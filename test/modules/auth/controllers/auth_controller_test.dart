// test/modules/auth/controllers/auth_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/modules/payment/payment.dart';
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
        data: UserPeekModel(userExists: true, confirmed: true),
      );

      final status = await authController.peekUser('rex@example.com');
      expect(status, equals(EPeekedUserStatus.exists));
    });

    test('returns existsUnconfirmed when user exists but not confirmed', () async {
      fakeAuth.peekUserResponse = ApiResponse.success(
        message: 'OK',
        statusCode: 200,
        data: UserPeekModel(userExists: true, confirmed: false),
      );

      final status = await authController.peekUser('unconfirmed@example.com');
      expect(status, equals(EPeekedUserStatus.existsUnconfirmed));
    });

    test('returns notExists when user does not exist', () async {
      fakeAuth.peekUserResponse = ApiResponse.success(
        message: 'OK',
        statusCode: 200,
        data: UserPeekModel(userExists: false, confirmed: false),
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

  group('AuthController - Product Entitlement & Access', () {
    final activeLifetime = AccessModel(
      id: 'acc_life',
      status: 'active',
      productId: 'prod_life_id',
      productCode: 'PROD_LIFE',
      productName: 'Lifetime Pass',
      active: true,
      expiresAt: null,
    );

    final activeSubscription = AccessModel(
      id: 'acc_sub',
      status: 'active',
      productId: 'prod_sub_id',
      productCode: 'PROD_SUB',
      productName: 'Monthly Subscription',
      active: true,
      expiresAt: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    );

    final expiredAccess = AccessModel(
      id: 'acc_exp',
      status: 'active',
      productId: 'prod_exp_id',
      productCode: 'PROD_EXP',
      productName: 'Expired Pass',
      active: true,
      expiresAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    );

    test('returns false when currentUser is null or has no accesses', () {
      authController.currentUser.value = null;
      expect(authController.hasAccess('prod_life_id'), isFalse);
      expect(authController.getAccess('prod_life_id'), isNull);
      expect(authController.activeAccesses, isEmpty);

      authController.currentUser.value = UserModel(id: 'u1', email: 'u1@test.com', accesses: []);
      expect(authController.hasAccess('prod_life_id'), isFalse);
      expect(authController.getAccess('prod_life_id'), isNull);
      expect(authController.activeAccesses, isEmpty);
    });

    test('hasAccess correctly verifies active entitlements by productId and productCode', () {
      authController.currentUser.value = UserModel(
        id: 'u1',
        email: 'u1@test.com',
        accesses: [activeLifetime, activeSubscription, expiredAccess],
      );

      // Match by product ID
      expect(authController.hasAccess('prod_life_id'), isTrue);
      expect(authController.hasAccess('prod_sub_id'), isTrue);

      // Match by product Code
      expect(authController.hasAccess('PROD_LIFE'), isTrue);
      expect(authController.hasAccess('PROD_SUB'), isTrue);

      // Expired access returns false
      expect(authController.hasAccess('prod_exp_id'), isFalse);
      expect(authController.hasAccess('PROD_EXP'), isFalse);

      // Unowned product returns false
      expect(authController.hasAccess('non_existent'), isFalse);
    });

    test('getAccess returns active matching AccessModel or null when expired/absent', () {
      authController.currentUser.value = UserModel(
        id: 'u1',
        email: 'u1@test.com',
        accesses: [activeLifetime, activeSubscription, expiredAccess],
      );

      final lifeById = authController.getAccess('prod_life_id');
      expect(lifeById, isNotNull);
      expect(lifeById?.id, 'acc_life');

      final subByCode = authController.getAccess('PROD_SUB');
      expect(subByCode, isNotNull);
      expect(subByCode?.id, 'acc_sub');

      expect(authController.getAccess('prod_exp_id'), isNull);
      expect(authController.getAccess('unknown_code'), isNull);
    });

    test('activeAccesses returns only currently active accesses', () {
      authController.currentUser.value = UserModel(
        id: 'u1',
        email: 'u1@test.com',
        accesses: [activeLifetime, activeSubscription, expiredAccess],
      );

      final activeList = authController.activeAccesses;
      expect(activeList.length, 2);
      expect(activeList.map((a) => a.id), containsAll(['acc_life', 'acc_sub']));
      expect(activeList.map((a) => a.id), isNot(contains('acc_exp')));
    });
  });
}
