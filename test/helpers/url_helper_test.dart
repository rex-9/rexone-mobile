import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/url.helper.dart';

void main() {
  setUp(() {
    dotenv.clean();
  });

  group('UrlHelper.normalize', () {
    test('normalizes localhost to 10.0.2.2 on Android', () {
      const url = 'http://localhost:3100/rexone/dev/video.mp4?token=abc';
      final result = UrlHelper.normalize(url, isAndroid: true);
      expect(result, 'http://10.0.2.2:3100/rexone/dev/video.mp4?token=abc');
    });

    test('normalizes 127.0.0.1 to 10.0.2.2 on Android', () {
      const url = 'http://127.0.0.1:3000/api/v1/assets';
      final result = UrlHelper.normalize(url, isAndroid: true);
      expect(result, 'http://10.0.2.2:3000/api/v1/assets');
    });

    test('normalizes 10.0.2.2 to localhost when not on Android (iOS/macOS)', () {
      const url = 'http://10.0.2.2:3000/api/v1/auth/login';
      final result = UrlHelper.normalize(url, isAndroid: false);
      expect(result, 'http://localhost:3000/api/v1/auth/login');
    });

    test('preserves localhost when not on Android', () {
      const url = 'http://localhost:3100/rexone/dev/video.mp4';
      final result = UrlHelper.normalize(url, isAndroid: false);
      expect(result, url);
    });

    test('preserves 10.0.2.2 on Android', () {
      const url = 'http://10.0.2.2:3000/api/v1/auth/login';
      final result = UrlHelper.normalize(url, isAndroid: true);
      expect(result, url);
    });

    test('preserves non-localhost remote URLs on Android', () {
      const url = 'https://s3.amazonaws.com/bucket/video.mp4?token=xyz';
      final result = UrlHelper.normalize(url, isAndroid: true);
      expect(result, url);
    });

    test('preserves non-localhost remote URLs on iOS/macOS', () {
      const url = 'https://api.rexone.com/api/v1/auth/login';
      final result = UrlHelper.normalize(url, isAndroid: false);
      expect(result, url);
    });

    test('preserves file:// URIs on Android', () {
      const url = 'file:///data/user/0/com.rexone.mobile/files/video.mp4';
      final result = UrlHelper.normalize(url, isAndroid: true);
      expect(result, url);
    });

    test('handles empty or malformed strings gracefully', () {
      expect(UrlHelper.normalize('', isAndroid: true), '');
      expect(UrlHelper.normalize('not-a-url', isAndroid: true), 'not-a-url');
    });

    test('uses host from apiBaseUrl when configured and not localhost', () {
      dotenv.loadFromString(
        envString: 'API_BASE_URL=http://192.168.1.100:3000\n',
      );
      const url = 'http://localhost:3100/rexone/dev/video.mp4';
      final result = UrlHelper.normalize(url, isAndroid: true);
      expect(result, 'http://192.168.1.100:3100/rexone/dev/video.mp4');
    });
  });

  group('UrlHelper.normalizeBaseUrl', () {
    test('resolves 10.0.2.2 to localhost on iOS simulator', () {
      expect(
        UrlHelper.normalizeBaseUrl('http://10.0.2.2:3000', isAndroid: false),
        'http://localhost:3000',
      );
    });

    test('resolves localhost to 10.0.2.2 on Android emulator', () {
      expect(
        UrlHelper.normalizeBaseUrl('http://localhost:3000', isAndroid: true),
        'http://10.0.2.2:3000',
      );
    });

    test('resolves 127.0.0.1 to 10.0.2.2 on Android emulator', () {
      expect(
        UrlHelper.normalizeBaseUrl('http://127.0.0.1:3000', isAndroid: true),
        'http://10.0.2.2:3000',
      );
    });

    test('leaves production domains untouched on both platforms', () {
      const prodUrl = 'https://api.rexone.com';
      expect(
        UrlHelper.normalizeBaseUrl(prodUrl, isAndroid: true),
        prodUrl,
      );
      expect(
        UrlHelper.normalizeBaseUrl(prodUrl, isAndroid: false),
        prodUrl,
      );
    });
  });

  group('UrlHelper.normalizeNullable', () {
    test('returns null when input is null', () {
      expect(UrlHelper.normalizeNullable(null, isAndroid: true), isNull);
    });

    test('normalizes when input is non-null', () {
      const url = 'http://localhost:3100/audio.mp3';
      expect(
        UrlHelper.normalizeNullable(url, isAndroid: true),
        'http://10.0.2.2:3100/audio.mp3',
      );
    });
  });

  group('UrlHelper.headersFor', () {
    test('returns empty map for non-Android platform', () {
      const url = 'http://10.0.2.2:3100/rexone/dev/video.mp4';
      expect(UrlHelper.headersFor(url, isAndroid: false), isEmpty);
    });

    test('returns Host: localhost:3100 for 10.0.2.2:3100 on Android', () {
      const url = 'http://10.0.2.2:3100/rexone/dev/video.mp4';
      expect(
        UrlHelper.headersFor(url, isAndroid: true),
        {'Host': 'localhost:3100'},
      );
    });

    test('returns Host: localhost:3100 for 127.0.0.1:3100 on Android', () {
      const url = 'http://127.0.0.1:3100/rexone/dev/video.mp4';
      expect(
        UrlHelper.headersFor(url, isAndroid: true),
        {AuthHeaders.host: 'localhost:3100'},
      );
    });

    test('returns Host: localhost:3100 for presigned Garage URL with X-Amz-Signature on Android', () {
      const url =
          'http://10.0.2.2:3100/rexone/dev/video.mp4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=abc123';
      expect(
        UrlHelper.headersFor(url, isAndroid: true),
        {AuthHeaders.host: 'localhost:3100'},
      );
    });

    test('returns empty map for external cloud host on Android', () {
      const url = 'https://s3.amazonaws.com/bucket/video.mp4';
      expect(UrlHelper.headersFor(url, isAndroid: true), isEmpty);
    });
  });
}
