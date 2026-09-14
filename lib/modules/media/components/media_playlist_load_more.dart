import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

/// Footer spinner while the next playlist page is loading.
class MediaPlaylistLoadMore extends StatelessWidget {
  const MediaPlaylistLoadMore({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Design.spacing.paddingSymmetric(v: Design.spacing.lg),
      child: Center(
        child: AppLoading(
          type: LoadingType.circular,
          size: LoadingSize.small,
          color: context.colors.primary,
        ),
      ),
    );
  }
}
