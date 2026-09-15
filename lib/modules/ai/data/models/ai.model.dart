// lib/modules/ai/data/models/ai.model.dart
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

class AiAssetModel {
  final String id;
  final String name;
  final String url;
  final String type;
  final String format;
  final String extension;
  final int? sizeBytes;
  final int? durationSecs;
  final String source;
  final String assetableType;
  final String assetableId;
  final String createdAt;
  final String updatedAt;

  const AiAssetModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.format,
    required this.extension,
    this.sizeBytes,
    this.durationSecs,
    required this.source,
    required this.assetableType,
    required this.assetableId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AiAssetModel.fromJson(Map<String, dynamic> json) {
    return AiAssetModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      name: json[AiKeys.name]?.toString() ?? '',
      url: json[AiKeys.url]?.toString() ?? '',
      type: json[AiKeys.type]?.toString() ?? '',
      format: json[AiKeys.format]?.toString() ?? '',
      extension: json[AiKeys.extension]?.toString() ?? '',
      sizeBytes: json[AiKeys.sizeBytes] is int
          ? json[AiKeys.sizeBytes] as int
          : int.tryParse(json[AiKeys.sizeBytes]?.toString() ?? ''),
      durationSecs: json[AiKeys.durationSecs] is int
          ? json[AiKeys.durationSecs] as int
          : int.tryParse(json[AiKeys.durationSecs]?.toString() ?? ''),
      source: json[AiKeys.source]?.toString() ?? '',
      assetableType: json[AiKeys.assetableType]?.toString() ?? '',
      assetableId: json[AiKeys.assetableId]?.toString() ?? '',
      createdAt: json[AiKeys.createdAt]?.toString() ?? '',
      updatedAt: json[AiKeys.updatedAt]?.toString() ?? '',
    );
  }
}

class AiMessageModel {
  final String id;
  final String role; // EChatRole.name // "user" | "assistant"
  final String content;
  final String? roomId;
  final String?
  status; // EAiMessageStatus.name //"queued" | "processing" | "completed" | "failed"
  final String? ttsStatus;
  final List<AiAssetModel> assets;
  final String createdAt;

  AiMessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.roomId,
    this.status,
    this.ttsStatus,
    this.assets = const [],
    required this.createdAt,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    final attrs = json[ApiKeys.attributes] is Map
        ? Map<String, dynamic>.from(json[ApiKeys.attributes] as Map)
        : null;
    final source = attrs ?? json;

    final metadata = source[AiKeys.metadata] is Map
        ? Map<String, dynamic>.from(source[AiKeys.metadata] as Map)
        : null;
    final rawAssets = source[AiKeys.assets];
    final assets = rawAssets is List
        ? rawAssets
              .whereType<Map>()
              .map(
                (item) =>
                    AiAssetModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <AiAssetModel>[];

    return AiMessageModel(
      id: json[ApiKeys.id]?.toString() ?? source[ApiKeys.id]?.toString() ?? '',
      role: source[AiKeys.role]?.toString() ?? EChatRole.user.name,
      content: source[AiKeys.content]?.toString() ?? '',
      roomId: source[AiKeys.roomId]?.toString(),
      status:
          metadata?[AiKeys.status]?.toString() ??
          source[AiKeys.status]?.toString(),
      ttsStatus: metadata?[AiKeys.ttsStatus]?.toString(),
      assets: assets,
      createdAt:
          source[AiKeys.createdAt]?.toString() ??
          AppDateTime.toUtcIso(DateTime.now())!,
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    AiKeys.role: role,
    AiKeys.content: content,
    AiKeys.status: status,
    AiKeys.createdAt: createdAt,
  };

  bool get isUser => role == EChatRole.user.name;
  bool get isFailed => status == EAiMessageStatus.failed.name;
  bool get isProcessing =>
      status == EAiMessageStatus.queued.name ||
      status == EAiMessageStatus.processing.name;

  String? get audioUrl {
    for (final asset in assets) {
      if (asset.type == AiKeys.audio && asset.url.isNotEmpty) {
        return asset.url;
      }
    }
    return null;
  }

  bool get hasAudio => audioUrl != null;
}

class AiRoomModel {
  final String id;
  final String title;
  final int messageCount;
  final String? lastMessage;
  final String createdAt;
  final String updatedAt;
  final bool processing;

  AiRoomModel({
    required this.id,
    required this.title,
    required this.messageCount,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.processing,
  });

  factory AiRoomModel.fromJson(Map<String, dynamic> json) {
    final attrs = json[ApiKeys.attributes] is Map
        ? Map<String, dynamic>.from(json[ApiKeys.attributes] as Map)
        : null;
    final source = attrs ?? json;

    return AiRoomModel(
      id: json[ApiKeys.id]?.toString() ?? source[ApiKeys.id]?.toString() ?? '',
      title: source[AiKeys.title]?.toString() ?? 'New Chat',
      messageCount: source[AiKeys.messageCount] is int
          ? source[AiKeys.messageCount] as int
          : int.tryParse(source[AiKeys.messageCount]?.toString() ?? '0') ?? 0,
      lastMessage: source[AiKeys.lastMessage]?.toString(),
      createdAt: source[AiKeys.createdAt]?.toString() ?? '',
      updatedAt: source[AiKeys.updatedAt]?.toString() ?? '',
      processing: source[AiKeys.processing] == true,
    );
  }

  AiRoomModel copyWith({
    String? id,
    String? title,
    int? messageCount,
    String? lastMessage,
    String? createdAt,
    String? updatedAt,
    bool? processing,
  }) {
    return AiRoomModel(
      id: id ?? this.id,
      title: title ?? this.title,
      messageCount: messageCount ?? this.messageCount,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      processing: processing ?? this.processing,
    );
  }
}
