// test/modules/splash/controllers/splash_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/modules/splash/splash.dart';
import 'package:rexone_mobile/routes/app.routes.dart';
import 'package:rexone_mobile/services/analytics.service.dart';
import 'package:rexone_mobile/services/version.service.dart';
import 'package:rexone_mobile/services/push_noti.service.dart';
import 'package:rexone_mobile/services/socket.service.dart';
import 'package:rexone_mobile/services/storage.service.dart';
import '../../../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVersionService fakeVersion;
  late FakeStorageService fakeStorage;
  late SplashController controller;

  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'RexOne',
      packageName: 'com.rexone.mobile',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  setUp(() {
    Get.testMode = true;
    fakeVersion = FakeVersionService();
    fakeStorage = FakeStorageService();

    Get.put<VersionService>(fakeVersion);
    Get.put<StorageService>(fakeStorage);
    Get.put<AuthService>(FakeAuthService());
    Get.put<AnalyticsService>(FakeAnalyticsService());
    Get.put<PushNotiService>(FakePushNotiService());
    Get.put<SocketService>(FakeSocketService());

    Get.put(AuthController());
    controller = Get.put(SplashController());
  });

  tearDown(() {
    Get.reset();
  });

  VersionModel version({
    bool updateRequired = false,
    bool mustUpdate = false,
    bool skipPremium = false,
  }) {
    return VersionModel(
      id: 'av1',
      number: '2.0.0',
      updateRequired: updateRequired,
      mustUpdate: mustUpdate,
      skipPremium: skipPremium,
    );
  }

  group('SplashController', () {
    test('checkAppVersion stores latest version and skip_premium', () async {
      fakeVersion.currentResponse = ApiResponse.success(
        message: 'OK',
        statusCode: 200,
        data: version(skipPremium: true),
      );

      await controller.checkAppVersion();

      expect(fakeVersion.lastRequestedVersion, equals('1.0.0'));
      expect(controller.latestVersion.value?.number, equals('2.0.0'));
      expect(fakeStorage.getSkipPremium(), isTrue);
    });

    test('checkAppVersion writes skip_premium false when Core returns false', () async {
      fakeStorage.setSkipPremium(true);
      fakeVersion.currentResponse = ApiResponse.success(
        message: 'OK',
        statusCode: 200,
        data: version(skipPremium: false),
      );

      await controller.checkAppVersion();

      expect(fakeStorage.getSkipPremium(), isFalse);
    });

    test('checkAppVersion keeps stored skip_premium when the request fails', () async {
      fakeStorage.setSkipPremium(true);
      fakeVersion.throwOnGet = true;

      await controller.checkAppVersion();

      expect(controller.latestVersion.value, isNull);
      expect(fakeStorage.getSkipPremium(), isTrue);
    });

    test('checkAppVersion does not store version when the API has no data', () async {
      fakeVersion.currentResponse = ApiResponse.error(
        message: 'Unavailable',
        statusCode: 500,
      );

      await controller.checkAppVersion();

      expect(controller.latestVersion.value, isNull);
      expect(fakeStorage.getSkipPremium(), isFalse);
    });

    test('promptUpdateIfNeeded is a no-op without a widget context', () async {
      controller.latestVersion.value = version(updateRequired: true, mustUpdate: true);

      await controller.promptUpdateIfNeeded();

      expect(controller.latestVersion.value?.updateRequired, isTrue);
    });

    test('navigate clears the route stack for logged-out users', () async {
      fakeStorage.saveRouteStack([AppRoutes.home, AppRoutes.settings]);

      await controller.navigate();

      expect(fakeStorage.getRouteStack(), isEmpty);
    });
  });
}
