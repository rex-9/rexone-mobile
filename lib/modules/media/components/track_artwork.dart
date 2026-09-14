import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

class TrackArtwork extends StatelessWidget {
  const TrackArtwork({
    super.key,
    required this.url,
    required this.size,
    this.radius,
  });

  final String url;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      radius ?? Design.spacing.radiusSmall,
    );
    return AppImage.network(
      url,
      width: size,
      height: size,
      borderRadius: borderRadius,
      fallback: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: borderRadius,
        ),
        child: Icon(
          Design.icons.musicNote,
          size: Design.spacing.iconLarge,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
