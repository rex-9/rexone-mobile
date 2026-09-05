// lib/routes/app_routes.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/pages/pages.dart';
import 'package:rexone_mobile/routes/guard.routes.dart';
import 'package:rexone_mobile/routes/server.routes.dart';

import '../modules/ai/ai.dart';
import '../modules/auth/auth.dart';
import '../modules/home/home.dart';
import '../modules/payment/payment.dart';
import '../modules/profile/profile.dart';
import '../modules/setting/setting.dart';
import '../modules/notification/notification.dart';

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
  static void toSettings() => Get.toNamed(settings);
  static void toPayment() => Get.toNamed(payment);
  static void toCheckout({required String url}) =>
      Get.toNamed(checkout, arguments: {'url': url});
  static void toAi() => Get.toNamed(ai);
  static void toProfile() => Get.toNamed(profile);
  static void toNotifications() => Get.toNamed(notifications);

  /// Resolves and routes a notification or deep link.
  ///
  /// - Links matching internal stacked routes (Payment, AI, Settings, Home, Notifications)
  ///   keep the user inside the app and route to the corresponding native screen.
  /// - Links not matching any mobile stacked routes (e.g. external websites, web-only admin paths)
  ///   are launched in the external system browser via [url_launcher].
  static Future<void> handleNotificationLink(String? rawLink) async {
    if (rawLink == null) return;
    final link = rawLink.trim();
    if (link.isEmpty) return;

    try {
      final uri = Uri.tryParse(link);
      final hasScheme =
          uri != null && (uri.isScheme('http') || uri.isScheme('https'));
      final path = hasScheme ? uri.path.toLowerCase() : link.toLowerCase();

      final normalizedPath = (path.length > 1 && path.endsWith('/'))
          ? path.substring(0, path.length - 1)
          : path;

      // 1. Payment & Billing (keep in app without leaving or opening checkout webview)
      if (_matchesPaymentRoute(normalizedPath)) {
        toPayment();
        return;
      }

      // 2. AI / Chat
      if (_matchesAiRoute(normalizedPath)) {
        toAi();
        return;
      }

      // 3. Settings & Profile
      if (_matchesSettingsRoute(normalizedPath)) {
        toSettings();
        return;
      }

      // 4. Notifications
      if (_matchesNotificationsRoute(normalizedPath)) {
        toNotifications();
        return;
      }

      // 5. Home / Root
      if (normalizedPath == '/' || normalizedPath == home) {
        toHome();
        return;
      }

      // 6. Any other registered mobile page in AppRoutes
      if (normalizedPath.startsWith('/')) {
        final matchesRegistered = pages.any(
          (p) => p.name.toLowerCase() == normalizedPath,
        );
        if (matchesRegistered) {
          Get.toNamed(normalizedPath);
          return;
        }
      }

      // 7. Unmatched link -> launch in external browser
      final targetUri = hasScheme
          ? uri
          : Uri.tryParse(
              '${_getWebBaseUrl()}${normalizedPath.startsWith('/') ? normalizedPath : '/$normalizedPath'}',
            );

      if (targetUri != null) {
        final launched = await launchUrl(
          targetUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          debugPrint('⚠️ Could not launch external URL: $targetUri');
        }
        return;
      }

      debugPrint('⚠️ Unhandled notification link: $link');
    } catch (e) {
      debugPrint('❌ Error routing notification link: $e');
    }
  }

  static bool _matchesPaymentRoute(String path) {
    return path == payment ||
        path.startsWith('/payment') ||
        path.startsWith('/checkout') ||
        path.startsWith('/pricing') ||
        path.startsWith('/subscription') ||
        path.startsWith('/transaction') ||
        path.startsWith('/invoice');
  }

  static bool _matchesAiRoute(String path) {
    return path == ai || path.startsWith('/ai') || path.startsWith('/chat');
  }

  static bool _matchesSettingsRoute(String path) {
    return path == settings ||
        path.startsWith('/settings') ||
        path.startsWith('/profile') ||
        path.startsWith('/account');
  }

  static bool _matchesNotificationsRoute(String path) {
    return path == notifications || path.startsWith('/notification');
  }

  static String _getWebBaseUrl() {
    final api = AppConfig.apiBaseUrl;
    if (api.contains('localhost:3000')) {
      return 'http://localhost:4000';
    } else if (api.contains('10.0.2.2:3000')) {
      return 'http://10.0.2.2:4000';
    } else if (api.contains('api.')) {
      return api.replaceFirst('api.', '');
    }
    return 'https://rexone.org';
  }

  static final pages = [
    // Public Pages
    GetPage(name: splash, page: () => const SplashPage()),
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
  ];

  static final notFound = GetPage(
    name: '/404',
    page: () => const HomePage(),
    middlewares: [GuardRoutes()],
  );
}
