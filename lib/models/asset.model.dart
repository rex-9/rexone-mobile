import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

class ChildAssetModel {
  final String id;
  final String url;
  final String status;
  final int? sizeBytes;
  final String name;
  final String? title;
  final String? description;
  final String? extension;
  final String? format;
  final String? type;

  const ChildAssetModel({
    required this.id,
    required this.url,
    required this.status,
    this.sizeBytes,
    this.name = '',
    this.title,
    this.description,
    this.extension,
    this.format,
    this.type,
  });

  String get displayLabel {
    final labeled = title?.trim();
    if (labeled != null && labeled.isNotEmpty) return labeled;

    if (name.isEmpty) return id;
    final segments = name.split('/');
    final base = segments.isNotEmpty ? segments.last : name;
    final dot = base.lastIndexOf('.');
    return dot > 0 ? base.substring(0, dot) : base;
  }

  bool get isPlayableSubtitle {
    if (url.isEmpty) return false;
    if (status.isNotEmpty && status != AssetKeys.statusReady) return false;
    if (extension != null && extension!.isNotEmpty && extension != 'srt') {
      return false;
    }
    return true;
  }

  factory ChildAssetModel.fromJson(Map<String, dynamic> json) {
    return ChildAssetModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      url: json[AssetKeys.url]?.toString() ?? '',
      status: json[AssetKeys.status]?.toString() ?? '',
      sizeBytes: (json[AssetKeys.sizeBytes] as num?)?.toInt(),
      name: json[AssetKeys.name]?.toString() ?? '',
      title: json[AssetKeys.title]?.toString(),
      description: json[AssetKeys.description]?.toString(),
      extension: json[AssetKeys.extension]?.toString(),
      format: json[AssetKeys.format]?.toString(),
      type: json[AssetKeys.type]?.toString(),
    );
  }
}

class AssetModel {
  final String id;
  final String name;
  final String? title;
  final String? description;
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
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? children;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ChildAssetModel? thumbnail;
  final List<ChildAssetModel> subtitles;

  AssetModel({
    required this.id,
    required this.name,
    this.title,
    this.description,
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
    this.metadata,
    this.children,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.subtitles = const [],
  });

  String get displayTitle {
    final labeled = title?.trim();
    if (labeled != null && labeled.isNotEmpty) return labeled;

    if (name.isEmpty) return '';
    final segments = name.split('/');
    final base = segments.isNotEmpty ? segments.last : name;
    final dot = base.lastIndexOf('.');
    return dot > 0 ? base.substring(0, dot) : base;
  }

  String get displayDuration {
    if (durationSecs == null || durationSecs! <= 0) return '';
    final minutes = durationSecs! ~/ 60;
    final seconds = durationSecs! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get displayThumbnailUrl {
    final thumb = thumbnail;
    if (thumb == null || thumb.url.isEmpty) return '';
    return thumb.url;
  }

  List<ChildAssetModel> get playableSubtitles =>
      subtitles.where((item) => item.isPlayableSubtitle).toList();

  bool get hasPlayableSubtitle => playableSubtitles.isNotEmpty;

  ChildAssetModel? get primarySubtitle =>
      playableSubtitles.isEmpty ? null : playableSubtitles.first;

  String subtitleUrlAt(int index) {
    final tracks = playableSubtitles;
    if (index < 0 || index >= tracks.length) return '';
    return tracks[index].url;
  }

  String get subtitleUrl => primarySubtitle?.url ?? '';

  bool get isAudioMedia => format == AssetKeys.formatAudio;

  bool get isVideoMedia => format == AssetKeys.formatVideo;

  bool get isPlayableMedia => isAudioMedia || isVideoMedia;

  bool matchesMediaFormat(String mediaFormat) =>
      format?.toLowerCase() == mediaFormat.toLowerCase();

  static ChildAssetModel? _childFromJson(dynamic raw) {
    if (raw is! Map) return null;
    return ChildAssetModel.fromJson(Map<String, dynamic>.from(raw));
  }

  static List<ChildAssetModel> _subtitlesFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => ChildAssetModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static ({ChildAssetModel? thumbnail, List<ChildAssetModel> subtitles})
      _parseChildAssets(Map<String, dynamic> json) {
    final children = json[AssetKeys.children];
    if (children is Map) {
      final map = Map<String, dynamic>.from(children);
      return (
        thumbnail: _childFromJson(map[AssetKeys.thumbnail]),
        subtitles: _subtitlesFromJson(map[AssetKeys.subtitles]),
      );
    }

    final legacySubtitle = _childFromJson(json[AssetKeys.subtitle]);
    return (
      thumbnail: _childFromJson(json[AssetKeys.thumbnail]),
      subtitles: legacySubtitle == null ? const [] : [legacySubtitle],
    );
  }

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    final childAssets = _parseChildAssets(json);

    return AssetModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      name: json[AssetKeys.name]?.toString() ?? '',
      title: json[AssetKeys.title]?.toString(),
      description: json[AssetKeys.description]?.toString(),
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
      metadata: json[AssetKeys.metadata] is Map
          ? Map<String, dynamic>.from(json[AssetKeys.metadata] as Map)
          : null,
      children: json[AssetKeys.children] is Map
          ? Map<String, dynamic>.from(json[AssetKeys.children] as Map)
          : null,
      createdAt: AppDateTime.fromUtc(json[AssetKeys.createdAt]),
      updatedAt: AppDateTime.fromUtc(json[AssetKeys.updatedAt]),
      thumbnail: childAssets.thumbnail,
      subtitles: childAssets.subtitles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKeys.id: id,
      AssetKeys.name: name,
      if (title != null) AssetKeys.title: title,
      if (description != null) AssetKeys.description: description,
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
      if (metadata != null) AssetKeys.metadata: metadata,
      if (children != null) AssetKeys.children: children,
    };
  }

  AssetModel copyWith({
    String? id,
    String? name,
    String? title,
    String? description,
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
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
    ChildAssetModel? thumbnail,
    List<ChildAssetModel>? subtitles,
  }) {
    return AssetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
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
      metadata: metadata ?? this.metadata,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      subtitles: subtitles ?? this.subtitles,
    );
  }
}
