import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

class MediaDownloadEntry {
  final String assetId;
  final EMediaDownloadState state;
  final double progress;
  final String mediaPath;
  final Map<String, String> subtitlePaths;
  final DateTime? downloadedAt;
  final String? errorMessage;
  final String? title;
  final String? mediaFormat;

  const MediaDownloadEntry({
    required this.assetId,
    this.state = EMediaDownloadState.none,
    this.progress = 0,
    this.mediaPath = '',
    this.subtitlePaths = const {},
    this.downloadedAt,
    this.errorMessage,
    this.title,
    this.mediaFormat,
  });

  bool get isReady => state == EMediaDownloadState.ready && mediaPath.isNotEmpty;

  MediaDownloadEntry copyWith({
    EMediaDownloadState? state,
    double? progress,
    String? mediaPath,
    Map<String, String>? subtitlePaths,
    DateTime? downloadedAt,
    String? errorMessage,
    String? title,
    String? mediaFormat,
    bool clearErrorMessage = false,
  }) {
    return MediaDownloadEntry(
      assetId: assetId,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      mediaPath: mediaPath ?? this.mediaPath,
      subtitlePaths: subtitlePaths ?? this.subtitlePaths,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      title: title ?? this.title,
      mediaFormat: mediaFormat ?? this.mediaFormat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      MediaDownloadConstants.jsonAssetId: assetId,
      MediaDownloadConstants.jsonState: state.storageValue,
      MediaDownloadConstants.jsonProgress: progress,
      MediaDownloadConstants.jsonMediaPath: mediaPath,
      MediaDownloadConstants.jsonSubtitlePaths: subtitlePaths,
      if (downloadedAt != null)
        MediaDownloadConstants.jsonDownloadedAt:
            AppDateTime.toUtcIso(downloadedAt),
      if (errorMessage != null && errorMessage!.isNotEmpty)
        MediaDownloadConstants.jsonErrorMessage: errorMessage,
      if (title != null && title!.isNotEmpty)
        MediaDownloadConstants.jsonTitle: title,
      if (mediaFormat != null && mediaFormat!.isNotEmpty)
        MediaDownloadConstants.jsonMediaFormat: mediaFormat,
    };
  }

  factory MediaDownloadEntry.fromJson(Map<String, dynamic> json) {
    final subtitleRaw = json[MediaDownloadConstants.jsonSubtitlePaths];
    final subtitlePaths = subtitleRaw is Map
        ? subtitleRaw.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : const <String, String>{};

    return MediaDownloadEntry(
      assetId: json[MediaDownloadConstants.jsonAssetId]?.toString() ?? '',
      state: EMediaDownloadState.fromStorage(
        json[MediaDownloadConstants.jsonState]?.toString(),
      ),
      progress: (json[MediaDownloadConstants.jsonProgress] as num?)?.toDouble() ??
          0,
      mediaPath: json[MediaDownloadConstants.jsonMediaPath]?.toString() ?? '',
      subtitlePaths: subtitlePaths,
      downloadedAt: AppDateTime.fromUtc(
        json[MediaDownloadConstants.jsonDownloadedAt],
      ),
      errorMessage: json[MediaDownloadConstants.jsonErrorMessage]?.toString(),
      title: json[MediaDownloadConstants.jsonTitle]?.toString(),
      mediaFormat: json[MediaDownloadConstants.jsonMediaFormat]?.toString(),
    );
  }
}
