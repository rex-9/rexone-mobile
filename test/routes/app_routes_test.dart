// test/routes/app_routes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';
import '../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeStorageService fakeStorage;

  setUp(() {
    Get.testMode = true;
    fakeStorage = FakeStorageService();
    Get.put<StorageService>(fakeStorage);
  });

  tearDown(() {
    Get.reset();
  });

  group('AppRoutes.navigateContinueURL', () {
    test('falls back to home when continue route is empty or null', () {
      AppRoutes.navigateContinueURL(fakeStorage);

      expect(fakeStorage.getRouteStack(), equals([AppRoutes.home]));
      expect(fakeStorage.getContinueRoute(), isNull);
    });

    test('falls back to home when continue route is auth route', () {
      fakeStorage.setContinueRoute(AppRoutes.auth);

      AppRoutes.navigateContinueURL(fakeStorage);

      expect(fakeStorage.getRouteStack(), equals([AppRoutes.home]));
      expect(fakeStorage.getContinueRoute(), isNull);
    });

    test('falls back to home when continue route is home itself', () {
      fakeStorage.setContinueRoute(AppRoutes.home);

      AppRoutes.navigateContinueURL(fakeStorage);

      expect(fakeStorage.getRouteStack(), equals([AppRoutes.home]));
      expect(fakeStorage.getContinueRoute(), isNull);
    });

    test('preserves home as stack base and consumes valid continue route', () {
      fakeStorage.setContinueRoute(AppRoutes.ai);

      AppRoutes.navigateContinueURL(fakeStorage);

      expect(
        fakeStorage.getRouteStack(),
        equals([AppRoutes.home, AppRoutes.ai]),
      );
      expect(fakeStorage.getContinueRoute(), isNull);
    });
  });

  group('AppRoutes.resolveNotificationRoute (Deep Linking)', () {
    test('resolves relative routes correctly', () {
      expect(AppRoutes.resolveNotificationRoute('/ai'), equals(AppRoutes.ai));
      expect(
        AppRoutes.resolveNotificationRoute('/payment'),
        equals(AppRoutes.payment),
      );
      expect(
        AppRoutes.resolveNotificationRoute('/profile'),
        equals(AppRoutes.profile),
      );
      expect(
        AppRoutes.resolveNotificationRoute('/notifications'),
        equals(AppRoutes.notifications),
      );
    });

    test('resolves custom app scheme correctly', () {
      final scheme = NotificationConstants.appUrlScheme;
      expect(
        AppRoutes.resolveNotificationRoute('$scheme://ai'),
        equals(AppRoutes.ai),
      );
      expect(
        AppRoutes.resolveNotificationRoute('$scheme:///ai'),
        equals(AppRoutes.ai),
      );
      expect(
        AppRoutes.resolveNotificationRoute('$scheme://ai?prompt=test'),
        equals('${AppRoutes.ai}?prompt=test'),
      );
      expect(
        AppRoutes.resolveNotificationRoute('$scheme://payment'),
        equals(AppRoutes.payment),
      );
      expect(
        AppRoutes.resolveNotificationRoute('$scheme://profile'),
        equals(AppRoutes.profile),
      );
      expect(
        AppRoutes.resolveNotificationRoute('$scheme://settings'),
        equals(AppRoutes.settings),
      );
    });

    test('rejects unrecognized schemes or invalid routes', () {
      final scheme = NotificationConstants.appUrlScheme;
      expect(AppRoutes.resolveNotificationRoute('https://evil.com'), isNull);
      expect(AppRoutes.resolveNotificationRoute('invalid_${scheme}://ai'), isNull);
      expect(AppRoutes.resolveNotificationRoute('custom://ai'), isNull);
      expect(
        AppRoutes.resolveNotificationRoute('$scheme://unknown_route'),
        equals(AppRoutes.home),
      );
      expect(AppRoutes.resolveNotificationRoute(''), isNull);
      expect(AppRoutes.resolveNotificationRoute(null), isNull);
    });
  });
}
