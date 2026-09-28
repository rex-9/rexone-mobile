import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

/// Clean circular avatar component with automatic URL normalization, AWS SigV4 headers,
/// and fallback initials or person icon.
class AppAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.url,
    this.name,
    this.radius = 24.0,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
  });

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final bg = backgroundColor ?? context.colors.primary.withValues(alpha: 0.12);
    final fg = foregroundColor ?? context.colors.primary;

    Widget fallback = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: _initials.isNotEmpty
          ? Text(
              _initials,
              style: context.typo.bodyMedium.copyWith(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.75,
              ),
            )
          : Icon(
              Design.icons.person,
              color: fg,
              size: radius * 0.9,
            ),
    );

    Widget avatar;
    if (url != null && url!.trim().isNotEmpty) {
      avatar = ClipOval(
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: AppImage(
            url: url,
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            fallback: fallback,
          ),
        ),
      );
    } else {
      avatar = fallback;
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}
