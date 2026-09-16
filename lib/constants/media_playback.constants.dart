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

  /// Temporary override for download/playback testing. Set empty to use API URL.
  static const String testPlaybackUrl =
      'https://testfileorg.netwet.net/Sample%20Video%202/sample_1280x720.mp4';
}
