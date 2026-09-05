// lib/design/elements/app_icons.dart
import 'package:flutter/material.dart';

/// Central icon registry. Every icon used anywhere in the app MUST be
/// declared here and accessed via [Design.icons]. Never reference [Icons]
/// directly outside of this file.
class AppIcons {
  const AppIcons();

  // ── Feedback ───────────────────────────────────────────────────
  IconData get error => Icons.error_outline_rounded;
  IconData get warning => Icons.warning_amber_rounded;
  IconData get success => Icons.check_circle_outline_rounded;
  IconData get info => Icons.info_outline_rounded;
  IconData get check => Icons.check_circle_outline_rounded;

  // ── Theme ──────────────────────────────────────────────────────
  IconData get lightMode => Icons.light_mode_rounded;
  IconData get darkMode => Icons.dark_mode_rounded;
  IconData get brightness => Icons.brightness_auto_rounded;

  // ── Navigation / Actions ───────────────────────────────────────
  IconData get backArrow => Icons.arrow_back_rounded;
  IconData get rightArrow => Icons.chevron_right_rounded;
  IconData get downArrow => Icons.arrow_drop_down_rounded;
  IconData get close => Icons.close_rounded;
  IconData get send => Icons.send_rounded;
  IconData get feedback => Icons.feedback_outlined;
  IconData get delete => Icons.delete_outline;
  IconData get deleteSweep => Icons.delete_sweep_outlined;

  // ── User / Auth ────────────────────────────────────────────────
  IconData get logout => Icons.logout_rounded;
  IconData get person => Icons.person_rounded;
  IconData get lock => Icons.lock_rounded;
  IconData get edit => Icons.edit_rounded;
  IconData get camera => Icons.photo_camera_rounded;
  IconData get gallery => Icons.photo_library_rounded;

  // ── Settings / UI ─────────────────────────────────────────────
  IconData get settings => Icons.settings_outlined;
  IconData get language => Icons.language_rounded;
  IconData get bell => Icons.notifications_outlined;
  IconData get bellActive => Icons.notifications_rounded;
  IconData get checkAll => Icons.done_all_rounded;
  IconData get filter => Icons.filter_list_rounded;
  IconData get openLink => Icons.open_in_new_rounded;

  // ── Chat / AI ─────────────────────────────────────────────────
  IconData get forum => Icons.forum_outlined;
  IconData get chat => Icons.chat_bubble_outline;
  IconData get mic => Icons.mic_rounded;
  IconData get stop => Icons.stop_rounded;
  IconData get play => Icons.play_arrow_rounded;
  IconData get speaker => Icons.volume_up_rounded;

  // ── Payment / Subscription ────────────────────────────────────
  IconData get activeSubscription => Icons.check_circle_outline;
  IconData get scheduledCancel => Icons.access_time;
  IconData get canceledSubscription => Icons.cancel_outlined;

  // ── Network / Connectivity ─────────────────────────────────────
  IconData get wifi => Icons.wifi_rounded;
  IconData get wifiOff => Icons.wifi_off_rounded;

  // ── Dev / Debug ───────────────────────────────────────────────
  IconData get bug => Icons.bug_report_outlined;
}
