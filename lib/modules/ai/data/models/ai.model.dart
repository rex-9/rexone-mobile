import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/asset.model.dart';

class AiMessageModel {
  final String id;
  final String role; // EChatRole.name // "user" | "assistant"
  final String content;
  final String? roomId;
  final String?
  status; // EAiMessageStatus.name //"queued" | "processing" | "completed" | "failed"
  final String? ttsStatus;
  final List<AssetModel> assets;
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
    final metadata = json[AiKeys.metadata] is Map
        ? Map<String, dynamic>.from(json[AiKeys.metadata] as Map)
        : null;
    final rawAssets = json[AiKeys.assets];
    final assets = rawAssets is List
        ? rawAssets
              .whereType<Map>()
              .map(
                (item) => AssetModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <AssetModel>[];

    return AiMessageModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      role: json[AiKeys.role]?.toString() ?? EChatRole.user.name,
      content: json[AiKeys.content]?.toString() ?? '',
      roomId: json[AiKeys.roomId]?.toString(),
      status:
          metadata?[AiKeys.status]?.toString() ??
          json[AiKeys.status]?.toString(),
      ttsStatus: metadata?[AiKeys.ttsStatus]?.toString(),
      assets: assets,
      createdAt: json[AiKeys.createdAt]?.toString() ?? '',
    );
  }

  bool get isUser => role == EChatRole.user.name;
  bool get isAssistant => role == EChatRole.assistant.name;
  bool get isSystem => role == EChatRole.system.name;

  bool get isCompleted => status == EAiMessageStatus.completed.name;
  bool get isProcessing =>
      status == EAiMessageStatus.queued.name ||
      status == EAiMessageStatus.processing.name;
  bool get isQueued => status == EAiMessageStatus.queued.name;
  bool get isFailed => status == EAiMessageStatus.failed.name;

  String? get audioUrl {
    for (final asset in assets) {
      if (asset.type == AiKeys.tts && asset.url.isNotEmpty) {
        return asset.url;
      }
    }
    return null;
  }

  bool get hasAudio => audioUrl != null;

  AiMessageModel copyWith({
    String? id,
    String? role,
    String? content,
    String? roomId,
    String? status,
    String? ttsStatus,
    List<AssetModel>? assets,
    String? createdAt,
  }) {
    return AiMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
      ttsStatus: ttsStatus ?? this.ttsStatus,
      assets: assets ?? this.assets,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    AiKeys.role: role,
    AiKeys.content: content,
    if (roomId != null) AiKeys.roomId: roomId,
    if (status != null) AiKeys.status: status,
    if (ttsStatus != null) AiKeys.ttsStatus: ttsStatus,
    AiKeys.assets: assets.map((a) => a.toJson()).toList(),
    AiKeys.createdAt: createdAt,
  };
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
    return AiRoomModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      title: json[AiKeys.title]?.toString() ?? 'New Chat',
      messageCount: json[AiKeys.messageCount] is int
          ? json[AiKeys.messageCount] as int
          : int.tryParse(json[AiKeys.messageCount]?.toString() ?? '0') ?? 0,
      lastMessage: json[AiKeys.lastMessage]?.toString(),
      createdAt: json[AiKeys.createdAt]?.toString() ?? '',
      updatedAt: json[AiKeys.updatedAt]?.toString() ?? '',
      processing: json[AiKeys.processing] == true,
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
