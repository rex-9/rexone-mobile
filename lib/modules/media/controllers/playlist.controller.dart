import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/data/local/local.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/app.routes.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/media_download.service.dart';
import 'package:rexone_mobile/services/network.service.dart';

import '../media.dart';

/// Paginated mixed audio/video playlist from `GET /v1/assets` (no type filter).
class MediaPlaylistController extends GetxController {
  late final MediaService _media;
  late final MediaDownloadService _downloads;

  NetworkService? get _network =>
      Get.isRegistered<NetworkService>() ? Get.find<NetworkService>() : null;

  bool get isOffline => _network != null && !_network!.isOnline.value;

  Worker? _networkWorker;

  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final Rxn<PaginationMeta> pagination = Rxn<PaginationMeta>();

  static const int _pageLimit = MediaLayoutConstants.playlistPageLimit;
  final List<AssetModel> _allFetched = [];
  int _currentPage = 1;
  bool _prefetching = false;

  AudioPlayerService get _audioPlayer => Get.find<AudioPlayerService>();

  VideoPlayerService get _videoPlayer => Get.find<VideoPlayerService>();

  List<AssetModel> get _audioAssets =>
      assets.where((item) => item.isAudioMedia).toList();

  List<AssetModel> get _videoAssets =>
      assets.where((item) => item.isVideoMedia).toList();

  AssetModel? get heroAsset {
    if (_audioPlayer.hasSession.value) {
      return _audioPlayer.currentAsset;
    }
    if (_videoPlayer.hasSession.value) {
      return _videoPlayer.currentAsset;
    }
    return assets.isNotEmpty ? assets.first : null;
  }

  @override
  void onInit() {
    super.onInit();
    _media = Get.find<MediaService>();
    _downloads = Get.find<MediaDownloadService>();
    if (_network != null) {
      _networkWorker = ever<bool>(_network!.isOnline, (online) {
        if (!online) {
          _loadOfflineAssets();
        } else {
          fetchAssets(refresh: true);
        }
      });
    }
    fetchAssets(refresh: true);
  }

  @override
  void onClose() {
    _networkWorker?.dispose();
    super.onClose();
  }

  MediaDownloadEntry? downloadEntryFor(AssetModel asset) =>
      _downloads.entryFor(asset.id);

  EMediaDownloadState downloadStateFor(AssetModel asset) =>
      _downloads.stateFor(asset.id);

  double downloadProgressFor(AssetModel asset) =>
      _downloads.progressFor(asset.id);

  Future<void> onDownloadTap(AssetModel asset) async {
    final state = downloadStateFor(asset);
    switch (state) {
      case EMediaDownloadState.none:
      case EMediaDownloadState.failed:
        await _startDownload(asset);
      case EMediaDownloadState.ready:
        await _removeDownload(asset);
      case EMediaDownloadState.paused:
        await _resumeDownload(asset);
      case EMediaDownloadState.processing:
        await _cancelDownload(asset);
      case EMediaDownloadState.queued:
      case EMediaDownloadState.downloading:
        break;
    }
  }

  Future<void> onDownloadPauseTap(AssetModel asset) async {
    final state = downloadStateFor(asset);
    if (state != EMediaDownloadState.queued &&
        state != EMediaDownloadState.downloading) {
      return;
    }
    try {
      await _downloads.pauseDownload(asset.id);
    } catch (error) {
      debugPrint('❌ [MediaPlaylistController] Pause download error: $error');
    }
  }

  Future<void> onDownloadLongPress(AssetModel asset) async {
    final state = downloadStateFor(asset);
    if (state == EMediaDownloadState.queued ||
        state == EMediaDownloadState.downloading ||
        state == EMediaDownloadState.paused) {
      await _cancelDownload(asset);
    }
  }

  Future<void> _startDownload(AssetModel asset) async {
    try {
      await _downloads.downloadAsset(asset);
    } catch (error) {
      final message = error.toString();
      if (message.contains('Too many active downloads')) {
        AppSnackbar.error(AppLocales.media.downloadTooMany.tr);
      } else {
        AppSnackbar.error(AppLocales.media.downloadFailed.tr);
      }
    }
  }

  Future<void> _resumeDownload(AssetModel asset) async {
    try {
      await _downloads.resumeDownload(asset.id);
    } catch (error) {
      final message = error.toString();
      if (message.contains('Too many active downloads')) {
        AppSnackbar.error(AppLocales.media.downloadTooMany.tr);
      } else {
        debugPrint('❌ [MediaPlaylistController] Resume download error: $error');
        AppSnackbar.error(AppLocales.media.downloadFailed.tr);
      }
    }
  }

  Future<void> _removeDownload(AssetModel asset) async {
    final sizeStr = await _downloads.getOccupiedDiskSizeFormatted(asset.id);
    final context = Get.context;
    if (context == null || !context.mounted) return;

    final confirmMessage = AppLocales.media.removeDownloadStorageConfirm
        .trParams({'title': asset.displayTitle, 'size': sizeStr});
    final confirmButton = AppLocales.media.removeDownloadWithSize
        .trParams({'size': sizeStr});

    final confirmed = await AppDialog.confirm(
      context: context,
      title: AppLocales.media.removeDownloadTitle.tr,
      message: confirmMessage,
      confirmLabel: confirmButton,
    );
    if (!confirmed) return;

    try {
      await _downloads.deleteDownload(asset.id);
      AppSnackbar.success(
        AppLocales.media.freedStorage.trParams({
          'title': asset.displayTitle,
          'size': sizeStr,
        }),
      );
      if (isOffline) {
        await _loadOfflineAssets();
      }
    } catch (error) {
      debugPrint('❌ [MediaPlaylistController] Remove download error: $error');
      AppSnackbar.error(AppLocales.media.downloadFailed.tr);
    }
  }

  Future<void> _cancelDownload(AssetModel asset) async {
    final context = Get.context;
    if (context == null) return;

    final confirmed = await AppDialog.confirm(
      context: context,
      title: AppLocales.media.cancelDownloadTitle.tr,
      message: AppLocales.media.cancelDownloadConfirm.tr,
      confirmLabel: AppLocales.media.cancelDownload.tr,
    );
    if (!confirmed) return;

    try {
      await _downloads.cancelDownload(asset.id);
    } catch (error) {
      debugPrint('❌ [MediaPlaylistController] Cancel download error: $error');
    }
  }

  bool isCurrentAsset(AssetModel asset) {
    if (asset.isAudioMedia) {
      return _audioPlayer.hasSession.value &&
          _audioPlayer.currentAsset?.id == asset.id;
    }
    if (asset.isVideoMedia) {
      return _videoPlayer.hasSession.value &&
          _videoPlayer.currentAsset?.id == asset.id;
    }
    return false;
  }

  bool isPlayingAsset(AssetModel asset) {
    if (!isCurrentAsset(asset)) return false;
    if (asset.isAudioMedia) return _audioPlayer.isPlaying.value;
    if (asset.isVideoMedia) return _videoPlayer.isPlaying.value;
    return false;
  }

  bool isLoadingAsset(AssetModel asset) {
    if (!isCurrentAsset(asset)) return false;
    if (asset.isAudioMedia) return _audioPlayer.isLoading.value;
    if (asset.isVideoMedia) return _videoPlayer.isLoading.value;
    return false;
  }

  Future<void> fetchAssets({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    if (isOffline) {
      isLoading.value = true;
      try {
        await _loadOfflineAssets();
      } finally {
        isLoading.value = false;
      }
      return;
    }

    isLoading.value = true;
    try {
      if (refresh) {
        _allFetched.clear();
      }
      await _loadPage(1, append: false);
      if (_allFetched.isEmpty) {
        await _loadOfflineAssets();
      } else {
        await _prefetchUntilScrollable();
      }
    } catch (e) {
      debugPrint('❌ [MediaPlaylistController] Fetch error: $e');
      if (_allFetched.isEmpty) {
        await _loadOfflineAssets();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOfflineAssets() async {
    if (!Get.isRegistered<AppDatabase>()) return;
    try {
      final db = Get.find<AppDatabase>();
      final localList = await db.getDownloadedAssets();
      final models = <AssetModel>[];
      if (localList.isNotEmpty) {
        for (final item in localList) {
          final children = await db.getChildAssets(item.id);
          models.add(item.toAssetModel(children: children));
        }
      }
      _allFetched
        ..clear()
        ..addAll(models);
      hasMore.value = false;
      _applyPlayableFilter();
    } catch (e) {
      debugPrint('⚠️ [MediaPlaylistController] Failed to load offline assets: $e');
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    final nextPage = (pagination.value?.currentPage ?? _currentPage) + 1;
    try {
      await _loadPage(nextPage, append: true);
    } catch (e) {
      debugPrint('❌ [MediaPlaylistController] Load more error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _loadPage(int page, {required bool append}) async {
    final res = await _media.getAssets(page: page, limit: _pageLimit);

    if (!res.success) {
      if (_allFetched.isEmpty) {
        await _loadOfflineAssets();
      } else {
        AppSnackbar.error(res.message);
      }
      return;
    }

    if (append) {
      _allFetched.addAll(res.records);
    } else {
      _allFetched
        ..clear()
        ..addAll(res.records);
    }

    pagination.value = res.pagination;
    hasMore.value = res.pagination?.hasNextPage ?? false;
    _currentPage = page;
    _applyPlayableFilter();
  }

  Future<void> _prefetchUntilScrollable() async {
    if (_prefetching || !hasMore.value) return;
    _prefetching = true;
    try {
      if (assets.length < _pageLimit && hasMore.value) {
        await _loadPage(_currentPage + 1, append: true);
      }
    } finally {
      _prefetching = false;
    }
  }

  void _applyPlayableFilter() {
    assets.assignAll(_allFetched.where((item) => item.isPlayableMedia));
    unawaited(_syncPlayerAssets());
  }

  Future<void> _syncPlayerAssets() async {
    _audioPlayer.setQueue(assets.toList());
    await _audioPlayer.setAssets(_audioAssets);
    await _videoPlayer.setAssets(_videoAssets);
  }

  Future<void> playAll() async {
    if (assets.isEmpty) return;
    await playAt(0);
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= assets.length) return;
    _audioPlayer.setQueue(assets.toList());
    final asset = assets[index];

    if (isCurrentAsset(asset)) {
      if (asset.isAudioMedia) {
        AppRoutes.toAudioPlayer();
      } else if (asset.isVideoMedia) {
        AppRoutes.toVideoPlayer();
      }
      return;
    }

    if (!await _audioPlayer.playQueueAt(index)) {
      if (asset.isAudioMedia) {
        AppSnackbar.error(AppLocales.audio.playbackFailed.tr);
      } else if (asset.isVideoMedia) {
        AppSnackbar.error(AppLocales.video.playbackFailed.tr);
      }
    }
  }
}
