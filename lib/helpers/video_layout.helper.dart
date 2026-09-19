// lib/helpers/video_layout.helper.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rexone_mobile/constants/constants.dart';

class VideoLayoutHelper {
  const VideoLayoutHelper._();

  /// Keeps 16:9 video within the page after fullscreen/orientation changes.
  static Size inlineVideoSize(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth;
    final maxHeight = math.max(
      MediaLayoutConstants.videoMinViewportHeight,
      constraints.maxHeight -
          MediaLayoutConstants.videoMetadataReserveHeight,
    );
    final aspectHeight = maxWidth *
        MediaLayoutConstants.videoAspectHeight /
        MediaLayoutConstants.videoAspectWidth;
    final height = math.min(aspectHeight, maxHeight);
    final width = math.min(
      maxWidth,
      height *
          MediaLayoutConstants.videoAspectWidth /
          MediaLayoutConstants.videoAspectHeight,
    );
    return Size(width, height);
  }
}
