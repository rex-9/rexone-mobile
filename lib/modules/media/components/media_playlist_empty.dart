import 'package:flutter/material.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

/// Empty playlist body for pull-to-refresh lists.
class MediaPlaylistEmpty extends StatelessWidget {
  const MediaPlaylistEmpty({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Design.spacing.padding(Design.spacing.screenPadding),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height *
              MediaLayoutConstants.playlistEmptyTopFraction,
        ),
        Center(
          child: Column(
            children: [
              Icon(
                icon,
                size: Design.spacing.xxxl * 2,
                color: colors.textSecondary.withValues(alpha: 0.3),
              ),
              SizedBox(height: Design.spacing.md),
              Text(
                message,
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
    );
  }
}
