// test/modules/notification/notification_constants_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/routes/routes.dart';

void main() {
  group('Notification Constants & Routes', () {
    test('NotificationKeys contains expected keys', () {
      expect(NotificationKeys.title, 'title');
      expect(NotificationKeys.message, 'message');
      expect(NotificationKeys.link, 'link');
      expect(NotificationKeys.data, 'data');
      expect(NotificationKeys.read, 'read');
      expect(NotificationKeys.readAt, 'read_at');
      expect(NotificationKeys.notificationId, 'notification_id');
      expect(NotificationKeys.templateId, 'template_id');
      expect(NotificationKeys.createdAt, 'created_at');
      expect(NotificationKeys.unreadCount, 'unread_count');
      expect(NotificationKeys.filter, 'filter');
      expect(NotificationKeys.updatedCount, 'updated_count');
    });

    test('NotificationConstants contains filters and socket types', () {
      expect(NotificationConstants.filterAll, 'all');
      expect(NotificationConstants.filterUnread, 'unread');
      expect(NotificationConstants.filterRead, 'read');
      expect(NotificationConstants.allFilters, ['all', 'unread', 'read']);
      expect(NotificationConstants.paymentSuccess, 'payment_success');
      expect(NotificationConstants.assetCompressed, 'asset_compressed');
      expect(NotificationConstants.signInAlert, 'sign_in_alert');
    });

    test('ServerRoutes includes correct notification endpoints', () {
      expect(ServerRoutes.notifications, '/v1/notifications');
      expect(
        ServerRoutes.unreadNotificationsCount,
        '/v1/notifications/unread_count',
      );
      expect(
        ServerRoutes.readNotification('123'),
        '/v1/notifications/123/read',
      );
      expect(ServerRoutes.readAllNotifications, '/v1/notifications/read_all');
      expect(ServerRoutes.deleteNotification('456'), '/v1/notifications/456');
      expect(ServerRoutes.adminNotifications, '/v1/admin/notifications');
      expect(
        ServerRoutes.adminNotificationsDispatch,
        '/v1/admin/notifications/dispatch',
      );
    });

    test('AppRoutes includes notifications route', () {
      expect(AppRoutes.notifications, '/notifications');
    });

    test('recognizes only absolute HTTPS links as external', () {
      expect(
        AppRoutes.isExternalNotificationLink('https://example.com/post'),
        isTrue,
      );
      expect(
        AppRoutes.isExternalNotificationLink('http://example.com/post'),
        isFalse,
      );
      expect(AppRoutes.isExternalNotificationLink('/profile'), isFalse);
    });

    test(
      'notification links resolve to native routes without external fallback',
      () {
        expect(AppRoutes.resolveNotificationRoute('/home'), AppRoutes.home);
        expect(
          AppRoutes.resolveNotificationRoute('/profile'),
          AppRoutes.profile,
        );
        expect(
          AppRoutes.resolveNotificationRoute('/payment/subscriptions'),
          AppRoutes.payment,
        );
        expect(
          AppRoutes.resolveNotificationRoute('/ai?room_id=room-1'),
          '/ai?room_id=room-1',
        );
        expect(
          AppRoutes.resolveNotificationRoute('/admin/assets/asset-1'),
          isNull,
        );
        expect(
          AppRoutes.resolveNotificationRoute('https://example.com/settings'),
          isNull,
        );
        expect(
          AppRoutes.resolveNotificationRoute('https://example.com/profile'),
          isNull,
        );
        expect(AppRoutes.resolveNotificationRoute(null), isNull);
      },
    );

    test(
      'EWsEventType includes all notification and lifecycle event types',
      () {
        expect(
          EWsEventType.fromString('in_app_notification'),
          EWsEventType.inAppNotification,
        );
        expect(
          EWsEventType.fromString('asset_compressed'),
          EWsEventType.assetCompressed,
        );
        expect(
          EWsEventType.fromString('asset_compressing'),
          EWsEventType.assetCompressing,
        );
        expect(
          EWsEventType.fromString('asset_compression_failed'),
          EWsEventType.assetCompressionFailed,
        );
        expect(
          EWsEventType.fromString('sign_in_alert'),
          EWsEventType.signInAlert,
        );
        expect(
          EWsEventType.fromString('subscription_resumed'),
          EWsEventType.subscriptionResumed,
        );
      },
    );
  });
}
