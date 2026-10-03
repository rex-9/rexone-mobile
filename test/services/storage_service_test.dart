// test/services/storage_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/routes/routes.dart';
import '../mocks/test_services.dart';

void main() {
  group('StorageService - Continue Route (Return-After-Auth)', () {
    late FakeStorageService storage;

    setUp(() {
      storage = FakeStorageService();
    });

    test('getContinueRoute returns null initially', () {
      expect(storage.getContinueRoute(), isNull);
    });

    test('setContinueRoute persists route and can be retrieved', () {
      storage.setContinueRoute(AppRoutes.ai);
      expect(storage.getContinueRoute(), equals(AppRoutes.ai));
      expect(storage.memory[StorageKeys.continueUrl], equals(AppRoutes.ai));
    });

    test('clearContinueRoute removes stored continue route', () {
      storage.setContinueRoute(AppRoutes.profile);
      expect(storage.getContinueRoute(), equals(AppRoutes.profile));

      storage.clearContinueRoute();
      expect(storage.getContinueRoute(), isNull);
      expect(storage.memory.containsKey(StorageKeys.continueUrl), isFalse);
    });

    test('consumeContinueRoute retrieves and immediately clears the route', () {
      storage.setContinueRoute(AppRoutes.payment);

      final consumed = storage.consumeContinueRoute();
      expect(consumed, equals(AppRoutes.payment));
      expect(storage.getContinueRoute(), isNull);
    });

    test('clearSession purges continueRoute along with token and user data', () {
      storage.setToken('auth_token_xyz');
      storage.setContinueRoute(AppRoutes.notifications);

      storage.clearSession();
      expect(storage.getToken(), isNull);
      expect(storage.getContinueRoute(), isNull);
    });
  });
}
