// lib/design/components/app_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/services/services.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = false,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.padding,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showExitConfirmation = true,
  });

  final Widget child;
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showExitConfirmation;

  static bool get isIOS => GetPlatform.isIOS;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) _handleBackPressed(context);
      },
      child: isIOS ? _buildCupertinoPage(context) : _buildMaterialPage(context),
    );
  }

  Widget _buildCupertinoPage(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildCupertinoNavBar(context),
      backgroundColor: backgroundColor ?? context.colors.background,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding:
                    padding ?? EdgeInsets.all(Design.spacing.screenPadding),
                child: child,
              ),
              if (bottomNavigationBar != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: bottomNavigationBar!,
                ),
              if (floatingActionButton != null)
                Positioned(bottom: 80, right: 20, child: floatingActionButton!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialPage(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: backgroundColor ?? context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: padding ?? EdgeInsets.all(Design.spacing.screenPadding),
          child: child,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  ObstructingPreferredSizeWidget? _buildCupertinoNavBar(BuildContext context) {
    if (title == null &&
        !showBackButton &&
        (actions == null || actions!.isEmpty)) {
      return null;
    }
    return CupertinoNavigationBar(
      backgroundColor: context.colors.surface.withValues(alpha: 0.9),
      border: Border(
        bottom: BorderSide(color: context.colors.divider, width: 0.5),
      ),
      leading: showBackButton
          ? AppButton(
              type: EButtonType.icon,
              icon: Design.icons.backArrow,
              onPressed: onBackPressed ?? () => _handleBackPressed(context),
            )
          : null,
      middle: title != null
          ? Text(title!, style: context.typo.headline4)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_timeZoneIndicator(context), ...?actions],
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (title == null &&
        !showBackButton &&
        (actions == null || actions!.isEmpty)) {
      return null;
    }
    return AppBar(
      backgroundColor: context.colors.surface,
      foregroundColor: context.colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBackButton
          ? AppButton(
              type: EButtonType.icon,
              icon: Design.icons.backArrow,
              onPressed: onBackPressed ?? () => _handleBackPressed(context),
            )
          : null,
      title: title != null ? Text(title!, style: context.typo.headline4) : null,
      actions: [_timeZoneIndicator(context), ...?actions],
    );
  }

  Widget _timeZoneIndicator(BuildContext context) {
    return Tooltip(
      message: '${AppDateTime.timeZoneName} (${AppDateTime.utcOffset})',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(AppDateTime.utcOffset, style: context.typo.caption),
      ),
    );
  }

  void _handleBackPressed(BuildContext context) async {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      final storage = Get.find<StorageService>();
      final stack = storage.getRouteStack();

      if (stack.length > 1) {
        stack.removeLast();
        storage.saveRouteStack(stack);
        Get.offAllNamed(stack.last);
      } else {
        final result = await _showExitDialog(context);
        if (result == true) {
          Get.back();
          // Exit the app
          if (GetPlatform.isIOS) {
            Future.delayed(const Duration(milliseconds: 100), () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            });
          } else {
            // Android/Web/Desktop - just close the app
            Future.delayed(const Duration(milliseconds: 100), () {
              SystemNavigator.pop();
            });
          }
        }
      }
    }
  }
}

Future<bool> _showExitDialog(BuildContext context) async {
  return await AppDialog.exit(context);
}
