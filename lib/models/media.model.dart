import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/asset.model.dart';

class StorageDetails {
  final String storageKey;
  final int bytes;
  final String format;

  const StorageDetails({
    required this.storageKey,
    required this.bytes,
    required this.format,
  });

  factory StorageDetails.fromJson(Map<String, dynamic> json) {
    return StorageDetails(
      storageKey: json[AssetKeys.storageKey]?.toString() ?? '',
      bytes: (json[AssetKeys.bytes] as num?)?.toInt() ?? 0,
      format: json[AssetKeys.format]?.toString() ?? '',
    );
  }
}

class MediaDelivery {
  final String type;
  final String url;
  final DateTime? expiresAt;

  const MediaDelivery({
    required this.type,
    required this.url,
    this.expiresAt,
  });

  factory MediaDelivery.fromJson(Map<String, dynamic> json) {
    return MediaDelivery(
      type: json[AssetKeys.type]?.toString() ?? '',
      url: UrlHelper.normalize(json[AssetKeys.url]?.toString() ?? ''),
      expiresAt: AppDateTime.fromUtc(json[AssetKeys.expiresAt]),
    );
  }
}

class MediaDetails {
  final String contentType;
  final String format;
  final int? sizeBytes;
  final int? durationSecs;
  final ChildAssetModel? thumbnail;
  final List<ChildAssetModel> subtitles;

  const MediaDetails({
    required this.contentType,
    required this.format,
    this.sizeBytes,
    this.durationSecs,
    this.thumbnail,
    this.subtitles = const [],
  });

  List<ChildAssetModel> get playableSubtitles =>
      subtitles.where((item) => item.isPlayableSubtitle).toList();

  factory MediaDetails.fromJson(Map<String, dynamic> json) {
    final thumbRaw = json[AssetKeys.thumbnail];
    final subsRaw = json[AssetKeys.subtitles];

    return MediaDetails(
      contentType: json[AssetKeys.contentType]?.toString() ?? '',
      format: json[AssetKeys.format]?.toString() ?? '',
      sizeBytes: (json[AssetKeys.sizeBytes] as num?)?.toInt(),
      durationSecs: (json[AssetKeys.durationSecs] as num?)?.toInt(),
      thumbnail: thumbRaw is Map
          ? ChildAssetModel.fromJson(Map<String, dynamic>.from(thumbRaw))
          : null,
      subtitles: subsRaw is List
          ? subsRaw
              .whereType<Map>()
              .map(
                (item) => ChildAssetModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
            : const [],
    );
  }
}

class MediaPlaybackModel {
  final String assetId;
  final MediaDelivery delivery;
  final MediaDetails media;

  const MediaPlaybackModel({
    required this.assetId,
    required this.delivery,
    required this.media,
  });

  String get url => delivery.url;
  String get type => delivery.type;
  String get contentType => media.contentType;
  String get format => media.format;
  int? get sizeBytes => media.sizeBytes;
  int? get durationSecs => media.durationSecs;
  ChildAssetModel? get thumbnail => media.thumbnail;
  List<ChildAssetModel> get subtitles => media.subtitles;
  List<ChildAssetModel> get playableSubtitles => media.playableSubtitles;
  DateTime? get expiresAt => delivery.expiresAt;

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  bool get isNearExpiry {
    final expiry = expiresAt;
    if (expiry == null) return false;
    return DateTime.now().isAfter(
      expiry.subtract(const Duration(seconds: 60)),
    );
  }

  factory MediaPlaybackModel.fromJson(Map<String, dynamic> json) {
    final deliveryRaw = json[AssetKeys.delivery];
    final mediaRaw = json[AssetKeys.media];

    return MediaPlaybackModel(
      assetId: json[AssetKeys.assetId]?.toString() ?? '',
      delivery: deliveryRaw is Map
          ? MediaDelivery.fromJson(Map<String, dynamic>.from(deliveryRaw))
          : const MediaDelivery(type: '', url: ''),
      media: mediaRaw is Map
          ? MediaDetails.fromJson(Map<String, dynamic>.from(mediaRaw))
          : const MediaDetails(contentType: '', format: ''),
    );
  }
}

class MediaDownloadModel {
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

  const MediaDownloadModel({
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

  MediaDownloadModel copyWith({
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
    return MediaDownloadModel(
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

  factory MediaDownloadModel.fromJson(Map<String, dynamic> json) {
    final subtitleRaw = json[MediaDownloadConstants.jsonSubtitlePaths];
    final subtitlePaths = subtitleRaw is Map
        ? subtitleRaw.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : const <String, String>{};

    return MediaDownloadModel(
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
