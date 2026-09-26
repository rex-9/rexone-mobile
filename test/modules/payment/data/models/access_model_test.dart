import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/modules/payment/data/models/access.model.dart';

void main() {
  group('AccessModel - JSON serialization', () {
    test('parses complete access json into AccessModel', () {
      final json = {
        ApiKeys.id: 'acc_100',
        PaymentKeys.status: 'active',
        PaymentKeys.grantedAt: '2026-01-01T00:00:00Z',
        PaymentKeys.expiresAt: '2026-12-31T23:59:59Z',
        PaymentKeys.revokedAt: null,
        PaymentKeys.expiredAt: null,
        PaymentKeys.productId: 'prod_premium',
        PaymentKeys.productCode: 'PROD_PREM',
        PaymentKeys.productName: 'Premium Pass',
        PaymentKeys.daysRemaining: 96,
        PaymentKeys.active: true,
      };

      final model = AccessModel.fromJson(json);

      expect(model.id, 'acc_100');
      expect(model.status, 'active');
      expect(model.grantedAt, '2026-01-01T00:00:00Z');
      expect(model.expiresAt, '2026-12-31T23:59:59Z');
      expect(model.revokedAt, isNull);
      expect(model.expiredAt, isNull);
      expect(model.productId, 'prod_premium');
      expect(model.productCode, 'PROD_PREM');
      expect(model.productName, 'Premium Pass');
      expect(model.daysRemaining, 96);
      expect(model.active, isTrue);
    });

    test('serializes AccessModel to JSON correctly', () {
      final model = AccessModel(
        id: 'acc_200',
        status: 'active',
        grantedAt: '2026-02-01T00:00:00Z',
        expiresAt: null,
        productId: 'prod_lifetime',
        productCode: 'LIFETIME',
        productName: 'Lifetime Access',
        daysRemaining: null,
        active: true,
      );

      final json = model.toJson();

      expect(json[ApiKeys.id], 'acc_200');
      expect(json[PaymentKeys.status], 'active');
      expect(json[PaymentKeys.grantedAt], '2026-02-01T00:00:00Z');
      expect(json[PaymentKeys.expiresAt], isNull);
      expect(json[PaymentKeys.productId], 'prod_lifetime');
      expect(json[PaymentKeys.productCode], 'LIFETIME');
      expect(json[PaymentKeys.productName], 'Lifetime Access');
      expect(json[PaymentKeys.active], isTrue);
    });
  });

  group('AccessModel - isCurrentlyActive entitlement check', () {
    test('returns true for active lifetime access (null expiresAt)', () {
      final model = AccessModel(
        id: 'acc_life',
        status: 'active',
        productId: 'prod_1',
        active: true,
        expiresAt: null,
      );

      expect(model.isCurrentlyActive, isTrue);
    });

    test('returns true for active lifetime access (empty expiresAt)', () {
      final model = AccessModel(
        id: 'acc_empty_date',
        status: 'active',
        productId: 'prod_1',
        active: true,
        expiresAt: '',
      );

      expect(model.isCurrentlyActive, isTrue);
    });

    test('returns true for active access with future expiresAt', () {
      final futureDate = DateTime.now().add(const Duration(days: 30)).toIso8601String();
      final model = AccessModel(
        id: 'acc_future',
        status: 'active',
        productId: 'prod_1',
        active: true,
        expiresAt: futureDate,
      );

      expect(model.isCurrentlyActive, isTrue);
    });

    test('returns false when expiresAt date has passed', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
      final model = AccessModel(
        id: 'acc_expired_time',
        status: 'active',
        productId: 'prod_1',
        active: true,
        expiresAt: pastDate,
      );

      expect(model.isCurrentlyActive, isFalse);
    });

    test('returns false when status is not active (e.g. revoked)', () {
      final futureDate = DateTime.now().add(const Duration(days: 30)).toIso8601String();
      final model = AccessModel(
        id: 'acc_revoked',
        status: 'revoked',
        productId: 'prod_1',
        active: true,
        expiresAt: futureDate,
      );

      expect(model.isCurrentlyActive, isFalse);
    });

    test('returns false when status is expired', () {
      final model = AccessModel(
        id: 'acc_status_expired',
        status: 'expired',
        productId: 'prod_1',
        active: true,
        expiresAt: null,
      );

      expect(model.isCurrentlyActive, isFalse);
    });

    test('returns false when active flag is false', () {
      final model = AccessModel(
        id: 'acc_flag_false',
        status: 'active',
        productId: 'prod_1',
        active: false,
        expiresAt: null,
      );

      expect(model.isCurrentlyActive, isFalse);
    });

    test('returns true when expiresAt has invalid format fallback', () {
      final model = AccessModel(
        id: 'acc_invalid_date',
        status: 'active',
        productId: 'prod_1',
        active: true,
        expiresAt: 'not-a-valid-date',
      );

      expect(model.isCurrentlyActive, isTrue);
    });
  });
}
