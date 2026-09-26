import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/modules/feedback/data/models/feedback.model.dart';

void main() {
  group('FeedbackModel', () {
    test('parses complete feedback JSON correctly', () {
      final json = {
        FeedbackKeys.id: 'fb_100',
        FeedbackKeys.content: 'Great app experience so far!',
        FeedbackKeys.rating: 5,
        FeedbackKeys.category: 'feature_request',
        FeedbackKeys.priority: 'high',
        FeedbackKeys.status: 'in_progress',
        FeedbackKeys.platform: 'android',
        FeedbackKeys.appVersion: '1.2.0',
        FeedbackKeys.os: 'Android 14',
        FeedbackKeys.device: 'Pixel 8',
        FeedbackKeys.page: '/dashboard',
        FeedbackKeys.metadata: {'theme': 'dark', 'network': 'wifi'},
        FeedbackKeys.adminNotes: 'Reviewed by support',
        FeedbackKeys.userId: 'usr_1',
        FeedbackKeys.userName: 'Rex',
        FeedbackKeys.userEmail: 'rex@example.com',
        FeedbackKeys.createdAt: '2026-09-20T12:00:00Z',
        FeedbackKeys.updatedAt: '2026-09-21T12:00:00Z',
      };

      final feedback = FeedbackModel.fromJson(json);

      expect(feedback.id, 'fb_100');
      expect(feedback.content, 'Great app experience so far!');
      expect(feedback.rating, 5);
      expect(feedback.category, 'feature_request');
      expect(feedback.priority, 'high');
      expect(feedback.status, 'in_progress');
      expect(feedback.platform, 'android');
      expect(feedback.appVersion, '1.2.0');
      expect(feedback.device, 'Pixel 8');
      expect(feedback.page, '/dashboard');
      expect(feedback.metadata, isNotNull);
      expect(feedback.metadata?['theme'], 'dark');
      expect(feedback.userId, 'usr_1');
      expect(feedback.userName, 'Rex');
      expect(feedback.createdAt, isNotNull);
    });

    test('serializes user submission payload correctly via toJson', () {
      final feedback = FeedbackModel(
        id: 'fb_200',
        content: 'Found a minor layout glitch',
        rating: 4,
        category: 'bug',
        priority: 'medium',
        status: 'new',
        platform: 'android',
        page: '/settings',
        appVersion: '1.2.1',
        metadata: {'screen_width': 390},
      );

      final json = feedback.toJson();

      expect(json[FeedbackKeys.content], 'Found a minor layout glitch');
      expect(json[FeedbackKeys.rating], 4);
      expect(json[FeedbackKeys.page], '/settings');
      expect(json[FeedbackKeys.appVersion], '1.2.1');
      expect(json[FeedbackKeys.metadata], isA<Map>());
      expect(json.containsKey(FeedbackKeys.id), isFalse); // ID is server-generated
    });
  });
}
