import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

import 'video_sheet_header.dart';

/// Scrollable speed list inside the settings sheet.
class VideoSettingsSpeedPanel extends StatelessWidget {
  const VideoSettingsSpeedPanel({
    super.key,
    required this.title,
    required this.onBack,
    required this.children,
  });

  final String title;
  final VoidCallback onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VideoSheetHeader(title: title, onBack: onBack),
        Expanded(
          child: ListView(
            padding: Design.spacing.zero,
            children: children,
          ),
        ),
      ],
    );
  }
}
