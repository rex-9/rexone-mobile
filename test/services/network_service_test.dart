// test/services/network_service_test.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/design/components/app_network_banner.dart';
import 'package:rexone_mobile/locales/app_locales.dart';
import 'package:rexone_mobile/locales/app_translations.dart';
import 'package:rexone_mobile/services/network.service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NetworkService networkService;

  setUp(() {
    Get.reset();
    networkService = NetworkService(autoInit: false);
    Get.put<NetworkService>(networkService);
  });

  tearDown(() {
    networkService.reset();
    Get.reset();
  });

  group('NetworkService State Transitions', () {
    test('initial state defaults to online with hidden banner', () {
      expect(networkService.isOnline.value, true);
      expect(networkService.isBannerVisible.value, false);
      expect(networkService.isRestored.value, false);
    });

    test('handleInitialConnectivity with empty or none shows offline banner', () {
      networkService.handleInitialConnectivity([ConnectivityResult.none]);

      expect(networkService.isOnline.value, false);
      expect(networkService.isBannerVisible.value, true);
      expect(networkService.isRestored.value, false);
    });

    test('handleInitialConnectivity with wifi does not show restored banner', () {
      networkService.handleInitialConnectivity([ConnectivityResult.wifi]);

      expect(networkService.isOnline.value, true);
      expect(networkService.isBannerVisible.value, false);
      expect(networkService.isRestored.value, false);
    });

    test('handleConnectivityChange transitions to offline when connection lost', () {
      networkService.handleInitialConnectivity([ConnectivityResult.wifi]);

      networkService.handleConnectivityChange([ConnectivityResult.none]);

      expect(networkService.isOnline.value, false);
      expect(networkService.isBannerVisible.value, true);
      expect(networkService.isRestored.value, false);
    });

    test(
      'handleConnectivityChange transitions to restored for 3 seconds then auto-hides',
      () async {
        networkService.handleInitialConnectivity([ConnectivityResult.wifi]);

        // Go offline
        networkService.handleConnectivityChange([ConnectivityResult.none]);
        expect(networkService.isOnline.value, false);
        expect(networkService.isBannerVisible.value, true);

        // Reconnect
        networkService.handleConnectivityChange([ConnectivityResult.wifi]);
        expect(networkService.isOnline.value, true);
        expect(networkService.isRestored.value, true);
        expect(networkService.isBannerVisible.value, true);

        // Wait 3.1 seconds for auto-hide timer to fire
        await Future.delayed(const Duration(milliseconds: 3100));

        expect(networkService.isBannerVisible.value, false);
        expect(networkService.isRestored.value, false);
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test('simulateOffline and simulateOnline helpers correctly toggle state', () {
      networkService.simulateOffline();
      expect(networkService.isOnline.value, false);
      expect(networkService.isBannerVisible.value, true);
      expect(networkService.isRestored.value, false);

      networkService.simulateOnline();
      expect(networkService.isOnline.value, true);
      expect(networkService.isRestored.value, true);
      expect(networkService.isBannerVisible.value, true);
    });
  });

  group('AppNetworkBanner Widget Tests', () {
    testWidgets('renders child content normally', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: const AppNetworkBanner(
            child: Scaffold(
              body: Center(child: Text('App Content')),
            ),
          ),
        ),
      );

      expect(find.text('App Content'), findsOneWidget);
    });

    testWidgets('shows connection lost banner when offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: const AppNetworkBanner(
            child: Scaffold(
              body: Center(child: Text('App Content')),
            ),
          ),
        ),
      );

      // Trigger offline
      networkService.simulateOffline();
      await tester.pumpAndSettle();

      expect(find.text(AppLocales.common.connectionLost.tr), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('shows connection is safe and sound banner when restored', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: const AppNetworkBanner(
            child: Scaffold(
              body: Center(child: Text('App Content')),
            ),
          ),
        ),
      );

      // Trigger offline then restored
      networkService.simulateOffline();
      await tester.pumpAndSettle();

      networkService.simulateOnline();
      await tester.pumpAndSettle();

      expect(find.text('Connection is safe and sound'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_rounded), findsOneWidget);

      // Advance clock 3.5 seconds so auto-dismiss timer completes and banner hides
      await tester.pump(const Duration(milliseconds: 3500));
      await tester.pumpAndSettle();
      expect(networkService.isBannerVisible.value, false);
    });
  });
}
