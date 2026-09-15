// lib/modules/ai/services/ai.service.dart
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

import '../data/requests/requests.dart';
import '../data/models/models.dart';

class AiService extends GetxService {
  late final ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  // ============================================================
  // CHAT
  // ============================================================
  Future<ApiResponse<Map<String, dynamic>>> chat(AiChatRequest request) async {
    final response = await _api.post(
      ServerRoutes.aiChat,
      request.toJson(),
      showLoading: false,
    );
    return _api.parseResponse<Map<String, dynamic>>(
      response,
      (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  // ============================================================
  // HISTORY
  // ============================================================
  Future<PaginatedResponse<AiMessageModel>> getHistory({
    String? roomId,
  }) async {
    final query = <String, dynamic>{};
    if (roomId != null && roomId.isNotEmpty) query[AiKeys.roomId] = roomId;
    final response = await _api.get(ServerRoutes.aiHistory, query: query);
    return _api.parsePaginatedResponse(
      response,
      (data) => AiMessageModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<ApiResponse<dynamic>> clearHistory({String? roomId}) async {
    final query = <String, dynamic>{};
    if (roomId != null && roomId.isNotEmpty) query[AiKeys.roomId] = roomId;
    final response = await _api.delete(ServerRoutes.aiClear, query: query);
    return _api.parseResponse(response, (data) => data);
  }

  // ============================================================
  // ROOMS
  // ============================================================
  Future<PaginatedResponse<AiRoomModel>> getRooms({int? page, int? limit}) async {
    final query = <String, dynamic>{};
    if (page != null) query[ApiKeys.page] = page.toString();
    if (limit != null) query[ApiKeys.limit] = limit.toString();
    final response = await _api.get(ServerRoutes.aiRooms, query: query);
    return _api.parsePaginatedResponse<AiRoomModel>(
      response,
      (data) => AiRoomModel.fromJson(data),
    );
  }

  Future<ApiResponse<AiRoomModel>> createRoom(CreateRoomRequest request) async {
    final response = await _api.post(ServerRoutes.aiRooms, request.toJson());
    return _api.parseResponse<AiRoomModel>(response, (data) {
      final record = data is Map && data[AiKeys.room] is Map
          ? data[AiKeys.room]
          : data;
      return ApiHelper.parseRecord<AiRoomModel>(record, AiRoomModel.fromJson) ??
          AiRoomModel.fromJson(const {});
    });
  }

  Future<ApiResponse<AiRoomModel>> renameRoom(String roomId, String title) async {
    final response = await _api.put(
      ServerRoutes.aiRename(roomId),
      {'title': title},
    );
    return _api.parseResponse<AiRoomModel>(response, (data) {
      final record = data is Map && data[AiKeys.room] is Map
          ? data[AiKeys.room]
          : data;
      return ApiHelper.parseRecord<AiRoomModel>(record, AiRoomModel.fromJson) ??
          AiRoomModel.fromJson(const {});
    });
  }

  Future<ApiResponse<dynamic>> deleteRoom(String roomId) async {
    final response = await _api.delete(ServerRoutes.aiDeleteRoom(roomId));
    return _api.parseResponse(response, (data) => data);
  }
}
