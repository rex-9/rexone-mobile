// lib/modules/notification/services/notification.service.dart
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

class NotificationService extends GetxService {
  late final ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  /// Fetch paginated notifications with optional filter ('all', 'unread', 'read')
  Future<PaginatedResponse<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String filter = NotificationConstants.filterAll,
  }) async {
    final query = <String, dynamic>{
      ApiKeys.page: page.toString(),
      ApiKeys.limit: limit.toString(),
    };

    if (filter != NotificationConstants.filterAll) {
      query[NotificationKeys.filter] = filter;
    }

    final response = await _api.get(
      ServerRoutes.notifications,
      query: query,
      showLoading: false,
    );

    return _api.parsePagyList<NotificationModel>(
      response,
      NotificationModel.fromJson,
    );
  }

  /// Fetch total unread notification count for badge
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get(
        ServerRoutes.unreadNotificationsCount,
        showLoading: false,
      );

      final res = _api.parseRecord<Map<String, dynamic>>(response);

      if (res.success && res.data != null) {
        return (res.data![NotificationKeys.unreadCount] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Mark single notification as read
  Future<ApiResponse<NotificationModel>> markAsRead(String id) async {
    final response = await _api.put(
      ServerRoutes.readNotification(id),
      {},
      showLoading: false,
    );

    return _api.parseRecord<NotificationModel>(
      response,
      NotificationModel.fromJson,
    );
  }

  /// Mark all user notifications as read
  Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() async {
    final response = await _api.put(
      ServerRoutes.readAllNotifications,
      {},
      showLoading: false,
    );

    return _api.parseRecord<Map<String, dynamic>>(response);
  }

  /// Delete an individual notification
  Future<ApiResponse<void>> deleteNotification(String id) async {
    final response = await _api.delete(
      ServerRoutes.deleteNotification(id),
      showLoading: false,
    );

    return _api.parseRecord<void>(response);
  }
}
