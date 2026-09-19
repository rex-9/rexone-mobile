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
  final bool isEncrypted;
  final int? sizeBytes;
  final int? downloadedBytes;
  final int? diskSizeBytes;

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
    this.isEncrypted = false,
    this.sizeBytes,
    this.downloadedBytes,
    this.diskSizeBytes,
  });

  bool get isReady => state == EMediaDownloadState.ready && mediaPath.isNotEmpty;

  /// Human-readable representation of the asset file size (e.g. `4.2 MB`).
  String get formattedSize =>
      FileSizeHelper.formatBytes(diskSizeBytes ?? sizeBytes);

  /// Human-readable progress string during active download (e.g. `1.2 MB / 4.2 MB (28%)`).
  String get formattedProgressSize => FileSizeHelper.formatProgress(
        downloadedBytes: downloadedBytes,
        totalBytes: sizeBytes,
        fallbackProgress: progress,
      );

  MediaDownloadEntry copyWith({
    EMediaDownloadState? state,
    double? progress,
    String? mediaPath,
    Map<String, String>? subtitlePaths,
    DateTime? downloadedAt,
    String? errorMessage,
    String? title,
    String? mediaFormat,
    bool? isEncrypted,
    int? sizeBytes,
    int? downloadedBytes,
    int? diskSizeBytes,
    bool clearErrorMessage = false,
  }) {
    return MediaDownloadEntry(
      assetId: assetId,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      mediaPath: mediaPath ?? this.mediaPath,
      subtitlePaths: subtitlePaths ?? this.subtitlePaths,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      title: title ?? this.title,
      mediaFormat: mediaFormat ?? this.mediaFormat,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      diskSizeBytes: diskSizeBytes ?? this.diskSizeBytes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      MediaDownloadConstants.jsonAssetId: assetId,
      MediaDownloadConstants.jsonState: state.storageValue,
      MediaDownloadConstants.jsonProgress: progress,
      MediaDownloadConstants.jsonMediaPath: mediaPath,
      MediaDownloadConstants.jsonSubtitlePaths: subtitlePaths,
      if (isEncrypted) 'isEncrypted': true,
      if (sizeBytes != null) 'sizeBytes': sizeBytes,
      if (downloadedBytes != null) 'downloadedBytes': downloadedBytes,
      if (diskSizeBytes != null) 'diskSizeBytes': diskSizeBytes,
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
      isEncrypted: json['isEncrypted'] == true,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      downloadedBytes: (json['downloadedBytes'] as num?)?.toInt(),
      diskSizeBytes: (json['diskSizeBytes'] as num?)?.toInt(),
    );
  }
}
