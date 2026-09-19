import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rexone_mobile/config/app.config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/data/local/local.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/asset.model.dart';
import 'package:rexone_mobile/models/media_download_entry.model.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/media_download_notification.service.dart';
import 'package:rexone_mobile/services/storage.service.dart';

class _PendingDownloadPlan {
  final String assetId;
  final AssetModel? asset;
  final String title;
  final String? mediaFormat;
  final List<ChildAssetModel> subtitles;
  final ChildAssetModel? thumbnail;

  const _PendingDownloadPlan({
    required this.assetId,
    this.asset,
    required this.title,
    this.mediaFormat,
    this.subtitles = const [],
    this.thumbnail,
  });
}

/// Encrypted offline media downloads with background transfer support.
class MediaDownloadService extends GetxService {
  late final StorageService _storage;
  late final MediaService _media;
  late final MediaDownloadNotificationService _notifications;
  AppDatabase? get _db =>
      Get.isRegistered<AppDatabase>() ? Get.find<AppDatabase>() : null;
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

    await FileDownloader().configure(
      androidConfig: [(Config.runInForeground, Config.always)],
    );

    await FileDownloader().start(autoCleanDatabase: true);
    _downloaderStarted = true;
    await _ensureDirectories();
    await _loadIndex();
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

  bool isPaused(String assetId) =>
      stateFor(assetId) == EMediaDownloadState.paused;

  Future<void> pauseDownload(String assetId) async {
    final entry = entries[assetId];
    if (entry == null) return;
    if (entry.state != EMediaDownloadState.downloading &&
        entry.state != EMediaDownloadState.queued) {
      return;
    }
    if (!_downloaderStarted) return;

    var attempted = false;
    for (final taskId in _taskIdsForAsset(assetId)) {
      final task = await FileDownloader().taskForId(taskId);
      if (task is! DownloadTask) continue;
      attempted = true;
      await FileDownloader().pause(task);
    }

    if (!attempted && entry.state == EMediaDownloadState.queued) {
      // Queued with no running task yet — mark paused locally.
    }

    _activeAssetIds.remove(assetId);
    _setEntry(
      entry.copyWith(state: EMediaDownloadState.paused),
    );
    await _notifications.onDownloadPaused(
      assetId: assetId,
      title: entry.title ?? assetId,
      progress: entry.progress,
    );
  }

  Future<void> resumeDownload(String assetId) async {
    final entry = entries[assetId];
    if (entry == null || entry.state != EMediaDownloadState.paused) return;
    if (!_downloaderStarted) {
      throw StateError('Downloader not started');
    }
    if (_activeAssetIds.length >=
        MediaDownloadConstants.maxConcurrentDownloads) {
      throw StateError('Too many active downloads');
    }

    var resumed = false;
    for (final taskId in _taskIdsForAsset(assetId)) {
      final task = await FileDownloader().taskForId(taskId);
      if (task is! DownloadTask) continue;
      final ok = await FileDownloader().resume(task);
      resumed = resumed || ok;
    }

    if (!resumed) {
      // Fall back to record lookup when taskForId is empty after pause.
      for (final taskId in _taskIdsForAsset(assetId)) {
        final record = await FileDownloader().database.recordForId(taskId);
        final task = record?.task;
        if (task is! DownloadTask) continue;
        final ok = await FileDownloader().resume(task);
        resumed = resumed || ok;
      }
    }

    if (!resumed) {
      throw StateError('Unable to resume download');
    }

    _activeAssetIds.add(assetId);
    _setEntry(
      entry.copyWith(state: EMediaDownloadState.downloading),
    );
    await _notifications.onDownloadProgress(
      assetId: assetId,
      title: entry.title ?? assetId,
      progress: entry.progress,
      paused: false,
    );
  }

  Future<void> downloadAsset(AssetModel asset) async {
    if (asset.id.isEmpty) {
      throw StateError('Invalid asset id');
    }
    if (AppConfig.offlineEncryptionKey.isEmpty) {
      throw StateError('MEDIA_OFFLINE_ENCRYPTION_KEY is not configured');
    }
    if (isDownloaded(asset.id) || isBusy(asset.id) || isPaused(asset.id)) {
      return;
    }
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
        sizeBytes: asset.sizeBytes,
      ),
    );

    final db = _db;
    if (db != null) {
      try {
        await db.upsertAsset(
          asset.toCompanion(
            downloadState: 'queued',
            downloadProgress: 0.0,
          ),
        );
        final childCompanions = <LocalChildAssetsTableCompanion>[];
        if (asset.thumbnail != null) {
          childCompanions.add(asset.thumbnail!.toCompanion(asset.id));
        }
        for (final s in asset.playableSubtitles) {
          childCompanions.add(s.toCompanion(asset.id));
        }
        if (childCompanions.isNotEmpty) {
          await db.upsertChildAssets(childCompanions);
        }
      } catch (e) {
        debugPrint('⚠️ [MediaDownloadService] Failed to upsert asset into Drift: $e');
      }
    }

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
        asset: asset,
        title: asset.displayTitle,
        mediaFormat: asset.format,
        subtitles: playback.data!.media.playableSubtitles,
        thumbnail: asset.thumbnail,
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

      unawaited(
        _db?.updateDownloadState(
          assetId: asset.id,
          state: 'downloading',
          progress: 0.0,
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
          isEncrypted: true,
          clearErrorMessage: true,
        ),
      );

      final db = _db;
      if (db != null) {
        await db.upsertAsset(
          LocalAssetsTableCompanion(
            id: drift.Value(assetId),
            name: drift.Value(title ?? assetId),
            title: drift.Value(title),
            url: drift.Value(mediaFile.path),
            type: drift.Value(mediaFormat ?? 'video'),
            format: drift.Value(mediaFormat),
            downloadState: const drift.Value('ready'),
            downloadProgress: const drift.Value(1.0),
            localFilePath: drift.Value(mediaFile.path),
            downloadedAt: drift.Value(DateTime.now()),
          ),
        );
      }
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
    await _db?.deleteAssetCascade(assetId);
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
      for (final ext in ['jpg', 'png', 'webp', 'jpeg']) {
        final thumb = File('${_offlineRoot.path}/${assetId}_thumb.$ext');
        if (await thumb.exists()) {
          await thumb.delete();
        }
      }
    }

    await _clearDecryptedCacheFor(assetId);
    entries.remove(assetId);
    entries.refresh();
    _persistIndex();
    await _db?.deleteAssetCascade(assetId);
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
    await _db?.clearAllOfflineData();
    await _notifications.endAllLiveActivities();
  }

  /// Calculates the exact byte count occupied on device storage for a downloaded asset.
  Future<int> getOccupiedDiskSizeBytes(String assetId) async {
    int total = 0;
    try {
      final media = _mediaFile(assetId);
      if (await media.exists()) {
        total += await media.length();
      }
      final entry = entries[assetId];
      if (entry != null) {
        for (final subtitleId in entry.subtitlePaths.keys) {
          final sub = _subtitleFile(assetId, subtitleId);
          if (await sub.exists()) {
            total += await sub.length();
          }
        }
      }
      for (final ext in ['jpg', 'png', 'webp', 'jpeg']) {
        final thumb = File('${_offlineRoot.path}/${assetId}_thumb.$ext');
        if (await thumb.exists()) {
          total += await thumb.length();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [MediaDownloadService] Error calculating disk size for $assetId: $e');
    }
    return total;
  }

  /// Returns human-readable storage size occupied by this downloaded asset (e.g. `4.2 MB`).
  Future<String> getOccupiedDiskSizeFormatted(String assetId) async {
    final bytes = await getOccupiedDiskSizeBytes(assetId);
    if (bytes > 0) {
      return FileSizeHelper.formatBytes(bytes);
    }
    final entry = entries[assetId];
    return entry?.formattedSize ?? '';
  }

  /// Returns the total bytes occupied on disk by all offline downloads combined.
  Future<int> getTotalOccupiedDiskSizeBytes() async {
    int total = 0;
    for (final id in entries.keys) {
      if (isDownloaded(id)) {
        total += await getOccupiedDiskSizeBytes(id);
      }
    }
    return total;
  }

  /// Returns human-readable total storage occupied by all offline downloads (e.g. `128.5 MB`).
  Future<String> getTotalOccupiedDiskSizeFormatted() async {
    final total = await getTotalOccupiedDiskSizeBytes();
    return FileSizeHelper.formatBytes(total);
  }

  Future<String?> resolveDecryptedMediaPath(String assetId) async {
    final entry = entries[assetId];
    if (entry == null || !entry.isReady) return null;

    final mediaFile = _mediaFile(assetId);
    if (!await mediaFile.exists()) return null;

    // Direct sandboxed download: return path directly without duplicate cache copy
    if (!entry.isEncrypted) {
      return mediaFile.path;
    }

    final cacheFile = _decryptedMediaCacheFile(assetId);
    final encryptedModified = await mediaFile.lastModified();
    if (await cacheFile.exists()) {
      final cacheModified = await cacheFile.lastModified();
      if (!cacheModified.isBefore(encryptedModified)) {
        return cacheFile.path;
      }
    }

    final decrypted = await MediaEncryptionHelper.decrypt(
      ciphertext: await mediaFile.readAsBytes(),
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

    final file = File('${_offlineRoot.path}/$relativePath');
    if (!await file.exists()) return null;

    // Direct sandboxed download: return path directly
    if (!entry.isEncrypted) {
      return file.path;
    }

    final cacheFile = _decryptedSubtitleCacheFile(assetId, subtitleId);
    final encryptedModified = await file.lastModified();
    if (await cacheFile.exists()) {
      final cacheModified = await cacheFile.lastModified();
      if (!cacheModified.isBefore(encryptedModified)) {
        return cacheFile.path;
      }
    }

    final decrypted = await MediaEncryptionHelper.decrypt(
      ciphertext: await file.readAsBytes(),
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
          title: subtitle.title,
          description: subtitle.description,
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

  Future<void> _loadIndex() async {
    final db = _db;
    if (db != null) {
      try {
        final localAssets = await db.getAllLocalAssets();
        if (localAssets.isNotEmpty) {
          final loaded = <String, MediaDownloadEntry>{};
          for (final a in localAssets) {
            final state = EMediaDownloadState.fromStorage(a.downloadState);
            final children = await db.getChildAssets(a.id);
            final subtitlePaths = <String, String>{};
            for (final c in children) {
              if (c.isDownloaded && c.localFilePath != null) {
                subtitlePaths[c.id] = c.localFilePath!;
              }
            }
            loaded[a.id] = MediaDownloadEntry(
              assetId: a.id,
              state: state,
              progress: a.downloadProgress,
              mediaPath: a.localFilePath != null
                  ? (a.localFilePath!.contains('/')
                      ? a.localFilePath!.split('/').last
                      : a.localFilePath!)
                  : '',
              subtitlePaths: subtitlePaths,
              downloadedAt: a.downloadedAt,
              errorMessage: a.errorMessage,
              title: a.title ?? a.name,
              mediaFormat: a.format,
              isEncrypted: false,
            );
          }
          entries.assignAll(loaded);
          return;
        }
      } catch (e) {
        debugPrint('⚠️ [MediaDownloadService] Failed to load index from Drift: $e');
      }
    }
    _loadIndexFromStorage();
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
          entry.state != EMediaDownloadState.queued &&
          entry.state != EMediaDownloadState.paused) {
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
        continue;
      }

      if (entry.state == EMediaDownloadState.paused) {
        _activeAssetIds.remove(entry.assetId);
      } else if (entry.state == EMediaDownloadState.downloading ||
          entry.state == EMediaDownloadState.queued) {
        _activeAssetIds.add(entry.assetId);
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
    _onTaskProgress(
      update.task,
      update.progress,
      expectedFileSize:
          update.expectedFileSize > 0 ? update.expectedFileSize : null,
    );
  }

  Future<void> _onTaskStatusUpdate(TaskStatusUpdate update) async {
    await _onTaskStatus(update.task, update.status);
  }

  void _onTaskProgress(
    Task task,
    double progress, {
    int? expectedFileSize,
  }) {
    final meta = _parseMeta(task.metaData);
    final assetId = meta[MediaDownloadConstants.metaAssetId]?.toString() ?? '';
    if (assetId.isEmpty) return;

    final entry = entries[assetId];
    if (entry == null) return;
    if (entry.state == EMediaDownloadState.paused) return;

    final phase = meta[MediaDownloadConstants.metaPhase]?.toString() ??
        MediaDownloadConstants.phaseMedia;
    final combined = _combinedProgress(
      assetId: assetId,
      phase: phase,
      phaseProgress: progress,
    );

    final effectiveTotal = entry.sizeBytes ?? expectedFileSize;
    final downloadedBytes =
        effectiveTotal != null && effectiveTotal > 0
            ? (combined * effectiveTotal).round()
            : null;

    _setEntry(
      entry.copyWith(
        state: EMediaDownloadState.downloading,
        progress: combined,
        sizeBytes: effectiveTotal,
        downloadedBytes: downloadedBytes,
      ),
    );

    unawaited(
      _db?.updateDownloadState(
        assetId: assetId,
        state: 'downloading',
        progress: combined,
        sizeBytes: effectiveTotal,
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
        if (stateFor(assetId) == EMediaDownloadState.paused) return;
        _setEntry(
          (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
            state: EMediaDownloadState.queued,
          ),
        );
        unawaited(_db?.updateDownloadState(assetId: assetId, state: 'queued'));
      case TaskStatus.running:
        if (stateFor(assetId) == EMediaDownloadState.paused) return;
        _setEntry(
          (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
            state: EMediaDownloadState.downloading,
          ),
        );
        unawaited(
          _db?.updateDownloadState(assetId: assetId, state: 'downloading'),
        );
      case TaskStatus.paused:
        final entry = entries[assetId];
        if (entry == null) return;
        _activeAssetIds.remove(assetId);
        _setEntry(
          entry.copyWith(state: EMediaDownloadState.paused),
        );
        unawaited(_db?.updateDownloadState(assetId: assetId, state: 'paused'));
        await _notifications.onDownloadPaused(
          assetId: assetId,
          title: entry.title ?? assetId,
          progress: entry.progress,
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
    unawaited(
      _db?.updateDownloadState(
        assetId: assetId,
        state: 'processing',
        progress: 0.95,
      ),
    );

    try {
      final mediaTemp = _mediaTempFile(assetId);
      if (!await mediaTemp.exists()) {
        throw StateError('Downloaded media file is missing');
      }

      final mediaFile = _mediaFile(assetId);
      await _moveFile(mediaTemp, mediaFile);

      final subtitlePaths = <String, String>{};
      for (final subtitle in plan?.subtitles ?? const <ChildAssetModel>[]) {
        if (subtitle.id.isEmpty) continue;
        final tempFile = _subtitleTempFile(assetId, subtitle.id);
        if (await tempFile.exists()) {
          final targetFile = _subtitleFile(assetId, subtitle.id);
          await _moveFile(tempFile, targetFile);
          subtitlePaths[subtitle.id] = subtitleFileName(assetId, subtitle.id);
          await _db?.markChildAssetDownloaded(
            childId: subtitle.id,
            localFilePath: targetFile.path,
          );
        }
      }

      if (plan?.thumbnail != null) {
        await _downloadThumbnailIfPresent(assetId, plan!.thumbnail);
      }

      await _clearDecryptedCacheFor(assetId);

      int diskSizeBytes = 0;
      if (await mediaFile.exists()) {
        diskSizeBytes += await mediaFile.length();
      }
      for (final subtitleId in subtitlePaths.keys) {
        final subFile = _subtitleFile(assetId, subtitleId);
        if (await subFile.exists()) {
          diskSizeBytes += await subFile.length();
        }
      }
      for (final ext in ['jpg', 'png', 'webp', 'jpeg']) {
        final thumb = File('${_offlineRoot.path}/${assetId}_thumb.$ext');
        if (await thumb.exists()) {
          diskSizeBytes += await thumb.length();
        }
      }

      final now = DateTime.now();
      final effectiveSize =
          diskSizeBytes > 0 ? diskSizeBytes : (plan?.asset?.sizeBytes ?? entry.sizeBytes);

      _setEntry(
        (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
          state: EMediaDownloadState.ready,
          progress: 1,
          mediaPath: mediaFileName(assetId),
          subtitlePaths: subtitlePaths,
          downloadedAt: now,
          title: plan?.title ?? entry.title,
          mediaFormat: plan?.mediaFormat ?? entry.mediaFormat,
          isEncrypted: false,
          diskSizeBytes: diskSizeBytes > 0 ? diskSizeBytes : null,
          sizeBytes: effectiveSize,
          downloadedBytes: effectiveSize,
          clearErrorMessage: true,
        ),
      );

      await _db?.updateDownloadState(
        assetId: assetId,
        state: 'ready',
        progress: 1.0,
        localFilePath: mediaFile.path,
        downloadedAt: now,
        sizeBytes: effectiveSize,
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

  Future<void> _downloadThumbnailIfPresent(
    String assetId,
    ChildAssetModel? thumbnail,
  ) async {
    if (thumbnail == null || thumbnail.url.isEmpty) {
      return;
    }
    final normalizedUrl = UrlHelper.normalize(thumbnail.url);
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      return;
    }
    try {
      final ext = thumbnail.extension ?? 'jpg';
      final targetFile = File('${_offlineRoot.path}/${assetId}_thumb.$ext');
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(normalizedUrl));
      UrlHelper.headersFor(normalizedUrl).forEach((k, v) {
        request.headers.set(k, v);
      });
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final sink = targetFile.openWrite();
        await response.pipe(sink);
        final thumbId =
            thumbnail.id.isNotEmpty ? thumbnail.id : '${assetId}_thumb';
        await _db?.markChildAssetDownloaded(
          childId: thumbId,
          localFilePath: targetFile.path,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [MediaDownloadService] Failed to cache thumbnail: $e');
    }
  }

  Future<void> _moveFile(File source, File destination) async {
    try {
      if (await destination.exists()) {
        await destination.delete();
      }
      await source.rename(destination.path);
    } catch (_) {
      await source.copy(destination.path);
      try {
        await source.delete();
      } catch (_) {}
    }
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

    unawaited(
      _db?.updateDownloadState(
        assetId: assetId,
        state: 'failed',
        errorMessage: message,
      ),
    );

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
    final normalizedUrl = UrlHelper.normalize(url);
    final headers = UrlHelper.headersFor(normalizedUrl);
    return DownloadTask(
      taskId: _mediaTaskId(assetId),
      url: normalizedUrl,
      headers: headers.isEmpty ? null : headers,
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
    final normalizedUrl = UrlHelper.normalize(subtitle.url);
    final headers = UrlHelper.headersFor(normalizedUrl);
    return DownloadTask(
      taskId: _subtitleTaskId(assetId, subtitle.id),
      url: normalizedUrl,
      headers: headers.isEmpty ? null : headers,
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
