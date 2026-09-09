import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../audio.dart';

class AudioPlaylistPage extends GetView<AudioPlaylistController> {
  const AudioPlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    final headerSize = Design.spacing.xxxl * 4;

    return AppPage(
      title: AppLocales.audio.title.tr,
      showBackButton: true,
      padding: EdgeInsets.zero,
      child: Obx(() {
        final tracks = controller.tracks;
        final currentIndex = player.currentIndex.value;
        final playing = player.isPlaying.value;

        return ListView(
          padding: EdgeInsets.all(Design.spacing.screenPadding),
          children: [
            Center(
              child: TrackArtwork(
                url: tracks.isNotEmpty ? tracks.first.artworkUrl : '',
                size: headerSize,
                radius: Design.spacing.radiusLarge,
              ),
            ),
            SizedBox(height: Design.spacing.xl),
            Text(
              AppLocales.audio.title.tr,
              textAlign: TextAlign.center,
              style: context.typo.headline3,
            ),
            SizedBox(height: Design.spacing.xs),
            Text(
              AppLocales.audio.playlistSubtitle.tr,
              textAlign: TextAlign.center,
              style: context.typo.bodyMedium,
            ),
            SizedBox(height: Design.spacing.xl),
            AppButton(
              type: EButtonType.primary,
              text: player.isLoading.value
                  ? AppLocales.common.loading.tr
                  : AppLocales.audio.playAll.tr,
              icon: player.isLoading.value ? null : Design.icons.play,
              onPressed: player.isLoading.value ? null : controller.playAll,
              isExpanded: true,
            ),
            SizedBox(height: Design.spacing.xxl),
            ...List.generate(tracks.length, (index) {
              final track = tracks[index];
              final isCurrent = currentIndex == index && player.hasSession.value;

              return Padding(
                padding: EdgeInsets.only(bottom: Design.spacing.sm),
                child: AppListTile(
                  onTap: () => controller.playAt(index),
                  leading: TrackArtwork(
                    url: track.artworkUrl,
                    size: Design.spacing.xxxl + Design.spacing.lg,
                  ),
                  title: Text(
                    track.title,
                    style: context.typo.bodyLarge.copyWith(
                      color: isCurrent
                          ? context.colors.primary
                          : context.colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(track.artist),
                  trailing: isCurrent
                      ? (player.isLoading.value
                            ? AppLoading(
                                size: LoadingSize.small,
                                color: context.colors.primary,
                              )
                            : Icon(
                                playing
                                    ? Design.icons.pause
                                    : Design.icons.play,
                                color: context.colors.primary,
                                size: Design.spacing.iconLarge,
                              ))
                      : null,
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
