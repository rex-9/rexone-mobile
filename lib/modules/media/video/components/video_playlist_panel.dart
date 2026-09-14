import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/models/models.dart';

import '../../components/media_asset_tile.dart';

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
              : ListView.separated(
                  itemCount: assets.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: Design.spacing.sm),
                  itemBuilder: (context, index) {
                    final item = assets[index];
                    final isCurrent =
                        currentIndex == index && hasSession;

                    return MediaAssetTile(
                      asset: item,
                      isCurrent: isCurrent,
                      isPlaying: isPlaying,
                      isLoading: isLoading,
                      showLoadingTrailing: false,
                      onTap: () => onPlayAt(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
