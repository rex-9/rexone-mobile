import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// iOS Lock Screen / Control Center Now Playing.
///
/// `audio_service` 0.18.19 never sets `MPNowPlayingInfoCenter.playbackState`
/// on iPhone, which iOS 13+ requires to show the system player.
class NowPlayingBridge {
  const NowPlayingBridge._();

  static const _channel = MethodChannel('rexone/now_playing');

  static Future<void> setPlaybackState({required bool playing}) async {
    if (!GetPlatform.isIOS) return;
    try {
      await _channel.invokeMethod('setPlaybackState', {'playing': playing});
    } catch (_) {}
  }

  static Future<void> clear() async {
    if (!GetPlatform.isIOS) return;
    try {
      await _channel.invokeMethod('clear');
    } catch (_) {}
  }
}
