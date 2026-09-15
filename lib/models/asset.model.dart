import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

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
  final String? status;
  final String? parentAssetId;
  final Map<String, dynamic>? children;
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
    this.status,
    this.parentAssetId,
    this.children,
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
      status: json[AssetKeys.status]?.toString(),
      parentAssetId: json[AssetKeys.parentAssetId]?.toString(),
      children: json[AssetKeys.children] is Map
          ? Map<String, dynamic>.from(json[AssetKeys.children] as Map)
          : null,
      createdAt: AppDateTime.fromUtc(json[AssetKeys.createdAt]),
      updatedAt: AppDateTime.fromUtc(json[AssetKeys.updatedAt]),
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
      if (status != null) AssetKeys.status: status,
      if (parentAssetId != null) AssetKeys.parentAssetId: parentAssetId,
      if (children != null) AssetKeys.children: children,
    };
  }

  AssetModel copyWith({
    String? id,
    String? name,
    String? url,
    String? type,
    String? format,
    String? extension,
    int? sizeBytes,
    int? durationSecs,
    String? source,
    String? assetableType,
    String? assetableId,
    String? createdById,
    String? status,
    String? parentAssetId,
    Map<String, dynamic>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      format: format ?? this.format,
      extension: extension ?? this.extension,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      durationSecs: durationSecs ?? this.durationSecs,
      source: source ?? this.source,
      assetableType: assetableType ?? this.assetableType,
      assetableId: assetableId ?? this.assetableId,
      createdById: createdById ?? this.createdById,
      status: status ?? this.status,
      parentAssetId: parentAssetId ?? this.parentAssetId,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
