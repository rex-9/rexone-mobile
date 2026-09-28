// test/controllers/socket_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/controllers/socket.controller.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/modules/notification/notification.dart';
import 'package:rexone_mobile/services/services.dart';
import '../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSocketService fakeSocket;
  late FakeSpeechService fakeSpeech;
  late FakeNotificationService fakeNotiService;
  late NotificationController notiController;
  late SocketController socketController;

  setUp(() {
    Get.testMode = true;
    fakeSocket = FakeSocketService();
    fakeSpeech = FakeSpeechService();
    fakeNotiService = FakeNotificationService();

    Get.put<SocketService>(fakeSocket);
    Get.put<SpeechService>(fakeSpeech);
    Get.put<NotificationService>(fakeNotiService);

    notiController = Get.put(NotificationController());
    socketController = Get.put(SocketController());
  });

  tearDown(() {
    Get.reset();
  });

  group('SocketController', () {
    test('routes speech events to SpeechService', () async {
      final speechMessage = SocketMessage(
        type: 'speech',
        channel: SpeechKeys.channel,
        message: 'hello world',
        data: {SocketKeys.type: SpeechKeys.finalPhrase},
      );

      fakeSocket.emit(speechMessage);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(fakeSpeech.lastSpeechEvent, equals(speechMessage));
      expect(
        fakeSpeech.lastSpeechEventType,
        equals(ESpeechEventType.finalPhrase),
      );
    });

    test(
      'routes notification events to NotificationController and inserts notification',
      () async {
        fakeNotiService.unreadCount = 5;

        final notiMessage = SocketMessage(
          id: 'notif_123',
          type: SocketKeys.notification,
          title: 'Payment Success',
          message: 'Your order has been placed',
          link: '/payment',
          data: {SocketKeys.type: 'payment_success'},
          createdAt: DateTime.now().toIso8601String(),
        );

        fakeSocket.emit(notiMessage);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(
          notiController.notifications.any((n) => n.id == 'notif_123'),
          isTrue,
        );
        expect(notiController.unreadCount.value, equals(5));
      },
    );

    test('parses the complete real-time notification envelope', () {
      final message = SocketMessage.fromJson({
        ApiKeys.id: 'notif_456',
        SocketKeys.type: SocketKeys.notification,
        NotificationKeys.title: 'Payment Successful',
        SocketKeys.message: 'Your payment completed.',
        NotificationKeys.link: '/payment',
        SocketKeys.data: {
          NotificationKeys.type: NotificationConstants.paymentSuccess,
        },
        SocketKeys.createdAt: DateTime.now().toIso8601String(),
      });

      expect(message.id, 'notif_456');
      expect(message.title, 'Payment Successful');
      expect(message.message, 'Your payment completed.');
      expect(message.link, '/payment');
    });

    test('ignores non-notification frames that are not speech', () async {
      final initialUnread = notiController.unreadCount.value;

      final unknownMessage = SocketMessage(
        type: 'heartbeat_ping',
        message: 'ping',
      );

      fakeSocket.emit(unknownMessage);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(notiController.unreadCount.value, equals(initialUnread));
    });

    test('invalidates session on iam_updated, access_revoked, or session_expired event', () async {
      final fakeStorage = FakeStorageService();
      Get.put<StorageService>(fakeStorage);
      Get.put<AuthService>(FakeAuthService());
      Get.put<AnalyticsService>(FakeAnalyticsService());
      Get.put<PushNotificationService>(FakePushNotificationService());
      Get.put<MediaDownloadService>(FakeMediaDownloadService());

      final authController = Get.put(AuthController());
      authController.isLoggedIn.value = true;
      authController.authToken.value = 'dummy_token';

      final iamMessage = SocketMessage(
        type: SocketKeys.notification,
        message: 'Your roles have been updated.',
        data: {SocketKeys.type: EWsEventType.iamUpdated.value},
      );

      fakeSocket.emit(iamMessage);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(authController.isLoggedIn.value, isFalse);
      expect(authController.authToken.value, isEmpty);

      // Re-authenticate and test access_revoked
      authController.isLoggedIn.value = true;
      authController.authToken.value = 'dummy_token';

      final revokedMessage = SocketMessage(
        type: SocketKeys.notification,
        message: 'Your access has been revoked.',
        data: {SocketKeys.type: EWsEventType.accessRevoked.value},
      );

      fakeSocket.emit(revokedMessage);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(authController.isLoggedIn.value, isFalse);
      expect(authController.authToken.value, isEmpty);
    });

    test('cancels subscription on close', () {
      expect(() => socketController.onClose(), returnsNormally);
    });
  });
}
