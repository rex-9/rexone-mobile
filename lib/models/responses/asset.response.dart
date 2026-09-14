import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/asset.model.dart';

class StorageDetails {
  final String storageKey;
  final int bytes;
  final String format;

  StorageDetails({
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

class AssetPlaybackDelivery {
  final String type;
  final String url;
  final DateTime? expiresAt;

  const AssetPlaybackDelivery({
    required this.type,
    required this.url,
    this.expiresAt,
  });

  factory AssetPlaybackDelivery.fromJson(Map<String, dynamic> json) {
    return AssetPlaybackDelivery(
      type: json[AssetKeys.type]?.toString() ?? '',
      url: json[AssetKeys.url]?.toString() ?? '',
      expiresAt: AppDateTime.fromUtc(json[AssetKeys.expiresAt]),
    );
  }
}

class AssetPlaybackMedia {
  final String contentType;
  final String format;
  final int? sizeBytes;
  final int? durationSecs;
  final ChildAssetModel? thumbnail;
  final List<ChildAssetModel> subtitles;

  const AssetPlaybackMedia({
    required this.contentType,
    required this.format,
    this.sizeBytes,
    this.durationSecs,
    this.thumbnail,
    this.subtitles = const [],
  });

  List<ChildAssetModel> get playableSubtitles =>
      subtitles.where((item) => item.isPlayableSubtitle).toList();

  factory AssetPlaybackMedia.fromJson(Map<String, dynamic> json) {
    final thumbRaw = json[AssetKeys.thumbnail];
    final subsRaw = json[AssetKeys.subtitles];

    return AssetPlaybackMedia(
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

class AssetPlaybackResponse {
  final String assetId;
  final AssetPlaybackDelivery delivery;
  final AssetPlaybackMedia media;

  const AssetPlaybackResponse({
    required this.assetId,
    required this.delivery,
    required this.media,
  });

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

  factory AssetPlaybackResponse.fromJson(Map<String, dynamic> json) {
    final deliveryRaw = json[AssetKeys.delivery];
    final mediaRaw = json[AssetKeys.media];

    return AssetPlaybackResponse(
      assetId: json[AssetKeys.assetId]?.toString() ?? '',
      delivery: deliveryRaw is Map
          ? AssetPlaybackDelivery.fromJson(
              Map<String, dynamic>.from(deliveryRaw),
            )
          : const AssetPlaybackDelivery(type: '', url: ''),
      media: mediaRaw is Map
          ? AssetPlaybackMedia.fromJson(Map<String, dynamic>.from(mediaRaw))
          : const AssetPlaybackMedia(contentType: '', format: ''),
    );
  }
}

class AssetUploadResponse {
  final AssetModel asset;
  final StorageDetails storageDetails;

  AssetUploadResponse({
    required this.asset,
    required this.storageDetails,
  });

  factory AssetUploadResponse.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json[AssetKeys.storageDetails];
    return AssetUploadResponse(
      asset:
          ApiHelper.parseRecord(json[AssetKeys.asset], AssetModel.fromJson) ??
          AssetModel.fromJson(const {}),
      storageDetails: detailsRaw is Map
          ? StorageDetails.fromJson(Map<String, dynamic>.from(detailsRaw))
          : StorageDetails(storageKey: '', bytes: 0, format: ''),
    );
  }
}
