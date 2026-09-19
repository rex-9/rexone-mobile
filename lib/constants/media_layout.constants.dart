// lib/constants/media_layout.constants.dart

class MediaLayoutConstants {
  const MediaLayoutConstants._();

  /// Distance from list bottom (px) before triggering paginated load-more.
  static const double playlistScrollPrefetchPx = 200;

  /// Top spacer fraction for empty playlist refresh views.
  static const double playlistEmptyTopFraction = 0.15;

  /// Default page size for audio/video asset playlists.
  static const int playlistPageLimit = 10;

  /// 16:9 inline video player layout.
  static const double videoAspectWidth = 16;
  static const double videoAspectHeight = 9;
  static const double videoMetadataReserveHeight = 180;
  static const double videoMinViewportHeight = 120;

  /// Max height fraction for video settings / subtitle bottom sheets.
  static const double videoSheetMaxHeightFraction = 0.55;
}
