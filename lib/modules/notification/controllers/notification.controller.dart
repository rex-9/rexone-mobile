// lib/modules/notification/controllers/notification.controller.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/auth/controllers/auth.controller.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/socket.service.dart';
import 'package:rexone_mobile/services/analytics.service.dart';
import '../services/notification.service.dart';

class NotificationController extends GetxController {
  late final NotificationService _service;

  // Observable state
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxString currentFilter = NotificationConstants.filterAll.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final Rxn<PaginationMeta> pagination = Rxn<PaginationMeta>();

  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    _service = Get.isRegistered<NotificationService>()
        ? Get.find<NotificationService>()
        : Get.put(NotificationService());

    fetchUnreadCount();
  }

  /// Fetch total unread count for badges
  Future<void> fetchUnreadCount() async {
    final count = await _service.getUnreadCount();
    unreadCount.value = count;
  }

  /// Fetch first page of notifications
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    _currentPage = 1;
    isLoading.value = true;

    try {
      final res = await _service.getNotifications(
        page: _currentPage,
        limit: 20,
        filter: currentFilter.value,
      );

      notifications.assignAll(res.records);
      pagination.value = res.pagination;
      hasMore.value = res.pagination?.hasNextPage ?? false;
      await fetchUnreadCount();
    } catch (e) {
      debugPrint('❌ [NotificationController] Fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load next page for infinite scroll
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    final nextPage = (pagination.value?.currentPage ?? _currentPage) + 1;

    try {
      final res = await _service.getNotifications(
        page: nextPage,
        limit: 20,
        filter: currentFilter.value,
      );

      notifications.addAll(res.records);
      pagination.value = res.pagination;
      hasMore.value = res.pagination?.hasNextPage ?? false;
      _currentPage = nextPage;
    } catch (e) {
      debugPrint('❌ [NotificationController] Load more error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Change filter ('all', 'unread', 'read')
  Future<void> changeFilter(String filter) async {
    if (currentFilter.value == filter) return;
    currentFilter.value = filter;
    await fetchNotifications(refresh: true);
  }

  /// Mark single notification as read
  Future<void> markAsRead(NotificationModel item) async {
    if (item.read) return;

    final index = notifications.indexWhere((n) => n.id == item.id);
    final updated = item.copyWith(read: true, readAt: DateTime.now());

    if (index != -1) {
      if (currentFilter.value == NotificationConstants.filterUnread) {
        notifications.removeAt(index);
      } else {
        notifications[index] = updated;
      }
    }

    unreadCount.value = max(0, unreadCount.value - 1);

    try {
      await _service.markAsRead(item.id);
    } catch (e) {
      debugPrint(
        '⚠️ [NotificationController] Failed to mark as read on server: $e',
      );
    }
  }

  /// Handles notification interactions that affect application state.
  Future<void> handleNotificationTap(NotificationModel item) async {
    if (Get.isRegistered<AnalyticsService>()) {
      Get.find<AnalyticsService>().logOpenNotification(item.id);
    }
    await markAsRead(item);

    if (item.isIamUpdated) {
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().getCurrentUser();
      }
      return;
    }

    if (item.link?.isNotEmpty ?? false) {
      await AppRoutes.handleNotificationLink(item.link);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (currentFilter.value == NotificationConstants.filterUnread) {
      notifications.clear();
    } else {
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].read) {
          notifications[i] = notifications[i].copyWith(
            read: true,
            readAt: DateTime.now(),
          );
        }
      }
    }

    unreadCount.value = 0;

    try {
      await _service.markAllAsRead();
    } catch (e) {
      debugPrint('⚠️ [NotificationController] Failed to mark all as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(NotificationModel item) async {
    notifications.removeWhere((n) => n.id == item.id);
    if (!item.read) {
      unreadCount.value = max(0, unreadCount.value - 1);
    }

    try {
      await _service.deleteNotification(item.id);
    } catch (e) {
      debugPrint(
        '⚠️ [NotificationController] Failed to delete notification: $e',
      );
    }
  }

  /// Handle incoming real-time socket notification
  void onSocketNotification(SocketMessage event) {
    if (event.clients != null &&
        !event.clients!.contains(AppConstants.platformMobile)) {
      return;
    }

    unreadCount.value++;

    if (event.data != null && event.data is Map) {
      try {
        final notiMap = <String, dynamic>{
          ApiKeys.id: event.id,
          NotificationKeys.title: event.title,
          NotificationKeys.message: event.message,
          NotificationKeys.link: event.link,
          NotificationKeys.clients: event.clients,
          NotificationKeys.data: event.data,
          NotificationKeys.createdAt: event.createdAt,
        };
        final newNotification = NotificationModel.fromJson(notiMap);

        if (currentFilter.value != NotificationConstants.filterRead) {
          // Check if already in list
          if (!notifications.any((n) => n.id == newNotification.id)) {
            notifications.insert(0, newNotification);
          }
        }
      } catch (e) {
        debugPrint('⚠️ [NotificationController] Socket parse error: $e');
      }
    }

    // Refresh count from server to stay perfectly accurate
    fetchUnreadCount();
  }
}
