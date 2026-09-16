import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/services/media_download.service.dart';

import '../../components/media_asset_tile.dart';
import '../../controllers/playlist.controller.dart';

/// Scrollable asset list shown below the inline video player.
class VideoPlaylistPanel extends StatelessWidget {
  const VideoPlaylistPanel({
    super.key,
    required this.assets,
    required this.currentIndex,
    required this.hasSession,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlayAt,
  });

  final List<AssetModel> assets;
  final int currentIndex;
  final bool hasSession;
  final bool isPlaying;
  final bool isLoading;
  final ValueChanged<int> onPlayAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocales.video.playlistSubtitle.tr,
          style: typo.labelLarge.copyWith(color: colors.textSecondary),
        ),
        SizedBox(height: Design.spacing.sm),
        Expanded(
          child: assets.isEmpty
              ? Center(
                  child: Text(
                    AppLocales.video.empty.tr,
                    style: typo.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
              : Obx(() {
                  final downloads = Get.find<MediaDownloadService>();
                  downloads.entries.length;

                  final playlist = Get.isRegistered<MediaPlaylistController>()
                      ? Get.find<MediaPlaylistController>()
                      : null;

                  return ListView.separated(
                    itemCount: assets.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: Design.spacing.sm),
                    itemBuilder: (context, index) {
                      final item = assets[index];
                      final isCurrent =
                          currentIndex == index && hasSession;
                      final downloadState = playlist != null
                          ? playlist.downloadStateFor(item)
                          : downloads.stateFor(item.id);
                      final downloadProgress = playlist != null
                          ? playlist.downloadProgressFor(item)
                          : downloads.progressFor(item.id);

                      return MediaAssetTile(
                        asset: item,
                        isCurrent: isCurrent,
                        isPlaying: isPlaying,
                        isLoading: isLoading,
                        showLoadingTrailing: false,
                        downloadState: downloadState,
                        downloadProgress: downloadProgress,
                        onDownloadTap: playlist == null
                            ? () {}
                            : () => playlist.onDownloadTap(item),
                        onTap: () => onPlayAt(index),
                      );
                    },
                  );
                }),
        ),
      ],
    );
  }
}
