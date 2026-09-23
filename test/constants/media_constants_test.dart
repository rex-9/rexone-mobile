import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'APP_NAME=RexOne\n');
  });
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

    test('video cache and buffering constants have optimal streaming defaults', () {
      expect(MediaPlaybackConstants.videoMaxCacheSizeBytes, equals(100 * 1024 * 1024));
      expect(MediaPlaybackConstants.videoMaxCacheFileSizeBytes, equals(20 * 1024 * 1024));
      expect(MediaPlaybackConstants.videoMinBufferMs, equals(15000));
      expect(MediaPlaybackConstants.videoMaxBufferMs, equals(60000));
      expect(MediaPlaybackConstants.videoBufferForPlaybackMs, equals(2000));
      expect(MediaPlaybackConstants.videoBufferForPlaybackAfterRebufferMs, equals(4000));
    });
  });

  group('MediaDownloadConstants', () {
    test('plaintext directory name is derived cleanly from app name', () {
      expect(MediaDownloadConstants.plaintextRootDirName, isNotEmpty);
      expect(
        MediaDownloadConstants.plaintextRootDirName,
        isNot(contains('hysanejunior')),
      );
    });

    test('constants have valid defaults and extensions', () {
      expect(MediaDownloadConstants.encryptedExtension, equals('enc'));
      expect(MediaDownloadConstants.defaultState, equals('none'));
      expect(MediaDownloadConstants.maxConcurrentDownloads, equals(2));
    });
  });
}
