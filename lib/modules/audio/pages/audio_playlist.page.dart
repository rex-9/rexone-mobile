import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../audio.dart';

class AudioPlaylistPage extends StatefulWidget {
  const AudioPlaylistPage({super.key});

  @override
  State<AudioPlaylistPage> createState() => _AudioPlaylistPageState();
}

class _AudioPlaylistPageState extends State<AudioPlaylistPage> {
  late final AudioPlaylistController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AudioPlaylistController>();
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
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = _controller.player;
    final headerSize = Design.spacing.xxxl * 4;
    final colors = context.colors;
    final typo = context.typo;

    return AppPage(
      title: AppLocales.audio.title.tr,
      showBackButton: true,
      padding: EdgeInsets.zero,
      child: Obx(() {
        if (_controller.isLoading.value && _controller.assets.isEmpty) {
          return Center(
            child: AppLoading(
              type: LoadingType.circular,
              color: colors.primary,
            ),
          );
        }

        if (_controller.assets.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _controller.fetchAssets(refresh: true),
            color: colors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(Design.spacing.screenPadding),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Design.icons.musicNote,
                        size: Design.spacing.xxxl * 2,
                        color: colors.textSecondary.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: Design.spacing.md),
                      Text(
                        AppLocales.audio.empty.tr,
                        textAlign: TextAlign.center,
                        style: typo.bodyLarge.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final assets = _controller.assets;
        final currentIndex = player.currentIndex.value;
        final playing = player.isPlaying.value;
        final heroAsset =
            player.currentAsset ?? (assets.isNotEmpty ? assets.first : null);
        final canPlay = assets.isNotEmpty && !player.isLoading.value;

        return RefreshIndicator(
          onRefresh: () => _controller.fetchAssets(refresh: true),
          color: colors.primary,
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(Design.spacing.screenPadding),
            children: [
              Center(
                child: TrackArtwork(
                  url: heroAsset?.displayThumbnailUrl ?? '',
                  size: headerSize,
                  radius: Design.spacing.radiusLarge,
                ),
              ),
              SizedBox(height: Design.spacing.xl),
              Text(
                AppLocales.audio.title.tr,
                textAlign: TextAlign.center,
                style: typo.headline3,
              ),
              SizedBox(height: Design.spacing.xs),
              Text(
                AppLocales.audio.playlistSubtitle.tr,
                textAlign: TextAlign.center,
                style: typo.bodyMedium,
              ),
              SizedBox(height: Design.spacing.xl),
              AppButton(
                type: EButtonType.primary,
                text: player.isLoading.value
                    ? AppLocales.common.loading.tr
                    : AppLocales.audio.playAll.tr,
                icon: player.isLoading.value ? null : Design.icons.play,
                onPressed: canPlay ? _controller.playAll : null,
                isExpanded: true,
              ),
              SizedBox(height: Design.spacing.xxl),
              ...List.generate(
                assets.length + (_controller.isLoadingMore.value ? 1 : 0),
                (index) {
                  if (index == assets.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Design.spacing.lg,
                      ),
                      child: Center(
                        child: AppLoading(
                          type: LoadingType.circular,
                          size: LoadingSize.small,
                          color: colors.primary,
                        ),
                      ),
                    );
                  }

                  final asset = assets[index];
                  final isCurrent =
                      currentIndex == index && player.hasSession.value;

                  return Padding(
                    padding: EdgeInsets.only(bottom: Design.spacing.sm),
                    child: AppListTile(
                      onTap: () => _controller.playAt(index),
                      leading: TrackArtwork(
                        url: asset.displayThumbnailUrl,
                        size: Design.spacing.xxxl + Design.spacing.lg,
                      ),
                      title: Text(
                        asset.displayTitle,
                        style: typo.bodyLarge.copyWith(
                          color: isCurrent
                              ? colors.primary
                              : colors.textPrimary,
                        ),
                      ),
                      subtitle: asset.displaySubtitle.isNotEmpty
                          ? Text(asset.displaySubtitle)
                          : null,
                      trailing: isCurrent
                          ? (player.isLoading.value
                                ? AppLoading(
                                    size: LoadingSize.small,
                                    color: colors.primary,
                                  )
                                : Icon(
                                    playing
                                        ? Design.icons.pause
                                        : Design.icons.play,
                                    color: colors.primary,
                                    size: Design.spacing.iconLarge,
                                  ))
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
