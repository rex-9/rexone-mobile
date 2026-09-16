import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/services/services.dart';

import '../media.dart';

class MediaPlaylistPage extends StatefulWidget {
  const MediaPlaylistPage({super.key});

  @override
  State<MediaPlaylistPage> createState() => _MediaPlaylistPageState();
}

class _MediaPlaylistPageState extends State<MediaPlaylistPage> {
  late final MediaPlaylistController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MediaPlaylistController>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            MediaLayoutConstants.playlistScrollPrefetchPx) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppLocales.media.playlistTitle.tr,
      showBackButton: true,
      padding: Design.spacing.zero,
      child: Obx(() {
        final audio = Get.find<AudioPlayerService>();
        final video = Get.find<VideoPlayerService>();
        final downloads = Get.find<MediaDownloadService>();

        // Playlist + players + download index drive tile state.
        _controller.assets.length;
        _controller.isLoading.value;
        _controller.isLoadingMore.value;
        _controller.hasMore.value;
        audio.currentIndex.value;
        audio.isPlaying.value;
        audio.isLoading.value;
        audio.hasSession.value;
        video.currentIndex.value;
        video.isPlaying.value;
        video.isLoading.value;
        video.hasSession.value;
        downloads.entries.length;

        return _buildBody(context);
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.colors;
    final assets = _controller.assets;
    final hero = _controller.heroAsset;
    final headerLoading = assets.any(_controller.isLoadingAsset);

    if (_controller.isLoading.value && assets.isEmpty) {
      return Center(
        child: AppLoading(
          type: LoadingType.circular,
          color: colors.primary,
        ),
      );
    }

    if (assets.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _controller.fetchAssets(refresh: true),
        color: colors.primary,
        child: MediaPlaylistEmpty(
          icon: Design.icons.playlist,
          message: AppLocales.media.playlistEmpty.tr,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _controller.fetchAssets(refresh: true),
      color: colors.primary,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: Design.spacing.padding(Design.spacing.screenPadding),
        children: [
          MediaPlaylistHeader(
            thumbnailUrl: hero?.displayThumbnailUrl ?? '',
            title: AppLocales.media.playlistTitle.tr,
            subtitle: AppLocales.media.playlistSubtitle.tr,
            playAllLabel: headerLoading
                ? AppLocales.common.loading.tr
                : AppLocales.media.playAll.tr,
            canPlay: assets.isNotEmpty && !headerLoading,
            isPlayAllLoading: headerLoading,
            onPlayAll: _controller.playAll,
          ),
          ...List.generate(
            assets.length + (_controller.isLoadingMore.value ? 1 : 0),
            (index) {
              if (index == assets.length) {
                return const MediaPlaylistLoadMore();
              }

              final asset = assets[index];
              final isCurrent = _controller.isCurrentAsset(asset);
              final isPlaying = _controller.isPlayingAsset(asset);
              final isLoading = _controller.isLoadingAsset(asset);
              final downloadState = _controller.downloadStateFor(asset);
              final downloadProgress = _controller.downloadProgressFor(asset);

              return Padding(
                padding: Design.spacing.paddingOnly(b: Design.spacing.sm),
                child: MediaAssetTile(
                  asset: asset,
                  isCurrent: isCurrent,
                  isPlaying: isPlaying,
                  isLoading: isLoading,
                  showLoadingTrailing: asset.isAudioMedia,
                  downloadState: downloadState,
                  downloadProgress: downloadProgress,
                  onDownloadTap: () => _controller.onDownloadTap(asset),
                  onTap: () => _controller.playAt(index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
