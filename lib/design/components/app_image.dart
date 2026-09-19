// lib/design/components/app_image.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import '../elements/app_media.dart';

class AppImage extends StatelessWidget {
  final String? url;
  final String? asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallback;

  const AppImage({
    super.key,
    this.url,
    this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
  });

  const AppImage.asset(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
  }) : url = null;

  const AppImage.network(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
  }) : asset = null;

  @override
  Widget build(BuildContext context) {
    const media = AppMedia();

    Widget imageWidget;
    final effectiveAsset = asset ?? (url != null && url!.startsWith('assets/') ? url : null);

    if (effectiveAsset != null && effectiveAsset.trim().isNotEmpty) {
      imageWidget = Image.asset(
        effectiveAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return fallback ??
              Image.asset(
                media.error,
                width: width,
                height: height,
                fit: fit,
              );
        },
      );
    } else if (url == null || url!.trim().isEmpty) {
      imageWidget = fallback ??
          Image.asset(
            media.error,
            width: width,
            height: height,
            fit: fit,
          );
    } else if (url!.startsWith('file://') || url!.startsWith('/')) {
      final path = url!.startsWith('file://')
          ? Uri.parse(url!).toFilePath()
          : url!;
      imageWidget = Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return fallback ??
              Image.asset(
                media.error,
                width: width,
                height: height,
                fit: fit,
              );
        },
      );
    } else {
      final headers = UrlHelper.headersFor(url!);
      imageWidget = Image.network(
        url!,
        headers: headers.isEmpty ? null : headers,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Image.asset(
            media.loading,
            width: width,
            height: height,
            fit: fit,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return fallback ??
              Image.asset(
                media.error,
                width: width,
                height: height,
                fit: fit,
              );
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
