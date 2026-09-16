import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:background_downloader/background_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rexone_mobile/config/app.config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/asset.model.dart';
import 'package:rexone_mobile/models/media_download_entry.model.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/media_download_notification.service.dart';
import 'package:rexone_mobile/services/storage.service.dart';

class _PendingDownloadPlan {
  final String assetId;
  final String title;
  final String? mediaFormat;
  final List<ChildAssetModel> subtitles;

  const _PendingDownloadPlan({
    required this.assetId,
    required this.title,
    this.mediaFormat,
    this.subtitles = const [],
  });
}

/// Encrypted offline media downloads with background transfer support.
class MediaDownloadService extends GetxService {
  late final StorageService _storage;
  late final MediaService _media;
  late final MediaDownloadNotificationService _notifications;
  late Directory _offlineRoot;
  late Directory _decryptedCacheDir;
  late Directory _tempDir;

  final RxMap<String, MediaDownloadEntry> entries =
      <String, MediaDownloadEntry>{}.obs;

  final Map<String, _PendingDownloadPlan> _pendingPlans = {};
  final Map<String, Set<String>> _completedSubtitleIds = {};
  final Set<String> _activeAssetIds = {};
  bool _downloaderStarted = false;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageService>();
    _media = Get.find<MediaService>();
    _notifications = Get.find<MediaDownloadNotificationService>();
  }

  /// Must run once at app startup before downloads are enqueued.
  Future<void> initializeDownloader() async {
    if (_downloaderStarted) {
      await _ensureDirectories();
      return;
    }

    FileDownloader().registerCallbacks(
      group: MediaDownloadConstants.downloadTaskGroup,
      taskStatusCallback: _onTaskStatusUpdate,
      taskProgressCallback: _onTaskProgressUpdate,
    );

    FileDownloader().configure(
      androidConfig: [(Config.runInForeground, Config.whenAble)],
    );

    await FileDownloader().start(autoCleanDatabase: true);
    _downloaderStarted = true;
    await _ensureDirectories();
    _loadIndexFromStorage();
    await _reconcileInterruptedDownloads();
  }

  MediaDownloadEntry? entryFor(String assetId) => entries[assetId];

  EMediaDownloadState stateFor(String assetId) =>
      entries[assetId]?.state ?? EMediaDownloadState.none;

  double progressFor(String assetId) => entries[assetId]?.progress ?? 0;

  bool isDownloaded(String assetId) => entries[assetId]?.isReady ?? false;

  bool isBusy(String assetId) {
    final state = stateFor(assetId);
    return state == EMediaDownloadState.queued ||
        state == EMediaDownloadState.downloading ||
        state == EMediaDownloadState.processing;
  }

  Future<void> downloadAsset(AssetModel asset) async {
    if (asset.id.isEmpty) {
      throw StateError('Invalid asset id');
    }
    if (AppConfig.offlineEncryptionKey.isEmpty) {
      throw StateError('MEDIA_OFFLINE_ENCRYPTION_KEY is not configured');
    }
    if (isDownloaded(asset.id) || isBusy(asset.id)) return;
    if (_activeAssetIds.length >=
        MediaDownloadConstants.maxConcurrentDownloads) {
      throw StateError('Too many active downloads');
    }

    _setEntry(
      MediaDownloadEntry(
        assetId: asset.id,
        state: EMediaDownloadState.queued,
        progress: 0,
        title: asset.displayTitle,
        mediaFormat: asset.format,
      ),
    );

    try {
      final playback = await _media.getAssetPlayback(asset.id);
      if (!playback.success || playback.data == null) {
        throw StateError(playback.message);
      }

      final url = playback.data!.delivery.url;
      if (url.isEmpty) {
        throw StateError('Playback URL is empty');
      }

      _pendingPlans[asset.id] = _PendingDownloadPlan(
        assetId: asset.id,
        title: asset.displayTitle,
        mediaFormat: asset.format,
        subtitles: playback.data!.media.playableSubtitles,
      );
      _completedSubtitleIds[asset.id] = {};
      _activeAssetIds.add(asset.id);

      _setEntry(
        (entries[asset.id] ?? MediaDownloadEntry(assetId: asset.id)).copyWith(
          state: EMediaDownloadState.downloading,
          progress: 0,
          clearErrorMessage: true,
        ),
      );

      await _notifications.onDownloadStarted(
        assetId: asset.id,
        title: asset.displayTitle,
      );

      final task = _buildMediaTask(
        assetId: asset.id,
        url: url,
        title: asset.displayTitle,
        mediaFormat: asset.format,
      );
      final enqueued = await FileDownloader().enqueue(task);
      if (!enqueued) {
        throw StateError('Unable to enqueue media download');
      }
    } catch (error) {
      await _failDownload(asset.id, error.toString());
      rethrow;
    }
  }

  /// Encrypts plaintext bytes into the offline sandbox and marks the entry ready.
  /// Used after a network download completes and by unit tests.
  Future<void> storeEncryptedMedia({
    required String assetId,
    required Uint8List plaintext,
    Map<String, Uint8List> subtitles = const {},
    String? title,
    String? mediaFormat,
  }) async {
    await _ensureDirectories();
    _setEntry(
      (entries[assetId] ??
              MediaDownloadEntry(
                assetId: assetId,
                title: title,
                mediaFormat: mediaFormat,
              ))
          .copyWith(
        state: EMediaDownloadState.processing,
        progress: 0.9,
        title: title,
        mediaFormat: mediaFormat,
        clearErrorMessage: true,
      ),
    );

    try {
      final key = AppConfig.offlineEncryptionKey;
      final encrypted = await MediaEncryptionHelper.encrypt(
        plaintext: plaintext,
        encryptionKey: key,
      );
      final mediaFile = _mediaFile(assetId);
      await mediaFile.writeAsBytes(encrypted, flush: true);

      final subtitlePaths = <String, String>{};
      for (final item in subtitles.entries) {
        final encryptedSubtitle = await MediaEncryptionHelper.encrypt(
          plaintext: item.value,
          encryptionKey: key,
        );
        final subtitleFile = _subtitleFile(assetId, item.key);
        await subtitleFile.writeAsBytes(encryptedSubtitle, flush: true);
        subtitlePaths[item.key] = subtitleFileName(assetId, item.key);
      }

      await _clearDecryptedCacheFor(assetId);

      _setEntry(
        (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
          state: EMediaDownloadState.ready,
          progress: 1,
          mediaPath: mediaFileName(assetId),
          subtitlePaths: subtitlePaths,
          downloadedAt: DateTime.now(),
          title: title,
          mediaFormat: mediaFormat,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      _setEntry(
        (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
          state: EMediaDownloadState.failed,
          progress: 0,
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<void> cancelDownload(String assetId) async {
    if (_downloaderStarted) {
      try {
        await FileDownloader().cancelTasksWithIds(_taskIdsForAsset(assetId));
      } catch (_) {}
    }
    await _deleteTempFiles(assetId);
    _pendingPlans.remove(assetId);
    _completedSubtitleIds.remove(assetId);
    _activeAssetIds.remove(assetId);

    if (isDownloaded(assetId)) return;

    entries.remove(assetId);
    entries.refresh();
    _persistIndex();
    await _notifications.endLiveActivityFor(assetId);
  }

  Future<void> deleteDownload(String assetId) async {
    await cancelDownload(assetId);

    final entry = entries[assetId];
    if (entry != null) {
      final media = _mediaFile(assetId);
      if (await media.exists()) {
        await media.delete();
      }
      for (final subtitleId in entry.subtitlePaths.keys) {
        final subtitle = _subtitleFile(assetId, subtitleId);
        if (await subtitle.exists()) {
          await subtitle.delete();
        }
      }
    }

    await _clearDecryptedCacheFor(assetId);
    entries.remove(assetId);
    entries.refresh();
    _persistIndex();
  }

  Future<void> clearAllDownloads() async {
    final assetIds = entries.keys.toList();
    for (final assetId in assetIds) {
      await cancelDownload(assetId);
    }

    await _ensureDirectories();
    if (await _offlineRoot.exists()) {
      await _offlineRoot.delete(recursive: true);
      await _ensureDirectories();
    }

    entries.clear();
    entries.refresh();
    _storage.clearMediaDownloadsIndex();
    await _notifications.endAllLiveActivities();
  }

  Future<String?> resolveDecryptedMediaPath(String assetId) async {
    final entry = entries[assetId];
    if (entry == null || !entry.isReady) return null;

    final encryptedFile = _mediaFile(assetId);
    if (!await encryptedFile.exists()) return null;

    final cacheFile = _decryptedMediaCacheFile(assetId);
    final encryptedModified = await encryptedFile.lastModified();
    if (await cacheFile.exists()) {
      final cacheModified = await cacheFile.lastModified();
      if (!cacheModified.isBefore(encryptedModified)) {
        return cacheFile.path;
      }
    }

    final decrypted = await MediaEncryptionHelper.decrypt(
      ciphertext: await encryptedFile.readAsBytes(),
      encryptionKey: AppConfig.offlineEncryptionKey,
    );
    await cacheFile.writeAsBytes(decrypted, flush: true);
    return cacheFile.path;
  }

  Future<String?> resolveDecryptedSubtitlePath(
    String assetId,
    String subtitleId,
  ) async {
    final entry = entries[assetId];
    if (entry == null || !entry.isReady) return null;

    final relativePath = entry.subtitlePaths[subtitleId];
    if (relativePath == null || relativePath.isEmpty) return null;

    final encryptedFile = File('${_offlineRoot.path}/$relativePath');
    if (!await encryptedFile.exists()) return null;

    final cacheFile = _decryptedSubtitleCacheFile(assetId, subtitleId);
    final encryptedModified = await encryptedFile.lastModified();
    if (await cacheFile.exists()) {
      final cacheModified = await cacheFile.lastModified();
      if (!cacheModified.isBefore(encryptedModified)) {
        return cacheFile.path;
      }
    }

    final decrypted = await MediaEncryptionHelper.decrypt(
      ciphertext: await encryptedFile.readAsBytes(),
      encryptionKey: AppConfig.offlineEncryptionKey,
    );
    await cacheFile.writeAsBytes(decrypted, flush: true);
    return cacheFile.path;
  }

  /// Builds playable subtitle tracks with `file://` URLs for offline playback.
  Future<List<ChildAssetModel>> resolveOfflineSubtitleTracks(
    AssetModel asset,
  ) async {
    if (!isDownloaded(asset.id)) return const [];

    final entry = entries[asset.id];
    if (entry == null || entry.subtitlePaths.isEmpty) return const [];

    final tracks = <ChildAssetModel>[];
    final seen = <String>{};

    for (final subtitle in asset.playableSubtitles) {
      if (subtitle.id.isEmpty || seen.contains(subtitle.id)) continue;
      final path = await resolveDecryptedSubtitlePath(asset.id, subtitle.id);
      if (path == null) continue;
      seen.add(subtitle.id);
      tracks.add(
        ChildAssetModel(
          id: subtitle.id,
          url: Uri.file(path).toString(),
          status: AssetKeys.statusReady,
          name: subtitle.name,
          extension: subtitle.extension ?? 'srt',
          format: subtitle.format,
          type: subtitle.type,
          sizeBytes: subtitle.sizeBytes,
        ),
      );
    }

    for (final subtitleId in entry.subtitlePaths.keys) {
      if (seen.contains(subtitleId)) continue;
      final path = await resolveDecryptedSubtitlePath(asset.id, subtitleId);
      if (path == null) continue;
      seen.add(subtitleId);
      tracks.add(
        ChildAssetModel(
          id: subtitleId,
          url: Uri.file(path).toString(),
          status: AssetKeys.statusReady,
          name: subtitleId,
          extension: 'srt',
        ),
      );
    }

    return tracks;
  }

  Future<void> _ensureDirectories() async {
    final supportDir = await getApplicationSupportDirectory();
    _offlineRoot = Directory(
      '${supportDir.path}/${MediaDownloadConstants.offlineRootDirName}',
    );
    _decryptedCacheDir = Directory(
      '${_offlineRoot.path}/${MediaDownloadConstants.decryptedCacheDirName}',
    );
    _tempDir = Directory(
      '${_offlineRoot.path}/${MediaDownloadConstants.tempDirName}',
    );
    for (final dir in [_offlineRoot, _decryptedCacheDir, _tempDir]) {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

  void _loadIndexFromStorage() {
    final raw = _storage.getMediaDownloadsIndex();
    if (raw == null || raw.isEmpty) {
      entries.clear();
      return;
    }

    final loaded = <String, MediaDownloadEntry>{};
    raw.forEach((key, value) {
      if (value is! Map) return;
      final entry = MediaDownloadEntry.fromJson(
        Map<String, dynamic>.from(value),
      );
      if (entry.assetId.isEmpty) return;
      loaded[entry.assetId] = entry;
    });
    entries.assignAll(loaded);
  }

  Future<void> _reconcileInterruptedDownloads() async {
    for (final entry in entries.values.toList()) {
      if (entry.state != EMediaDownloadState.downloading &&
          entry.state != EMediaDownloadState.queued) {
        continue;
      }

      final hasActiveTask = await _hasActiveTask(entry.assetId);
      if (!hasActiveTask) {
        _setEntry(
          entry.copyWith(
            state: EMediaDownloadState.failed,
            progress: 0,
            errorMessage: 'Download interrupted',
          ),
        );
      }
    }
  }

  Future<bool> _hasActiveTask(String assetId) async {
    for (final taskId in _taskIdsForAsset(assetId)) {
      final record = await FileDownloader().database.recordForId(taskId);
      if (record == null) continue;
      if (record.status == TaskStatus.enqueued ||
          record.status == TaskStatus.running ||
          record.status == TaskStatus.paused) {
        return true;
      }
    }
    return false;
  }

  void _onTaskProgressUpdate(TaskProgressUpdate update) {
    _onTaskProgress(update.task, update.progress);
  }

  Future<void> _onTaskStatusUpdate(TaskStatusUpdate update) async {
    await _onTaskStatus(update.task, update.status);
  }

  void _onTaskProgress(Task task, double progress) {
    final meta = _parseMeta(task.metaData);
    final assetId = meta[MediaDownloadConstants.metaAssetId]?.toString() ?? '';
    if (assetId.isEmpty) return;

    final phase = meta[MediaDownloadConstants.metaPhase]?.toString() ??
        MediaDownloadConstants.phaseMedia;
    final combined = _combinedProgress(
      assetId: assetId,
      phase: phase,
      phaseProgress: progress,
    );

    final entry = entries[assetId];
    if (entry == null) return;

    _setEntry(
      entry.copyWith(
        state: EMediaDownloadState.downloading,
        progress: combined,
      ),
    );

    final title = entry.title ?? assetId;
    _notifications.onDownloadProgress(
      assetId: assetId,
      title: title,
      progress: combined,
    );
  }

  Future<void> _onTaskStatus(Task task, TaskStatus status) async {
    final meta = _parseMeta(task.metaData);
    final assetId = meta[MediaDownloadConstants.metaAssetId]?.toString() ?? '';
    if (assetId.isEmpty) return;

    switch (status) {
      case TaskStatus.enqueued:
        _setEntry(
          (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
            state: EMediaDownloadState.queued,
          ),
        );
      case TaskStatus.running:
        _setEntry(
          (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
            state: EMediaDownloadState.downloading,
          ),
        );
      case TaskStatus.complete:
        await _handleTaskComplete(task, meta);
      case TaskStatus.canceled:
        await _handleTaskCanceled(assetId);
      case TaskStatus.failed:
      case TaskStatus.notFound:
        await _failDownload(
          assetId,
          'Download failed (${status.name})',
        );
      default:
        break;
    }
  }

  Future<void> _handleTaskComplete(
    Task task,
    Map<String, dynamic> meta,
  ) async {
    final assetId = meta[MediaDownloadConstants.metaAssetId]?.toString() ?? '';
    if (assetId.isEmpty) return;

    final phase = meta[MediaDownloadConstants.metaPhase]?.toString() ??
        MediaDownloadConstants.phaseMedia;

    if (phase == MediaDownloadConstants.phaseMedia) {
      await _enqueueSubtitleDownloads(assetId);
      return;
    }

    final subtitleId =
        meta[MediaDownloadConstants.metaSubtitleId]?.toString() ?? '';
    if (subtitleId.isNotEmpty) {
      _completedSubtitleIds.putIfAbsent(assetId, () => {}).add(subtitleId);
    }

    final plan = _pendingPlans[assetId];
    final totalSubtitles = plan?.subtitles.length ?? 0;
    final completed = _completedSubtitleIds[assetId]?.length ?? 0;
    if (completed < totalSubtitles) return;

    await _finalizeDownload(assetId);
  }

  Future<void> _enqueueSubtitleDownloads(String assetId) async {
    final plan = _pendingPlans[assetId];
    if (plan == null) {
      await _finalizeDownload(assetId);
      return;
    }

    if (plan.subtitles.isEmpty) {
      await _finalizeDownload(assetId);
      return;
    }

    for (final subtitle in plan.subtitles) {
      if (subtitle.id.isEmpty || subtitle.url.isEmpty) continue;
      final task = _buildSubtitleTask(
        assetId: assetId,
        subtitle: subtitle,
        title: plan.title,
        mediaFormat: plan.mediaFormat,
      );
      await FileDownloader().enqueue(task);
    }
  }

  Future<void> _finalizeDownload(String assetId) async {
    final plan = _pendingPlans[assetId];
    final entry = entries[assetId];
    if (entry == null) return;

    _setEntry(
      entry.copyWith(
        state: EMediaDownloadState.processing,
        progress: 0.95,
      ),
    );

    try {
      final mediaTemp = _mediaTempFile(assetId);
      if (!await mediaTemp.exists()) {
        throw StateError('Downloaded media file is missing');
      }

      final subtitleFiles = <String, File>{};
      for (final subtitle in plan?.subtitles ?? const <ChildAssetModel>[]) {
        if (subtitle.id.isEmpty) continue;
        final file = _subtitleTempFile(assetId, subtitle.id);
        if (await file.exists()) {
          subtitleFiles[subtitle.id] = file;
        }
      }

      await _storeEncryptedMediaFromFiles(
        assetId: assetId,
        plaintextFile: mediaTemp,
        subtitleFiles: subtitleFiles,
        title: plan?.title ?? entry.title,
        mediaFormat: plan?.mediaFormat ?? entry.mediaFormat,
      );

      await _deleteTempFiles(assetId);
      _pendingPlans.remove(assetId);
      _completedSubtitleIds.remove(assetId);
      _activeAssetIds.remove(assetId);

      await _notifications.onDownloadFinished(
        assetId: assetId,
        title: plan?.title ?? entry.title ?? assetId,
        success: true,
      );
    } catch (error) {
      await _failDownload(assetId, error.toString());
    }
  }

  Future<void> _storeEncryptedMediaFromFiles({
    required String assetId,
    required File plaintextFile,
    Map<String, File> subtitleFiles = const {},
    String? title,
    String? mediaFormat,
  }) async {
    await _ensureDirectories();
    final key = AppConfig.offlineEncryptionKey;

    final encrypted = await MediaEncryptionHelper.encrypt(
      plaintext: await plaintextFile.readAsBytes(),
      encryptionKey: key,
    );
    final mediaFile = _mediaFile(assetId);
    await mediaFile.writeAsBytes(encrypted, flush: true);

    final subtitlePaths = <String, String>{};
    for (final item in subtitleFiles.entries) {
      final encryptedSubtitle = await MediaEncryptionHelper.encrypt(
        plaintext: await item.value.readAsBytes(),
        encryptionKey: key,
      );
      final subtitleFile = _subtitleFile(assetId, item.key);
      await subtitleFile.writeAsBytes(encryptedSubtitle, flush: true);
      subtitlePaths[item.key] = subtitleFileName(assetId, item.key);
    }

    await _clearDecryptedCacheFor(assetId);

    _setEntry(
      (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
        state: EMediaDownloadState.ready,
        progress: 1,
        mediaPath: mediaFileName(assetId),
        subtitlePaths: subtitlePaths,
        downloadedAt: DateTime.now(),
        title: title,
        mediaFormat: mediaFormat,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _failDownload(String assetId, String message) async {
    await _deleteTempFiles(assetId);
    _pendingPlans.remove(assetId);
    _completedSubtitleIds.remove(assetId);
    _activeAssetIds.remove(assetId);

    final entry = entries[assetId];
    if (entry != null) {
      _setEntry(
        entry.copyWith(
          state: EMediaDownloadState.failed,
          progress: 0,
          errorMessage: message,
        ),
      );
    }

    await _notifications.onDownloadFinished(
      assetId: assetId,
      title: entry?.title ?? assetId,
      success: false,
      errorMessage: message,
    );
  }

  Future<void> _handleTaskCanceled(String assetId) async {
    await _deleteTempFiles(assetId);
    _pendingPlans.remove(assetId);
    _completedSubtitleIds.remove(assetId);
    _activeAssetIds.remove(assetId);

    entries.remove(assetId);
    entries.refresh();
    _persistIndex();
  }

  DownloadTask _buildMediaTask({
    required String assetId,
    required String url,
    required String title,
    String? mediaFormat,
  }) {
    return DownloadTask(
      taskId: _mediaTaskId(assetId),
      url: url,
      filename: '$assetId${MediaDownloadConstants.tempMediaSuffix}',
      directory:
          '${MediaDownloadConstants.offlineRootDirName}/${MediaDownloadConstants.tempDirName}',
      baseDirectory: BaseDirectory.applicationSupport,
      group: MediaDownloadConstants.downloadTaskGroup,
      updates: Updates.statusAndProgress,
      displayName: title.isNotEmpty ? title : assetId,
      metaData: jsonEncode({
        MediaDownloadConstants.metaAssetId: assetId,
        MediaDownloadConstants.metaPhase: MediaDownloadConstants.phaseMedia,
        MediaDownloadConstants.metaTitle: title,
        MediaDownloadConstants.metaMediaFormat: mediaFormat,
      }),
      allowPause: true,
    );
  }

  DownloadTask _buildSubtitleTask({
    required String assetId,
    required ChildAssetModel subtitle,
    required String title,
    String? mediaFormat,
  }) {
    return DownloadTask(
      taskId: _subtitleTaskId(assetId, subtitle.id),
      url: subtitle.url,
      filename:
          '${assetId}_${subtitle.id}${MediaDownloadConstants.tempSubtitleSuffix}',
      directory:
          '${MediaDownloadConstants.offlineRootDirName}/${MediaDownloadConstants.tempDirName}',
      baseDirectory: BaseDirectory.applicationSupport,
      group: MediaDownloadConstants.downloadTaskGroup,
      updates: Updates.statusAndProgress,
      displayName: subtitle.displayLabel,
      metaData: jsonEncode({
        MediaDownloadConstants.metaAssetId: assetId,
        MediaDownloadConstants.metaPhase: MediaDownloadConstants.phaseSubtitle,
        MediaDownloadConstants.metaSubtitleId: subtitle.id,
        MediaDownloadConstants.metaTitle: title,
        MediaDownloadConstants.metaMediaFormat: mediaFormat,
      }),
      allowPause: true,
    );
  }

  double _combinedProgress({
    required String assetId,
    required String phase,
    required double phaseProgress,
  }) {
    final plan = _pendingPlans[assetId];
    final subtitleCount = plan?.subtitles.length ?? 0;

    if (phase == MediaDownloadConstants.phaseMedia) {
      if (subtitleCount == 0) return phaseProgress.clamp(0, 1);
      return (phaseProgress * 0.85).clamp(0, 1);
    }

    final completed = _completedSubtitleIds[assetId]?.length ?? 0;
    final current = phaseProgress.clamp(0, 1);
    final subtitleWeight = 0.15 / subtitleCount;
    return (0.85 + (completed * subtitleWeight) + (current * subtitleWeight))
        .clamp(0, 0.99);
  }

  Map<String, dynamic> _parseMeta(String? metaData) {
    if (metaData == null || metaData.isEmpty) return {};
    try {
      final decoded = jsonDecode(metaData);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return {MediaDownloadConstants.metaAssetId: metaData};
    }
    return {};
  }

  String mediaFileName(String assetId) =>
      '$assetId${MediaDownloadConstants.mediaFileSuffix}';

  String subtitleFileName(String assetId, String subtitleId) =>
      '${assetId}_$subtitleId${MediaDownloadConstants.subtitleFileSuffix}';

  File _mediaFile(String assetId) =>
      File('${_offlineRoot.path}/${mediaFileName(assetId)}');

  File _subtitleFile(String assetId, String subtitleId) =>
      File('${_offlineRoot.path}/${subtitleFileName(assetId, subtitleId)}');

  File _mediaTempFile(String assetId) =>
      File('${_tempDir.path}/$assetId${MediaDownloadConstants.tempMediaSuffix}');

  File _subtitleTempFile(String assetId, String subtitleId) => File(
        '${_tempDir.path}/${assetId}_$subtitleId${MediaDownloadConstants.tempSubtitleSuffix}',
      );

  File _decryptedMediaCacheFile(String assetId) =>
      File('${_decryptedCacheDir.path}/$assetId.bin');

  File _decryptedSubtitleCacheFile(String assetId, String subtitleId) =>
      File('${_decryptedCacheDir.path}/${assetId}_$subtitleId.srt');

  String _mediaTaskId(String assetId) => 'media_dl_$assetId';

  String _subtitleTaskId(String assetId, String subtitleId) =>
      'media_dl_${assetId}_sub_$subtitleId';

  List<String> _taskIdsForAsset(String assetId) {
    final ids = <String>[_mediaTaskId(assetId)];
    final plan = _pendingPlans[assetId] ?? _planFromEntry(assetId);
    for (final subtitle in plan?.subtitles ?? const <ChildAssetModel>[]) {
      if (subtitle.id.isEmpty) continue;
      ids.add(_subtitleTaskId(assetId, subtitle.id));
    }
    return ids;
  }

  _PendingDownloadPlan? _planFromEntry(String assetId) {
    final entry = entries[assetId];
    if (entry == null) return null;
    return _PendingDownloadPlan(
      assetId: assetId,
      title: entry.title ?? assetId,
      mediaFormat: entry.mediaFormat,
    );
  }

  Future<void> _deleteTempFiles(String assetId) async {
    await _ensureDirectories();
    final mediaTemp = _mediaTempFile(assetId);
    if (await mediaTemp.exists()) {
      await mediaTemp.delete();
    }

    final dir = _tempDir;
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (name.startsWith('${assetId}_') || name.startsWith('$assetId.')) {
        await entity.delete();
      }
    }
  }

  Future<void> _clearDecryptedCacheFor(String assetId) async {
    final mediaCache = _decryptedMediaCacheFile(assetId);
    if (await mediaCache.exists()) {
      await mediaCache.delete();
    }

    final entry = entries[assetId];
    if (entry == null) return;
    for (final subtitleId in entry.subtitlePaths.keys) {
      final subtitleCache = _decryptedSubtitleCacheFile(assetId, subtitleId);
      if (await subtitleCache.exists()) {
        await subtitleCache.delete();
      }
    }
  }

  void _setEntry(MediaDownloadEntry entry) {
    entries[entry.assetId] = entry;
    entries.refresh();
    _persistIndex();
  }

  void _persistIndex() {
    final index = entries.map(
      (assetId, entry) => MapEntry(assetId, entry.toJson()),
    );
    _storage.saveMediaDownloadsIndex(index);
  }
}
