import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/modules/home/home.dart';
import 'package:rexone_mobile/services/storage.service.dart';
import 'package:rexone_mobile/services/version.service.dart';
import '../../../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVersionService fakeVersion;
  late FakeStorageService fakeStorage;
  late HomeController controller;

  setUpAll(() async {
    PackageInfo.setMockInitialValues(
      appName: 'RexOne',
      packageName: 'com.rex9.rexone',
      version: '1.4.0',
      buildNumber: '42',
      buildSignature: '',
    );
    await AppInfo.init();
  });

  setUp(() {
    Get.testMode = true;
    fakeVersion = FakeVersionService();
    fakeStorage = FakeStorageService();
    Get.put<VersionService>(fakeVersion);
    Get.put<StorageService>(fakeStorage);
    controller = Get.put(HomeController());
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController', () {
    test(
      'reportUserVersion posts installed version and build number',
      () async {
        await controller.reportUserVersion();

        expect(fakeVersion.lastReportedVersion, equals('1.4.0'));
        expect(fakeVersion.lastReportedBuildNumber, equals(42));
      },
    );

    test('reportUserVersion does not throw when the request fails', () async {
      fakeVersion.throwOnReport = true;

      await controller.reportUserVersion();

      expect(fakeVersion.lastReportedVersion, equals('1.4.0'));
    });
  });
}
