import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/helpers/video_layout.helper.dart';

void main() {
  group('VideoLayoutHelper.inlineVideoSize', () {
    test('returns 16:9 size within constraints', () {
      const constraints = BoxConstraints(maxWidth: 400, maxHeight: 800);
      final size = VideoLayoutHelper.inlineVideoSize(constraints);

      expect(size.width, 400);
      expect(size.height, 225);
    });

    test('respects min viewport height when vertical space is tight', () {
      const constraints = BoxConstraints(maxWidth: 320, maxHeight: 250);
      final size = VideoLayoutHelper.inlineVideoSize(constraints);

      expect(size.height, 120);
      expect(size.width / size.height, closeTo(16 / 9, 0.01));
    });
  });
}
