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

class MediaDownloadException implements Exception {
  final String message;
  const MediaDownloadException(this.message);

  @override
  String toString() => message;
}

class MediaDownloadLimitException extends MediaDownloadException {
  const MediaDownloadLimitException() : super('Too many active downloads');
}

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

/// Offline media downloads: AES-GCM for audio/video; plaintext for images/attachments.
class MediaDownloadService extends GetxService {
  late final StorageService _storage;
  late final MediaService _media;
  late final MediaDownloadNotificationService _notifications;
  AppDatabase? get _db =>
      Get.isRegistered<AppDatabase>() ? Get.find<AppDatabase>() : null;
  late Directory _supportRoot;
  late Directory _offlineRoot;
  late Directory _plaintextRoot;
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
    _setEntry(entry.copyWith(state: EMediaDownloadState.paused));
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
      throw const MediaDownloadException('Downloader not started');
    }
    if (_activeAssetIds.length >=
        MediaDownloadConstants.maxConcurrentDownloads) {
      throw const MediaDownloadLimitException();
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
      throw const MediaDownloadException('Unable to resume download');
    }

    _activeAssetIds.add(assetId);
    _setEntry(entry.copyWith(state: EMediaDownloadState.downloading));
    await _notifications.onDownloadProgress(
      assetId: assetId,
      title: entry.title ?? assetId,
      progress: entry.progress,
      paused: false,
    );
  }

  Future<void> downloadAsset(AssetModel asset) async {
    if (asset.id.isEmpty) {
      throw const MediaDownloadException('Invalid asset id');
    }
    final encrypt = _shouldEncryptAsset(asset);
    if (encrypt && AppConfig.offlineEncryptionKey.isEmpty) {
      throw const MediaDownloadException(
        'MEDIA_OFFLINE_ENCRYPTION_KEY is not configured',
      );
    }
    if (isDownloaded(asset.id) || isBusy(asset.id) || isPaused(asset.id)) {
      return;
    }
    if (_activeAssetIds.length >=
        MediaDownloadConstants.maxConcurrentDownloads) {
      throw const MediaDownloadLimitException();
    }

    _setEntry(
      MediaDownloadEntry(
        assetId: asset.id,
        state: EMediaDownloadState.queued,
        progress: 0,
        title: asset.displayTitle,
        mediaFormat: asset.format,
        sizeBytes: asset.sizeBytes,
        isEncrypted: encrypt,
      ),
    );

    final db = _db;
    if (db != null) {
      try {
        await db.upsertAsset(
          asset.toCompanion(
            downloadState: EMediaDownloadState.queued.storageValue,
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
        debugPrint(
          '⚠️ [MediaDownloadService] Failed to upsert asset into Drift: $e',
        );
      }
    }

    try {
      final resolved = await _resolveDownloadSource(asset);

      _pendingPlans[asset.id] = _PendingDownloadPlan(
        assetId: asset.id,
        asset: asset,
        title: asset.displayTitle,
        mediaFormat: asset.format,
        subtitles: resolved.subtitles,
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
          state: EMediaDownloadState.downloading.storageValue,
          progress: 0.0,
        ),
      );

      await _notifications.onDownloadStarted(
        assetId: asset.id,
        title: asset.displayTitle,
      );

      final task = _buildMediaTask(
        assetId: asset.id,
        url: resolved.url,
        title: asset.displayTitle,
        mediaFormat: asset.format,
      );
      final enqueued = await FileDownloader().enqueue(task);
      if (!enqueued) {
        throw const MediaDownloadException('Unable to enqueue media download');
      }
    } catch (error) {
      await _failDownload(asset.id, error.toString());
      rethrow;
    }
  }

  /// Enqueues every downloadable asset that is not already ready/in-flight.
  /// Respects [MediaDownloadConstants.maxConcurrentDownloads] by waiting for slots.
  Future<int> downloadMissing(List<AssetModel> targets) async {
    var started = 0;
    for (final asset in targets) {
      if (!asset.isDownloadableAsset) continue;
      final state = stateFor(asset.id);
      if (state == EMediaDownloadState.ready ||
          state == EMediaDownloadState.queued ||
          state == EMediaDownloadState.downloading ||
          state == EMediaDownloadState.processing ||
          state == EMediaDownloadState.paused) {
        continue;
      }

      while (_activeAssetIds.length >=
          MediaDownloadConstants.maxConcurrentDownloads) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }

      try {
        await downloadAsset(asset);
        started++;
      } catch (error) {
        debugPrint(
          '❌ [MediaDownloadService] Bulk download skip ${asset.id}: $error',
        );
      }
    }
    return started;
  }

  Future<({String url, List<ChildAssetModel> subtitles})>
  _resolveDownloadSource(AssetModel asset) async {
    if (asset.isPlayableMedia) {
      final playback = await _media.getAssetPlayback(asset.id);
      if (!playback.success || playback.data == null) {
        throw MediaDownloadException(playback.message);
      }
      final url = playback.data!.delivery.url;
      if (url.isEmpty) {
        throw const MediaDownloadException('Playback URL is empty');
      }
      return (url: url, subtitles: playback.data!.media.playableSubtitles);
    }

    final url = asset.url;
    if (url.isEmpty) {
      throw const MediaDownloadException('Asset URL is empty');
    }
    return (url: url, subtitles: const <ChildAssetModel>[]);
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
      final mediaFile = _encryptedMediaFile(assetId);
      await mediaFile.writeAsBytes(encrypted, flush: true);

      final subtitlePaths = <String, String>{};
      for (final item in subtitles.entries) {
        final encryptedSubtitle = await MediaEncryptionHelper.encrypt(
          plaintext: item.value,
          encryptionKey: key,
        );
        final subtitleFile = _encryptedSubtitleFile(assetId, item.key);
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
            type: drift.Value(mediaFormat ?? AssetKeys.typeVideo),
            format: drift.Value(mediaFormat),
            downloadState: drift.Value(EMediaDownloadState.ready.storageValue),
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
      final media = _mediaFileForEntry(entry);
      if (await media.exists()) {
        await media.delete();
      }
      for (final relative in entry.subtitlePaths.values) {
        final subtitle = _fileFromRelativePath(relative);
        if (await subtitle.exists()) {
          await subtitle.delete();
        }
      }
      for (final ext in AssetKeys.imageExtensions) {
        final thumb = File('${_offlineRoot.path}/${assetId}_thumb.$ext');
        if (await thumb.exists()) {
          await thumb.delete();
        }
      }
      // Legacy plaintext stored under media_offline with .enc name.
      final legacy = File('${_offlineRoot.path}/${mediaFileName(assetId)}');
      if (legacy.path != media.path && await legacy.exists()) {
        await legacy.delete();
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
    }
    if (await _plaintextRoot.exists()) {
      await _plaintextRoot.delete(recursive: true);
    }
    await _ensureDirectories();

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
      final entry = entries[assetId];
      if (entry != null) {
        final media = _mediaFileForEntry(entry);
        if (await media.exists()) {
          total += await media.length();
        }
        for (final relative in entry.subtitlePaths.values) {
          final sub = _fileFromRelativePath(relative);
          if (await sub.exists()) {
            total += await sub.length();
          }
        }
      } else {
        final media = _encryptedMediaFile(assetId);
        if (await media.exists()) {
          total += await media.length();
        }
      }
      for (final ext in AssetKeys.imageExtensions) {
        final thumb = File('${_offlineRoot.path}/${assetId}_thumb.$ext');
        if (await thumb.exists()) {
          total += await thumb.length();
        }
      }
    } catch (e) {
      debugPrint(
        '⚠️ [MediaDownloadService] Error calculating disk size for $assetId: $e',
      );
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

    final mediaFile = _mediaFileForEntry(entry);
    if (!await mediaFile.exists()) return null;

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

  /// Path suitable for an external viewer (correct extension; FileProvider-friendly).
  ///
  /// Plaintext downloads under [MediaDownloadConstants.plaintextRootDirName] are
  /// returned as-is when the extension already matches. Encrypted A/V is decrypted
  /// to cache when needed for non-player open flows.
  Future<String?> resolveOpenableMediaPath(
    String assetId, {
    String? fileExtension,
  }) async {
    final entry = entries[assetId];
    if (entry == null || !entry.isReady) return null;

    final ext = _sanitizeFileExtension(fileExtension);
    if (!entry.isEncrypted) {
      final mediaFile = _mediaFileForEntry(entry);
      if (!await mediaFile.exists()) return null;
      if (ext == null || mediaFile.path.toLowerCase().endsWith('.$ext')) {
        return mediaFile.path;
      }
    }

    final sourcePath = await resolveDecryptedMediaPath(assetId);
    if (sourcePath == null || sourcePath.isEmpty) return null;

    final openExt = ext ?? 'bin';
    final openable = File('${_decryptedCacheDir.path}/$assetId.$openExt');
    final source = File(sourcePath);

    if (source.path == openable.path) return openable.path;

    final sourceModified = await source.lastModified();
    if (await openable.exists()) {
      final openableModified = await openable.lastModified();
      if (!openableModified.isBefore(sourceModified)) {
        return openable.path;
      }
    }

    await _ensureDirectories();
    await source.copy(openable.path);
    return openable.path;
  }

  String? _sanitizeFileExtension(String? raw) {
    if (raw == null) return null;
    var value = raw.trim().toLowerCase();
    if (value.startsWith('.')) value = value.substring(1);
    if (value.isEmpty ||
        value == MediaDownloadConstants.encryptedExtension ||
        value.contains('/') ||
        value.contains('\\')) {
      return null;
    }
    return value;
  }

  Future<String?> resolveDecryptedSubtitlePath(
    String assetId,
    String subtitleId,
  ) async {
    final entry = entries[assetId];
    if (entry == null || !entry.isReady) return null;

    final relativePath = entry.subtitlePaths[subtitleId];
    if (relativePath == null || relativePath.isEmpty) return null;

    final file = _fileFromRelativePath(relativePath);
    if (!await file.exists()) return null;

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
          extension: subtitle.extension ?? AssetKeys.extensionSrt,
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
          extension: AssetKeys.extensionSrt,
        ),
      );
    }

    return tracks;
  }

  Future<void> _ensureDirectories() async {
    final supportDir = await getApplicationSupportDirectory();
    _supportRoot = supportDir;
    _offlineRoot = Directory(
      '${supportDir.path}/${MediaDownloadConstants.offlineRootDirName}',
    );
    _plaintextRoot = Directory(
      '${supportDir.path}/${MediaDownloadConstants.plaintextRootDirName}',
    );
    _decryptedCacheDir = Directory(
      '${_offlineRoot.path}/${MediaDownloadConstants.decryptedCacheDirName}',
    );
    _tempDir = Directory(
      '${_offlineRoot.path}/${MediaDownloadConstants.tempDirName}',
    );
    for (final dir in [
      _offlineRoot,
      _plaintextRoot,
      _decryptedCacheDir,
      _tempDir,
    ]) {
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
          final storedIndex = _storage.getMediaDownloadsIndex() ?? const {};
          final loaded = <String, MediaDownloadEntry>{};
          for (final a in localAssets) {
            final state = EMediaDownloadState.fromStorage(a.downloadState);
            final children = await db.getChildAssets(a.id);
            final subtitlePaths = <String, String>{};
            for (final c in children) {
              if (c.isDownloaded && c.localFilePath != null) {
                final path = c.localFilePath!;
                subtitlePaths[c.id] = path.contains('/')
                    ? path.split('/').last
                    : path;
              }
            }
            final mediaName = a.localFilePath != null
                ? (a.localFilePath!.contains('/')
                      ? a.localFilePath!.split('/').last
                      : a.localFilePath!)
                : '';

            final stored = storedIndex[a.id];
            if (stored is Map) {
              final fromStorage = MediaDownloadEntry.fromJson(
                Map<String, dynamic>.from(stored),
              );
              loaded[a.id] = fromStorage.copyWith(
                state: state,
                progress: a.downloadProgress,
                downloadedAt: a.downloadedAt ?? fromStorage.downloadedAt,
                title: fromStorage.title ?? a.title ?? a.name,
                mediaFormat: fromStorage.mediaFormat ?? a.format,
                mediaPath: fromStorage.mediaPath.isNotEmpty
                    ? fromStorage.mediaPath
                    : mediaName,
                subtitlePaths: fromStorage.subtitlePaths.isNotEmpty
                    ? fromStorage.subtitlePaths
                    : subtitlePaths,
              );
              continue;
            }

            // Legacy Drift-only rows: treat as plaintext (pre-encryption finalize).
            loaded[a.id] = MediaDownloadEntry(
              assetId: a.id,
              state: state,
              progress: a.downloadProgress,
              mediaPath: mediaName,
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
        debugPrint(
          '⚠️ [MediaDownloadService] Failed to load index from Drift: $e',
        );
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
      expectedFileSize: update.expectedFileSize > 0
          ? update.expectedFileSize
          : null,
    );
  }

  Future<void> _onTaskStatusUpdate(TaskStatusUpdate update) async {
    await _onTaskStatus(update.task, update.status);
  }

  void _onTaskProgress(Task task, double progress, {int? expectedFileSize}) {
    final meta = _parseMeta(task.metaData);
    final assetId = meta[MediaDownloadConstants.metaAssetId]?.toString() ?? '';
    if (assetId.isEmpty) return;

    final entry = entries[assetId];
    if (entry == null) return;
    if (entry.state == EMediaDownloadState.paused) return;

    final phase =
        meta[MediaDownloadConstants.metaPhase]?.toString() ??
        MediaDownloadConstants.phaseMedia;
    final combined = _combinedProgress(
      assetId: assetId,
      phase: phase,
      phaseProgress: progress,
    );

    final effectiveTotal = entry.sizeBytes ?? expectedFileSize;
    final downloadedBytes = effectiveTotal != null && effectiveTotal > 0
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
        state: EMediaDownloadState.downloading.storageValue,
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
        unawaited(
          _db?.updateDownloadState(
            assetId: assetId,
            state: EMediaDownloadState.queued.storageValue,
          ),
        );
      case TaskStatus.running:
        if (stateFor(assetId) == EMediaDownloadState.paused) return;
        _setEntry(
          (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
            state: EMediaDownloadState.downloading,
          ),
        );
        unawaited(
          _db?.updateDownloadState(
            assetId: assetId,
            state: EMediaDownloadState.downloading.storageValue,
          ),
        );
      case TaskStatus.paused:
        final entry = entries[assetId];
        if (entry == null) return;
        _activeAssetIds.remove(assetId);
        _setEntry(entry.copyWith(state: EMediaDownloadState.paused));
        unawaited(
          _db?.updateDownloadState(
            assetId: assetId,
            state: EMediaDownloadState.paused.storageValue,
          ),
        );
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
        await _failDownload(assetId, 'Download failed (${status.name})');
      default:
        break;
    }
  }

  Future<void> _handleTaskComplete(Task task, Map<String, dynamic> meta) async {
    final assetId = meta[MediaDownloadConstants.metaAssetId]?.toString() ?? '';
    if (assetId.isEmpty) return;

    final phase =
        meta[MediaDownloadConstants.metaPhase]?.toString() ??
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
      entry.copyWith(state: EMediaDownloadState.processing, progress: 0.95),
    );
    unawaited(
      _db?.updateDownloadState(
        assetId: assetId,
        state: EMediaDownloadState.processing.storageValue,
        progress: 0.95,
      ),
    );

    try {
      final mediaTemp = _mediaTempFile(assetId);
      if (!await mediaTemp.exists()) {
        throw const MediaDownloadException('Downloaded media file is missing');
      }

      final encrypt = _shouldEncryptPlan(plan, entry);
      final plaintextExt = plan?.asset?.resolvedFileExtension ?? 'bin';

      late final File mediaFile;
      late final String mediaPathName;

      if (encrypt) {
        if (AppConfig.offlineEncryptionKey.isEmpty) {
          throw const MediaDownloadException(
            'MEDIA_OFFLINE_ENCRYPTION_KEY is not configured',
          );
        }
        final encrypted = await MediaEncryptionHelper.encrypt(
          plaintext: await mediaTemp.readAsBytes(),
          encryptionKey: AppConfig.offlineEncryptionKey,
        );
        mediaFile = _encryptedMediaFile(assetId);
        await mediaFile.writeAsBytes(encrypted, flush: true);
        await mediaTemp.delete();
        mediaPathName = mediaFileName(assetId);
      } else {
        mediaFile = _plaintextMediaFile(assetId, plaintextExt);
        await _moveFile(mediaTemp, mediaFile);
        mediaPathName = plaintextMediaFileName(assetId, plaintextExt);
      }

      final subtitlePaths = <String, String>{};
      for (final subtitle in plan?.subtitles ?? const <ChildAssetModel>[]) {
        if (subtitle.id.isEmpty) continue;
        final tempFile = _subtitleTempFile(assetId, subtitle.id);
        if (!await tempFile.exists()) continue;

        if (encrypt) {
          final encryptedSubtitle = await MediaEncryptionHelper.encrypt(
            plaintext: await tempFile.readAsBytes(),
            encryptionKey: AppConfig.offlineEncryptionKey,
          );
          final targetFile = _encryptedSubtitleFile(assetId, subtitle.id);
          await targetFile.writeAsBytes(encryptedSubtitle, flush: true);
          await tempFile.delete();
          subtitlePaths[subtitle.id] = subtitleFileName(assetId, subtitle.id);
          await _db?.markChildAssetDownloaded(
            childId: subtitle.id,
            localFilePath: targetFile.path,
          );
        } else {
          final targetFile = _plaintextSubtitleFile(assetId, subtitle.id);
          await _moveFile(tempFile, targetFile);
          subtitlePaths[subtitle.id] = plaintextSubtitleFileName(
            assetId,
            subtitle.id,
          );
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
      for (final relative in subtitlePaths.values) {
        final subFile = _fileFromRelativePath(relative);
        if (await subFile.exists()) {
          diskSizeBytes += await subFile.length();
        }
      }
      for (final ext in AssetKeys.imageExtensions) {
        final thumb = File('${_offlineRoot.path}/${assetId}_thumb.$ext');
        if (await thumb.exists()) {
          diskSizeBytes += await thumb.length();
        }
      }

      final now = DateTime.now();
      final effectiveSize = diskSizeBytes > 0
          ? diskSizeBytes
          : (plan?.asset?.sizeBytes ?? entry.sizeBytes);

      _setEntry(
        (entries[assetId] ?? MediaDownloadEntry(assetId: assetId)).copyWith(
          state: EMediaDownloadState.ready,
          progress: 1,
          mediaPath: mediaPathName,
          subtitlePaths: subtitlePaths,
          downloadedAt: now,
          title: plan?.title ?? entry.title,
          mediaFormat: plan?.mediaFormat ?? entry.mediaFormat,
          isEncrypted: encrypt,
          diskSizeBytes: diskSizeBytes > 0 ? diskSizeBytes : null,
          sizeBytes: effectiveSize,
          downloadedBytes: effectiveSize,
          clearErrorMessage: true,
        ),
      );

      await _db?.updateDownloadState(
        assetId: assetId,
        state: EMediaDownloadState.ready.storageValue,
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
        final thumbId = thumbnail.id.isNotEmpty
            ? thumbnail.id
            : '${assetId}_thumb';
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
        state: EMediaDownloadState.failed.storageValue,
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
    final uri = Uri.tryParse(url);
    // Playback URLs dynamically presigned for the client host (e.g. 10.0.2.2:3100) must not have
    // their Host header overridden, as doing so invalidates the S3 SigV4 signature.
    final isDynamicallySigned =
        uri != null &&
        uri.queryParameters.containsKey(AuthHeaders.xAmzSignature) &&
        uri.host != 'localhost' &&
        uri.host != '127.0.0.1';
    final headers = isDynamicallySigned
        ? null
        : (UrlHelper.headersFor(normalizedUrl).isEmpty
              ? null
              : UrlHelper.headersFor(normalizedUrl));
    return DownloadTask(
      taskId: _mediaTaskId(assetId),
      url: normalizedUrl,
      headers: headers,
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

  String plaintextMediaFileName(String assetId, String extension) =>
      '$assetId.$extension';

  String plaintextSubtitleFileName(String assetId, String subtitleId) =>
      '${assetId}_$subtitleId.srt';

  bool _shouldEncryptAsset(AssetModel asset) => asset.isPlayableMedia;

  bool _shouldEncryptPlan(
    _PendingDownloadPlan? plan,
    MediaDownloadEntry entry,
  ) {
    final asset = plan?.asset;
    if (asset != null) return _shouldEncryptAsset(asset);
    return _isPlayableFormat(plan?.mediaFormat ?? entry.mediaFormat);
  }

  bool _isPlayableFormat(String? formatOrType) {
    final value = formatOrType?.trim().toLowerCase() ?? '';
    return value == AssetKeys.formatAudio ||
        value == AssetKeys.formatVideo ||
        value == AssetKeys.typeAudio ||
        value == AssetKeys.typeVideo;
  }

  File _encryptedMediaFile(String assetId) =>
      File('${_offlineRoot.path}/${mediaFileName(assetId)}');

  File _encryptedSubtitleFile(String assetId, String subtitleId) =>
      File('${_offlineRoot.path}/${subtitleFileName(assetId, subtitleId)}');

  File _plaintextMediaFile(String assetId, String extension) => File(
    '${_plaintextRoot.path}/${plaintextMediaFileName(assetId, extension)}',
  );

  File _plaintextSubtitleFile(String assetId, String subtitleId) => File(
    '${_plaintextRoot.path}/${plaintextSubtitleFileName(assetId, subtitleId)}',
  );

  File _mediaFileForEntry(MediaDownloadEntry entry) {
    final name = entry.mediaPath.isNotEmpty
        ? entry.mediaPath
        : mediaFileName(entry.assetId);
    if (name.contains('/') || name.contains('\\')) {
      return File('${_supportRoot.path}/$name');
    }
    if (entry.isEncrypted) {
      return File('${_offlineRoot.path}/$name');
    }
    final plain = File('${_plaintextRoot.path}/$name');
    if (plain.existsSync()) return plain;
    // Legacy unencrypted files lived under media_offline as *.enc
    return File('${_offlineRoot.path}/$name');
  }

  File _fileFromRelativePath(String relativePath) {
    if (relativePath.contains('/') || relativePath.contains('\\')) {
      if (relativePath.startsWith('/')) return File(relativePath);
      return File('${_supportRoot.path}/$relativePath');
    }
    final plain = File('${_plaintextRoot.path}/$relativePath');
    if (plain.existsSync()) return plain;
    return File('${_offlineRoot.path}/$relativePath');
  }

  File _mediaTempFile(String assetId) => File(
    '${_tempDir.path}/$assetId${MediaDownloadConstants.tempMediaSuffix}',
  );

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
    await _ensureDirectories();
    final cacheDir = _decryptedCacheDir;
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (name == assetId ||
            name.startsWith('$assetId.') ||
            name.startsWith('${assetId}_')) {
          await entity.delete();
        }
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
