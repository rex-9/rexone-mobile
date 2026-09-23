import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/locales/locales.dart';

/// Inline 16:9 video surface powered by better_player.
class VideoPlayerViewport extends StatelessWidget {
  const VideoPlayerViewport({
    super.key,
    required this.size,
    required this.controller,
  });

  final Size size;
  final BetterPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
          child: ColoredBox(
            color: Colors.black,
            child: controller == null
                ? Center(child: AppLoading(color: colors.primary))
                : Localizations.override(
                    context: context,
                    delegates: AppLocalizations.delegates,
                    child: BetterPlayer(controller: controller!),
                  ),
          ),
        ),
      ),
    );
  }
}
