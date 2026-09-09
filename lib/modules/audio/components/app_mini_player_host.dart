import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/routes/app.routes.dart';

import '../audio.dart';

class AppMiniPlayerHost extends StatelessWidget {
  const AppMiniPlayerHost({super.key, required this.child});

  final Widget? child;

  static const _hiddenRoutes = {
    AppRoutes.splash,
    AppRoutes.auth,
    AppRoutes.signinPassword,
    AppRoutes.signupPasswordCreate,
    AppRoutes.signupPasswordConfirm,
    AppRoutes.signupInfo,
    AppRoutes.confirmEmail,
    AppRoutes.forgotPassword,
    AppRoutes.audioPlayer,
    AppRoutes.ai,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child ?? const SizedBox.shrink()),
        Obx(() {
          if (!Get.isRegistered<AudioPlayerService>()) {
            return const SizedBox.shrink();
          }
          final player = Get.find<AudioPlayerService>();
          final route = player.navRoute.value.isEmpty
              ? Get.currentRoute
              : player.navRoute.value;
          if (!player.hasSession.value ||
              player.isFullPlayerOpen.value ||
              _hiddenRoutes.contains(route)) {
            return const SizedBox.shrink();
          }
          return const SafeArea(
            top: false,
            child: MiniPlayer(),
          );
        }),
      ],
    );
  }
}

class MiniPlayerRouteObserver extends NavigatorObserver {
  void _sync(Route<dynamic>? route) {
    if (!Get.isRegistered<AudioPlayerService>()) return;
    final name = route?.settings.name ?? Get.currentRoute;
    Get.find<AudioPlayerService>().navRoute.value = name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _sync(newRoute);
  }
}
