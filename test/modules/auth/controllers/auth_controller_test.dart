// test/modules/auth/controllers/auth_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/services/analytics.service.dart';
import 'package:rexone_mobile/services/media_download.service.dart';
import 'package:rexone_mobile/services/push_noti.service.dart';
import 'package:rexone_mobile/services/socket.service.dart';
import 'package:rexone_mobile/services/storage.service.dart';
import '../../../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthService fakeAuth;
  late FakeStorageService fakeStorage;
  late FakeAnalyticsService fakeAnalytics;
  late FakePushNotiService fakePush;
  late FakeSocketService fakeSocket;
  late FakeMediaDownloadService fakeDownloads;
  late AuthController authController;

  setUp(() {
    Get.testMode = true;
    fakeAuth = FakeAuthService();
    fakeStorage = FakeStorageService();
    fakeAnalytics = FakeAnalyticsService();
    fakePush = FakePushNotiService();
    fakeSocket = FakeSocketService();
    fakeDownloads = FakeMediaDownloadService();

    Get.put<AuthService>(fakeAuth);
    Get.put<StorageService>(fakeStorage);
    Get.put<AnalyticsService>(fakeAnalytics);
    Get.put<PushNotiService>(fakePush);
    Get.put<SocketService>(fakeSocket);
    Get.put<MediaDownloadService>(fakeDownloads);

    authController = Get.put(AuthController());
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController - Session & Status', () {
    test('initializes with unauthenticated state when storage is empty', () {
      expect(authController.isLoggedIn.value, isFalse);
      expect(authController.authToken.value, isEmpty);
      expect(authController.currentUser.value, isNull);
    });

    test('checkAuthStatus restores session when token and user are in storage', () async {
      final user = UserModel(id: 'usr_abc', email: 'rex@example.com', name: 'Rex');
      fakeAuth.currentUserResponse = ApiResponse.success(
        message: 'OK',
        statusCode: 200,
        data: user,
      );
      fakeStorage.setToken('stored_token_123');
      fakeStorage.setUserData(user);

      await authController.checkAuthStatus();

      expect(authController.isLoggedIn.value, isTrue);
      expect(authController.authToken.value, equals('stored_token_123'));
      expect(authController.currentUser.value?.id, equals('usr_abc'));
      expect(fakeSocket.lastConnectedToken, equals('stored_token_123'));
    });

    test('signOut clears local storage session, route stack, and resets state', () async {
      final user = UserModel(id: 'usr_abc', email: 'rex@example.com');
      fakeStorage.setToken('stored_token_123');
      fakeStorage.setUserData(user);
      fakeStorage.saveRouteStack(['/home', '/settings']);

      await authController.checkAuthStatus();
      expect(authController.isLoggedIn.value, isTrue);

      await authController.signOut();

      expect(authController.isLoggedIn.value, isFalse);
      expect(authController.authToken.value, isEmpty);
      expect(authController.currentUser.value, isNull);
      expect(fakeStorage.getToken(), isNull);
      expect(fakeStorage.getUserData(), isNull);
      expect(fakeStorage.getRouteStack(), isEmpty);
      expect(fakePush.userCleared, isTrue);
      expect(fakeDownloads.clearedAll, isTrue);
      expect(fakeSocket.wasDisconnected, isTrue);
      expect(fakeAnalytics.loggedEvents, contains(AnalyticsConstants.eventSignOut));
    });
  });

  group('AuthController - Email Validation', () {
    test('validates standard email correctly', () {
      authController.email.value = 'user@example.com';
      expect(authController.validateEmail(), isTrue);
      expect(authController.emailError.value, isNull);
    });

    test('rejects invalid email and sets emailError', () {
      authController.email.value = 'invalid-email';
      expect(authController.validateEmail(), isFalse);
      expect(authController.emailError.value, isNotNull);

      authController.email.value = 'test@';
      expect(authController.validateEmail(), isFalse);

      authController.email.value = ' @domain.com';
      expect(authController.validateEmail(), isFalse);
    });
  });

  group('AuthController - Peek User', () {
    test('returns exists when user exists and confirmed', () async {
      fakeAuth.peekUserResponse = ApiResponse.success(
        message: 'OK',
        statusCode: 200,
        data: PeekUserResponse(userExists: true, confirmed: true),
      );

      final status = await authController.peekUser('rex@example.com');
      expect(status, equals(EPeekedUserStatus.exists));
    });

    test('returns existsUnconfirmed when user exists but not confirmed', () async {
      fakeAuth.peekUserResponse = ApiResponse.success(
        message: 'OK',
        statusCode: 200,
        data: PeekUserResponse(userExists: true, confirmed: false),
      );

      final status = await authController.peekUser('unconfirmed@example.com');
      expect(status, equals(EPeekedUserStatus.existsUnconfirmed));
    });

    test('returns notExists when user does not exist', () async {
      fakeAuth.peekUserResponse = ApiResponse.success(
        message: 'OK',
        statusCode: 200,
        data: PeekUserResponse(userExists: false, confirmed: false),
      );

      final status = await authController.peekUser('new@example.com');
      expect(status, equals(EPeekedUserStatus.notExists));
    });

    test('returns error on network or server failure', () async {
      fakeAuth.peekUserResponse = ApiResponse.error(
        message: 'Server Error',
        statusCode: 500,
      );

      final status = await authController.peekUser('error@example.com');
      expect(status, equals(EPeekedUserStatus.error));
    });
  });

  group('AuthController - Passcode Retry State', () {
    test('loadRetryState resets attempts to maxAttempts and clears cooldown', () {
      authController.attemptsLeft.value = 1;
      authController.hasFailureHistory.value = true;
      authController.cooldownSecondsLeft.value = 30;

      authController.loadRetryState();

      expect(authController.attemptsLeft.value, equals(AuthController.maxAttempts));
      expect(authController.hasFailureHistory.value, isFalse);
      expect(authController.cooldownSecondsLeft.value, equals(0));
    });
  });
}
