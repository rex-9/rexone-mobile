import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/app.routes.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/media_download.service.dart';

import '../media.dart';

/// Paginated mixed audio/video playlist from `GET /v1/assets` (no type filter).
class MediaPlaylistController extends GetxController {
  late final MediaService _media;
  late final MediaDownloadService _downloads;

  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final Rxn<PaginationMeta> pagination = Rxn<PaginationMeta>();

  static const int _pageLimit = MediaLayoutConstants.playlistPageLimit;
  static const int _maxPrefetchPages = 5;
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
    fetchAssets(refresh: true);
  }

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
      case EMediaDownloadState.queued:
      case EMediaDownloadState.downloading:
      case EMediaDownloadState.processing:
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

  Future<void> _removeDownload(AssetModel asset) async {
    try {
      await _downloads.deleteDownload(asset.id);
    } catch (error) {
      debugPrint('❌ [MediaPlaylistController] Remove download error: $error');
      AppSnackbar.error(AppLocales.media.downloadFailed.tr);
    }
  }

  Future<void> _cancelDownload(AssetModel asset) async {
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

    isLoading.value = true;
    try {
      if (refresh) {
        _allFetched.clear();
      }
      await _loadPage(1, append: false);
      await _prefetchUntilScrollable();
    } catch (e) {
      debugPrint('❌ [MediaPlaylistController] Fetch error: $e');
    } finally {
      isLoading.value = false;
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
      AppSnackbar.error(res.message);
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
    if (_prefetching) return;
    _prefetching = true;
    try {
      var attempts = 0;
      while (hasMore.value &&
          assets.length < _pageLimit &&
          attempts < _maxPrefetchPages) {
        attempts++;
        final previousCount = assets.length;
        final nextPage = _currentPage + 1;
        await _loadPage(nextPage, append: true);
        if (assets.length == previousCount) break;
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
