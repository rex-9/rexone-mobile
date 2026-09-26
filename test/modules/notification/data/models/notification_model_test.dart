import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/modules/notification/data/models/notification.model.dart';
import 'package:rexone_mobile/services/services.dart';

void main() {
  group('NotificationModel', () {
    test('parses from flat JSON map correctly', () {
      final json = {
        'id': 'notif-123',
        'title': 'Welcome to RexOne',
        'message': 'We are glad to have you here.',
        'link': '/dashboard',
        'metadata': {'type': 'welcome'},
        'read': false,
        'read_at': null,
        'template_id': 'tpl-welcome',
        'created_at': '2026-09-05T10:00:00.000Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, 'notif-123');
      expect(model.title, 'Welcome to RexOne');
      expect(model.message, 'We are glad to have you here.');
      expect(model.link, '/dashboard');
      expect(model.metadata['type'], 'welcome');
      expect(model.read, false);
      expect(model.readAt, isNull);
      expect(model.notificationId, 'tpl-welcome');
      expect(model.templateId, 'tpl-welcome');
      expect(model.createdAt, isNotNull);
    });

    test('parses notification_id directly from JSON attributes with ApiService.flattenRecord', () {
      final json = ApiService.flattenRecord({
        'id': 'notif-999',
        'attributes': {
          'title': 'New Feature',
          'message': 'Check out our new AI tools.',
          'notification_id': 'notif-def-456',
          'read': false,
          'created_at': '2026-09-05T10:00:00.000Z',
        },
      });

      final model = NotificationModel.fromJson(json);

      expect(model.id, 'notif-999');
      expect(model.notificationId, 'notif-def-456');
      expect(model.templateId, 'notif-def-456');
    });

    test('parses from JSONAPI style attributes correctly with ApiService.flattenRecord', () {
      final json = ApiService.flattenRecord({
        'id': 'notif-456',
        'type': 'user_notifications',
        'attributes': {
          'title': 'Payment Received',
          'message': 'Your invoice has been paid.',
          'link': '/payment',
          'metadata': {'amount': 99.99},
          'read': true,
          'read_at': '2026-09-05T10:30:00.000Z',
          'notification_id': null,
          'created_at': '2026-09-05T10:00:00.000Z',
        },
      });

      final model = NotificationModel.fromJson(json);

      expect(model.id, 'notif-456');
      expect(model.title, 'Payment Received');
      expect(model.message, 'Your invoice has been paid.');
      expect(model.link, '/payment');
      expect(model.metadata['amount'], 99.99);
      expect(model.read, true);
      expect(model.readAt, isNotNull);
      expect(model.notificationId, isNull);
      expect(model.templateId, isNull);
    });

    test('toJson serializes correctly and round trips', () {
      final model = NotificationModel(
        id: 'notif-789',
        title: 'System Update',
        message: 'Maintenance scheduled.',
        link: null,
        metadata: {'scope': 'all'},
        read: false,
        createdAt: DateTime.parse('2026-09-05T10:00:00.000Z'),
      );

      final json = model.toJson();

      expect(json['id'], 'notif-789');
      expect(json['title'], 'System Update');
      expect(json['message'], 'Maintenance scheduled.');
      expect(json['read'], false);
      expect(json['metadata'], {'scope': 'all'});

      final reconstructed = NotificationModel.fromJson(json);
      expect(reconstructed.id, model.id);
      expect(reconstructed.title, model.title);
      expect(reconstructed.message, model.message);
      expect(reconstructed.read, model.read);
    });

    test('copyWith creates modified copy preserving other fields', () {
      final original = NotificationModel(
        id: 'notif-abc',
        title: 'Original Title',
        message: 'Original Message',
        read: false,
        createdAt: DateTime.parse('2026-09-05T10:00:00.000Z'),
      );

      final modified = original.copyWith(
        read: true,
        readAt: DateTime.parse('2026-09-05T10:15:00.000Z'),
      );

      expect(modified.id, original.id);
      expect(modified.title, original.title);
      expect(modified.message, original.message);
      expect(modified.read, true);
      expect(modified.readAt, isNotNull);
    });
  });
}
