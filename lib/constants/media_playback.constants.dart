// lib/constants/media_playback.constants.dart

class MediaPlaybackConstants {
  const MediaPlaybackConstants._();

  static const List<double> videoSpeedSteps = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  static const String lyricsErrorFetchFailed = 'fetch_failed';
  static const String lyricsErrorEmpty = 'empty';

  /// Network video cache configuration (bytes)
  static const int videoMaxCacheSizeBytes = 100 * 1024 * 1024;
  static const int videoMaxCacheFileSizeBytes = 20 * 1024 * 1024;

  /// Network video buffering configuration (milliseconds)
  static const int videoMinBufferMs = 15000;
  static const int videoMaxBufferMs = 60000;
  static const int videoBufferForPlaybackMs = 2000;
  static const int videoBufferForPlaybackAfterRebufferMs = 4000;
}
