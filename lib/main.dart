// lib/main.dart
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';
import 'bindings/initial.binding.dart';
import 'locales/app_translations.dart';
import 'modules/audio/components/app_mini_player_host.dart';
import 'modules/setting/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Telemetry & Error Listeners ("It works on my machine" killer)
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.presentError(details);
    }
    LogService.reportFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    LogService.reportPlatformError(error, stack);
    return true;
  };

  await dotenv.load(fileName: AppConfig.appEnv);
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('⚠️ Firebase initializeApp skipped or failed: $e');
  }
  await GetStorage.init();
  await JustAudioBackground.init(
    androidNotificationChannelId: '${AppConfig.androidAppId}.audio',
    androidNotificationChannelName: AppConfig.appName,
    androidNotificationOngoing: true,
  );
  InitialBinding().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<AnalyticsService>();

    // DEBUG: Test ENV...
    // print('APP_NAME: ${AppConfig.appName}');
    // print('APP_VERSION: ${AppConfig.appVersion}');
    // print('API_BASE_URL: ${AppConfig.apiBaseUrl}');
    // print('GOOGLE_CLIENT_ID: ${AppConfig.googleServerClientId}');
    // print('ONE_SIGNAL_APP_ID: ${AppConfig.oneSignalAppId}');
    // print('APP_STORE_APP_ID: ${AppConfig.appStoreAppId}');
    // print('APP_STORE_BUNDLE_ID: ${AppConfig.appStoreBundleId}');

    return GetBuilder<SettingController>(
      builder: (settings) => ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => GetMaterialApp(
          title: AppConfig.appName,
          theme: Design.theme.light,
          darkTheme: Design.theme.dark,
          themeMode: settings.themeMode,
          translations: AppTranslations(),
          locale: settings.locale,
          fallbackLocale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.pages,
          unknownRoute: AppRoutes.notFound,
          navigatorObservers: [analytics.observer, MiniPlayerRouteObserver()],
          builder: (context, child) {
            return AppNetworkBanner(
              child: AppMiniPlayerHost(
                child: AppLoading.builder(context, child),
              ),
            );
          },
        ),
      ),
    );
  }
}
