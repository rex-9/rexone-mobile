import 'package:rexone_mobile/constants/constants.dart';

class AssetThumbnailModel {
  final String id;
  final String url;
  final String status;
  final int? sizeBytes;

  const AssetThumbnailModel({
    required this.id,
    required this.url,
    required this.status,
    this.sizeBytes,
  });

  factory AssetThumbnailModel.fromJson(Map<String, dynamic> json) {
    return AssetThumbnailModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      url: json[AssetKeys.url]?.toString() ?? '',
      status: json[AssetKeys.status]?.toString() ?? '',
      sizeBytes: (json[AssetKeys.sizeBytes] as num?)?.toInt(),
    );
  }
}

class AssetModel {
  final String id;
  final String name;
  final String url;
  final String type;
  final String? format;
  final String? extension;
  final int? sizeBytes;
  final int? durationSecs;
  final String source;
  final String? status;
  final String? assetableType;
  final String? assetableId;
  final String? parentAssetId;
  final String? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AssetThumbnailModel? thumbnail;

  AssetModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.format,
    this.extension,
    this.sizeBytes,
    this.durationSecs,
    required this.source,
    this.status,
    this.assetableType,
    this.assetableId,
    this.parentAssetId,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
  });

  /// Playable when compression finished (`ready` or `optimal`).
  bool get isReady =>
      status == null ||
      status!.isEmpty ||
      AssetKeys.playableStatuses.contains(status);

  bool get _isThumbnailUsable {
    final thumbStatus = thumbnail?.status ?? '';
    return thumbStatus.isEmpty ||
        AssetKeys.playableStatuses.contains(thumbStatus);
  }

  String get displayTitle {
    if (name.isEmpty) return '';
    final segments = name.split('/');
    final base = segments.isNotEmpty ? segments.last : name;
    final dot = base.lastIndexOf('.');
    return dot > 0 ? base.substring(0, dot) : base;
  }

  String get displaySubtitle {
    if (durationSecs == null || durationSecs! <= 0) return '';
    final minutes = durationSecs! ~/ 60;
    final seconds = durationSecs! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get displayThumbnailUrl {
    final thumb = thumbnail;
    if (thumb == null || thumb.url.isEmpty) return '';
    if (thumb.status.isNotEmpty && thumb.status != AssetKeys.statusReady) {
      return '';
    }
    return thumb.url;
  }

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    final thumbRaw = json[AssetKeys.thumbnail];
    return AssetModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      name: json[AssetKeys.name]?.toString() ?? '',
      url: json[AssetKeys.url]?.toString() ?? '',
      type: json[AssetKeys.type]?.toString() ?? '',
      format: json[AssetKeys.format]?.toString(),
      extension: json[AssetKeys.extension]?.toString(),
      sizeBytes: (json[AssetKeys.sizeBytes] as num?)?.toInt(),
      durationSecs: (json[AssetKeys.durationSecs] as num?)?.toInt(),
      source: json[AssetKeys.source]?.toString() ?? AssetKeys.sourceUpload,
      status: json[AssetKeys.status]?.toString(),
      assetableType: json[AssetKeys.assetableType]?.toString(),
      assetableId: json[AssetKeys.assetableId]?.toString(),
      parentAssetId: json[AssetKeys.parentAssetId]?.toString(),
      createdById: json[AssetKeys.createdById]?.toString(),
      createdAt: json[AssetKeys.createdAt] != null
          ? DateTime.tryParse(json[AssetKeys.createdAt].toString())
          : null,
      updatedAt: json[AssetKeys.updatedAt] != null
          ? DateTime.tryParse(json[AssetKeys.updatedAt].toString())
          : null,
      thumbnail: thumbRaw is Map
          ? AssetThumbnailModel.fromJson(Map<String, dynamic>.from(thumbRaw))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKeys.id: id,
      AssetKeys.name: name,
      AssetKeys.url: url,
      AssetKeys.type: type,
      if (format != null) AssetKeys.format: format,
      if (extension != null) AssetKeys.extension: extension,
      if (sizeBytes != null) AssetKeys.sizeBytes: sizeBytes,
      if (durationSecs != null) AssetKeys.durationSecs: durationSecs,
      AssetKeys.source: source,
      if (status != null) AssetKeys.status: status,
      if (assetableType != null) AssetKeys.assetableType: assetableType,
      if (assetableId != null) AssetKeys.assetableId: assetableId,
      if (parentAssetId != null) AssetKeys.parentAssetId: parentAssetId,
      if (createdById != null) AssetKeys.createdById: createdById,
    };
  }
}
