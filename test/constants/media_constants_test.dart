// test/constants/media_constants_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';

void main() {
  group('MediaLayoutConstants', () {
    test('playlist pagination uses a positive page limit', () {
      expect(MediaLayoutConstants.playlistPageLimit, greaterThan(0));
    });

    test('video sheet max height is a fractional viewport cap', () {
      expect(MediaLayoutConstants.videoSheetMaxHeightFraction, inInclusiveRange(0.0, 1.0));
    });
  });

  group('MediaPlaybackConstants', () {
    test('video speed steps include normal playback', () {
      expect(MediaPlaybackConstants.videoSpeedSteps, contains(1.0));
    });

    test('lyrics error codes are stable string tokens', () {
      expect(MediaPlaybackConstants.lyricsErrorFetchFailed, isNotEmpty);
      expect(MediaPlaybackConstants.lyricsErrorEmpty, isNotEmpty);
      expect(
        MediaPlaybackConstants.lyricsErrorFetchFailed,
        isNot(MediaPlaybackConstants.lyricsErrorEmpty),
      );
    });
  });
}
