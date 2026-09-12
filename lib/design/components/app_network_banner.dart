// lib/design/components/app_network_banner.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locales/app_locales.dart';
import '../../services/network.service.dart';
import '../design.dart';

/// Global overlay banner displaying offline / connectivity restored status.
/// When offline: displays error banner ('Connection lost').
/// When back online: displays green success banner ('Connection is safe and sound') for 3s, then smoothly disappears.
class AppNetworkBanner extends StatelessWidget {
  final Widget child;

  const AppNetworkBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Obx(() {
          if (!Get.isRegistered<NetworkService>()) {
            return const SizedBox.shrink();
          }

          final network = Get.find<NetworkService>();
          final isVisible = network.isBannerVisible.value;
          final isRestored = network.isRestored.value;
          final statusColor = isRestored
              ? context.colors.success
              : context.colors.error;

          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                ignoring: !isVisible,
                child: AnimatedSlide(
                  duration: Design.timers.medium,
                  curve: Design.timers.easeInOut,
                  offset: isVisible ? Offset.zero : const Offset(0, -1.2),
                  child: AnimatedOpacity(
                    duration: Design.timers.short,
                    opacity: isVisible ? 1.0 : 0.0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: Design.spacing.paddingSymmetric(
                          h: Design.spacing.md,
                          v: Design.spacing.xs,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: Design.spacing.bannerMaxWidth,
                          ),
                          child: Material(
                            color: context.colors.surface,
                            borderRadius: BorderRadius.circular(
                              Design.spacing.radiusLarge,
                            ),
                            elevation: 0,
                            child: AnimatedContainer(
                              duration: Design.timers.medium,
                              curve: Design.timers.easeInOut,
                              padding: Design.spacing.paddingSymmetric(
                                h: Design.spacing.md,
                                v: Design.spacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.35),
                                ),
                                borderRadius: BorderRadius.circular(
                                  Design.spacing.radiusLarge,
                                ),
                                boxShadow: Design.colors.shadows.sm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: Design.spacing.padding(
                                      Design.spacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.14,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isRestored
                                          ? Design.icons.wifi
                                          : Design.icons.wifiOff,
                                      color: statusColor,
                                      size: Design.spacing.iconSmall,
                                    ),
                                  ),
                                  SizedBox(width: Design.spacing.sm),
                                  Flexible(
                                    child: Text(
                                      isRestored
                                          ? AppLocales
                                                .common
                                                .connectionRestored
                                                .tr
                                          : AppLocales.common.connectionLost.tr,
                                      style: context.typo.labelMedium.copyWith(
                                        color: context.colors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
