// lib/routes/app_routes.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/components/app_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rexone_mobile/routes/guard.routes.dart';
import 'package:rexone_mobile/routes/server.routes.dart';
import 'package:rexone_mobile/services/storage.service.dart';

import '../modules/ai/ai.dart';
import '../modules/auth/auth.dart';
import '../modules/home/home.dart';
import '../modules/payment/payment.dart';
import '../modules/profile/profile.dart';
import '../modules/setting/setting.dart';
import '../modules/notification/notification.dart';
import '../modules/splash/splash.dart';
import '../modules/media/media.dart';

class AppRoutes {
  // ===== SERVER ROUTES =====
  static const server = ServerRoutes;

  // ===== PUBLIC ROUTES (No Auth Required) =====
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String signinPassword = '/signin-password';
  static const String signupPasswordCreate = '/signup-password-create';
  static const String signupPasswordConfirm = '/signup-password-confirm';
  static const String signupInfo = '/signup-info';
  static const String confirmEmail = '/confirm-email';
  static const String forgotPassword = '/forgot-password';

  // ===== PROTECTED ROUTES (Auth Required) =====
  static const String home = '/home';
  static const String settings = '/settings';
  static const String payment = '/payment';
  static const String checkout = '/checkout';
  static const String ai = '/ai';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String mediaPlaylist = '/media-playlist';
  static const String audioPlayer = '/audio-player';
  static const String videoPlayer = '/video-player';

  // ===== PUBLIC NAVIGATION =====
  static void toSplash() => Get.offAllNamed(splash);
  static void toAuth() => Get.offAllNamed(auth);
  static void toSignInPassword() => Get.toNamed(signinPassword);
  static void toSignUpPasswordCreate() => Get.toNamed(signupPasswordCreate);
  static void toSignUpPasswordConfirm() => Get.toNamed(signupPasswordConfirm);
  static void toSignUpInfo({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    Get.toNamed(
      signupInfo,
      arguments: {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      },
    );
  }

  static void toConfirmEmail({required String email}) {
    Get.toNamed(confirmEmail, arguments: {'email': email});
  }

  static void toForgotPassword() => Get.toNamed(forgotPassword);

  // ===== PROTECTED NAVIGATION =====
  static void toHome() => Get.offAllNamed(home);

  /// Navigates to the preserved continue route (e.g. from deep links) or falls back to Home,
  /// preserving Home as the root of the navigation stack.
  static void navigateContinueURL([StorageService? storageService]) {
    final storage = storageService ?? Get.find<StorageService>();
    final continueRoute = storage.consumeContinueRoute();
    if (continueRoute != null &&
        continueRoute.isNotEmpty &&
        continueRoute != auth &&
        continueRoute != home) {
      storage.saveRouteStack([home, continueRoute]);
      Get.offAllNamed(home);
      Get.toNamed(continueRoute);
    } else {
      storage.saveRouteStack([home]);
      toHome();
    }
  }

  static void toSettings() => Get.toNamed(settings);
  static void toPayment() => Get.toNamed(payment);
  static void toCheckout({required String url}) =>
      Get.toNamed(checkout, arguments: {'url': url});
  static void toAi() => Get.toNamed(ai);
  static void toProfile() => Get.toNamed(profile);
  static void toNotifications() => Get.toNamed(notifications);
  static void toPlaylist() => Get.toNamed(mediaPlaylist);

  static void toAudioPlayer() {
    if (Get.isRegistered<AudioPlayerService>()) {
      Get.find<AudioPlayerService>().isFullPlayerOpen.value = true;
    }
    Get.toNamed(audioPlayer);
  }

  static void toVideoPlayer() => Get.toNamed(videoPlayer);

  /// Resolves and routes an incoming deep link or notification link.
  ///
  /// External links prompt confirmation before opening. Unsupported or
  /// Web-only routes keep the current page open and notify the user.
  static Future<void> handleDeepLink(String? rawLink) async {
    try {
      if (isExternalNotificationLink(rawLink)) {
        final context = Get.context;
        if (context == null) return;

        final shouldOpen = await AppDialog.confirm(
          context: context,
          title: AppLocales.notification.externalTitle.tr,
          message: AppLocales.notification.externalMessage.tr,
          confirmLabel: AppLocales.notification.externalConfirm.tr,
        );
        if (shouldOpen) {
          await launchUrl(
            Uri.parse(rawLink!.trim()),
            mode: LaunchMode.externalApplication,
          );
        }
        return;
      }

      final target = resolveNotificationRoute(rawLink);
      if (target == null) {
        if (rawLink?.trim().isNotEmpty == true) {
          await showWebOnlyNotificationNotice();
        }
        return;
      }

      final storage = Get.isRegistered<StorageService>()
          ? Get.find<StorageService>()
          : null;
      final authController = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : null;

      final isLoggedIn = authController?.isLoggedIn.value ?? false;

      // If route is protected and user is not logged in: save continueRoute and go to auth
      if (!isLoggedIn) {
        storage?.clearRouteStack();
        storage?.setContinueRoute(target);
        toAuth();
        return;
      }

      // If user is already on the target route, avoid duplicate push
      if (Get.currentRoute == target) {
        return;
      }

      // User is authenticated: ensure Home is the base of the back stack
      if (target == home) {
        storage?.saveRouteStack([home]);
        toHome();
        return;
      }

      storage?.saveRouteStack([home, target]);
      Get.offAllNamed(home);
      Get.toNamed(target);
    } catch (e) {
      debugPrint('❌ Error routing deep link: $e');
    }
  }

  /// Converts Core's platform-neutral link or custom scheme URI (e.g. rexone://ai)
  /// into a registered Mobile route.
  static String? resolveNotificationRoute(String? rawLink) {
    final value = rawLink?.trim();
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null) return null;

    String path;
    String? query;

    if (uri.hasScheme) {
      final scheme = uri.scheme.toLowerCase();
      if (scheme != NotificationConstants.appUrlScheme) {
        return null;
      }
      final host = uri.host.isNotEmpty ? '/${uri.host}' : '';
      path = '$host${uri.path}';
      if (uri.hasQuery) {
        query = uri.query;
      }
    } else {
      path = uri.path;
      if (uri.hasQuery) {
        query = uri.query;
      }
    }

    path = path.toLowerCase();
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    if (path == '/' || path == home) return home;
    if (path == profile) return profile;
    if (path == payment || path.startsWith('$payment/')) return payment;
    if (path == ai) {
      return query != null && query.isNotEmpty ? '$ai?$query' : ai;
    }
    if (path == notifications) return notifications;
    if (path == settings) return settings;
    if (path == mediaPlaylist) return mediaPlaylist;

    // Non-existent route from custom scheme defaults directly to home
    if (uri.hasScheme &&
        uri.scheme.toLowerCase() == NotificationConstants.appUrlScheme) {
      return home;
    }

    return null;
  }

  static bool isExternalNotificationLink(String? rawLink) {
    final uri = Uri.tryParse(rawLink?.trim() ?? '');
    return uri != null &&
        uri.scheme == NotificationConstants.externalLinkScheme &&
        uri.host.isNotEmpty;
  }

  static Future<void> showWebOnlyNotificationNotice() async {
    final context = Get.context;
    if (context == null) return;

    await AppDialog.confirm(
      context: context,
      title: AppLocales.notification.webOnlyTitle.tr,
      message: AppLocales.notification.webOnlyMessage.tr,
      confirmLabel: AppLocales.notification.webOnlyConfirm.tr,
    );
  }

  static final pages = [
    // Public Pages
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(name: auth, page: () => AuthPage()),
    GetPage(name: signinPassword, page: () => const SignInPasswordPage()),
    GetPage(
      name: signupPasswordCreate,
      page: () => const SignUpPasswordCreatePage(),
    ),
    GetPage(
      name: signupPasswordConfirm,
      page: () => const SignUpPasswordConfirmPage(),
    ),
    GetPage(name: signupInfo, page: () => const SignUpInfoPage()),
    GetPage(name: confirmEmail, page: () => const ConfirmEmailPage()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordPage()),

    // Protected Pages
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: settings,
      page: () => const SettingPage(),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: payment,
      page: () => const PaymentPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaymentController>(() => PaymentController());
      }),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: checkout,
      page: () => const CheckoutWebViewPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CheckoutController>(() => CheckoutController());
      }),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: ai,
      page: () => const AiPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AiController>(() => AiController());
      }),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationController>(() => NotificationController());
      }),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: mediaPlaylist,
      page: () => const MediaPlaylistPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MediaPlaylistController>(() => MediaPlaylistController());
      }),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: audioPlayer,
      page: () => const AudioPlayerPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AudioPlayerController>(() => AudioPlayerController());
      }),
      middlewares: [GuardRoutes()],
    ),
    GetPage(
      name: videoPlayer,
      page: () => const VideoPlayerPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<VideoPlayerController>(() => VideoPlayerController());
      }),
      middlewares: [GuardRoutes()],
    ),
  ];
}
