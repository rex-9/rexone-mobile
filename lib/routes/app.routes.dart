// lib/routes/app_routes.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/components/app_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rexone_mobile/routes/guard.routes.dart';
import 'package:rexone_mobile/routes/server.routes.dart';

import '../modules/ai/ai.dart';
import '../modules/auth/auth.dart';
import '../modules/home/home.dart';
import '../modules/payment/payment.dart';
import '../modules/profile/profile.dart';
import '../modules/setting/setting.dart';
import '../modules/notification/notification.dart';
import '../modules/splash/splash.dart';

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
  /// Notification links always stay inside the native application. Unsupported
  /// or Web-only routes keep the current page open and explain where to view
  /// the update.
  static Future<void> handleNotificationLink(String? rawLink) async {
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
      if (target == payment) {
        toPayment();
        return;
      }
      if (target == ai || target.startsWith('$ai?')) {
        Get.toNamed(target);
        return;
      }
      if (target == profile) {
        toProfile();
        return;
      }
      if (target == notifications) {
        toNotifications();
        return;
      }
      if (target == home) toHome();
    } catch (e) {
      debugPrint('❌ Error routing notification link: $e');
    }
  }

  /// Converts Core's platform-neutral link into a registered Mobile route.
  static String? resolveNotificationRoute(String? rawLink) {
    final value = rawLink?.trim();
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || uri.hasScheme || uri.hasAuthority) return null;

    var path = uri.path.toLowerCase();
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    if (path == '/' || path == home) return home;
    if (path == profile) return profile;
    if (path == payment || path.startsWith('$payment/')) return payment;
    if (path == ai) {
      return uri.hasQuery ? '$ai?${uri.query}' : ai;
    }
    if (path == notifications) return notifications;

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
  ];

  static final notFound = GetPage(
    name: '/404',
    page: () => const HomePage(),
    middlewares: [GuardRoutes()],
  );
}
