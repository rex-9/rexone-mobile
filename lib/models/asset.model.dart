import 'package:rexone_mobile/constants/constants.dart';

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
  final String? assetableType;
  final String? assetableId;
  final String? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.assetableType,
    this.assetableId,
    this.createdById,
    this.createdAt,
    this.updatedAt,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      name: json[AssetKeys.name] ?? '',
      url: json[AssetKeys.url] ?? '',
      type: json[AssetKeys.type] ?? '',
      format: json[AssetKeys.format],
      extension: json[AssetKeys.extension],
      sizeBytes: (json[AssetKeys.sizeBytes] as num?)?.toInt(),
      durationSecs: (json[AssetKeys.durationSecs] as num?)?.toInt(),
      source: json[AssetKeys.source] ?? AssetKeys.sourceUpload,
      assetableType: json[AssetKeys.assetableType],
      assetableId: json[AssetKeys.assetableId],
      createdById: json[AssetKeys.createdById],
      createdAt: json[AssetKeys.createdAt] != null
          ? DateTime.tryParse(json[AssetKeys.createdAt].toString())
          : null,
      updatedAt: json[AssetKeys.updatedAt] != null
          ? DateTime.tryParse(json[AssetKeys.updatedAt].toString())
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
      if (assetableType != null) AssetKeys.assetableType: assetableType,
      if (assetableId != null) AssetKeys.assetableId: assetableId,
      if (createdById != null) AssetKeys.createdById: createdById,
    };
  }
}
