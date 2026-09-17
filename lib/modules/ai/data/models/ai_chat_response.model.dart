// lib/modules/ai/data/models/ai_chat_response.model.dart
import 'package:rexone_mobile/constants/constants.dart';
import 'ai.model.dart';

class AiChatResponse {
  final List<AiMessageModel> messages;
  final String roomId;
  final String? status;
  final String? operationId;
  final String? operationType;
  final String? link;
  final String? jobId;

  const AiChatResponse({
    this.messages = const [],
    required this.roomId,
    this.status,
    this.operationId,
    this.operationType,
    this.link,
    this.jobId,
  });

  factory AiChatResponse.fromJson(dynamic raw, {Map<String, dynamic>? meta}) {
    if (raw is! Map) {
      final rId = meta?[AiKeys.roomId]?.toString() ?? '';
      return AiChatResponse(messages: const [], roomId: rId);
    }
    final json = Map<String, dynamic>.from(raw);
    final responseMeta = meta ??
        (json[ApiKeys.meta] is Map
            ? Map<String, dynamic>.from(json[ApiKeys.meta] as Map)
            : null);

    final rawList = json[AiKeys.messages] ??
        responseMeta?[AiKeys.messages] ??
        (json[ApiKeys.data] is List ? json[ApiKeys.data] : null);

    final parsedMessages = <AiMessageModel>[];

    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map) {
          parsedMessages.add(
            AiMessageModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    } else if (json[ApiKeys.data] is Map) {
      parsedMessages.add(
        AiMessageModel.fromJson(
          Map<String, dynamic>.from(json[ApiKeys.data] as Map),
        ),
      );
    }

    final roomId = responseMeta?[AiKeys.roomId]?.toString() ??
        json[AiKeys.roomId]?.toString() ??
        (parsedMessages.isNotEmpty ? parsedMessages.first.roomId : null) ??
        '';

    return AiChatResponse(
      messages: parsedMessages,
      roomId: roomId,
      status: responseMeta?[AiKeys.status]?.toString() ??
          json[AiKeys.status]?.toString(),
      operationId: responseMeta?[AiKeys.operationId]?.toString() ??
          json[AiKeys.operationId]?.toString(),
      operationType: responseMeta?[AiKeys.operationType]?.toString() ??
          json[AiKeys.operationType]?.toString(),
      link: responseMeta?[AiKeys.link]?.toString() ??
          json[AiKeys.link]?.toString(),
      jobId: responseMeta?[AiKeys.jobId]?.toString() ??
          json[AiKeys.jobId]?.toString(),
    );
  }
}
