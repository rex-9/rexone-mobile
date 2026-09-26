import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/modules/payment/data/models/models.dart';

void main() {
  group('CouponModel', () {
    test('parses percentage coupon correctly', () {
      final json = {
        'id': 'coupon_1',
        'title': 'Summer Promo',
        'description': '20% discount on all courses',
        'code': 'SUMMER20',
        'coupon_type': 'percentage',
        'amount': 20,
        'currency': 'usd',
        'max_usage': 100,
        'max_usage_per_user': 1,
        'used_count': 5,
        'expires_at': '2026-12-31T23:59:59Z',
        'referrer_id': 'user_ref_1',
        'target_role_ids': ['role_1'],
        'target_user_ids': ['user_1'],
        'target_product_ids': ['prod_1'],
        'active': true,
        'exhausted': false,
        'expired': false,
      };

      final coupon = CouponModel.fromJson(json);

      expect(coupon.id, 'coupon_1');
      expect(coupon.code, 'SUMMER20');
      expect(coupon.isPercentage, true);
      expect(coupon.isFixed, false);
      expect(coupon.amount, 20);
      expect(coupon.maxUsage, 100);
      expect(coupon.usedCount, 5);
      expect(coupon.active, true);
      expect(coupon.exhausted, false);
      expect(coupon.expired, false);
      expect(coupon.targetRoleIds, ['role_1']);
    });

    test('parses fixed amount coupon correctly', () {
      final json = {
        'id': 'coupon_2',
        'title': '\$10 Off',
        'code': 'FIXED10',
        'coupon_type': 'fixed',
        'amount': 1000,
        'currency': 'usd',
        'max_usage': 0,
        'max_usage_per_user': 2,
        'used_count': 50,
        'active': true,
      };

      final coupon = CouponModel.fromJson(json);

      expect(coupon.id, 'coupon_2');
      expect(coupon.code, 'FIXED10');
      expect(coupon.isPercentage, false);
      expect(coupon.isFixed, true);
      expect(coupon.amount, 1000);
      expect(coupon.maxUsage, 0);
    });
  });

  group('CouponValidationModel', () {
    test('parses successful validation with 100% free access', () {
      final json = {
        'valid': true,
        'discount_amount': 2900,
        'final_amount': 0,
        'original_amount': 2900,
        'currency': 'usd',
        'coupon': {
          'id': 'coupon_free',
          'title': '100% Free VIP',
          'code': 'FREEVIP',
          'coupon_type': 'percentage',
          'amount': 100,
          'max_usage': 10,
          'max_usage_per_user': 1,
          'used_count': 0,
          'target_role_ids': [],
          'target_user_ids': [],
          'target_product_ids': [],
          'active': true,
          'exhausted': false,
          'expired': false,
        },
      };

      final validation = CouponValidationModel.fromJson(json);

      expect(validation.valid, true);
      expect(validation.discountAmount, 2900);
      expect(validation.finalAmount, 0);
      expect(validation.isFree, true);
      expect(validation.code, 'FREEVIP');
      expect(validation.coupon, isNotNull);
      expect(validation.coupon!.id, 'coupon_free');
    });

    test('parses partial discount validation', () {
      final json = {
        'valid': true,
        'discount_amount': 500,
        'final_amount': 2400,
        'original_amount': 2900,
        'currency': 'usd',
        'coupon': {
          'id': 'coupon_save500',
          'title': 'Save 500',
          'code': 'SAVE500',
          'coupon_type': 'fixed',
          'amount': 500,
          'max_usage': 100,
          'max_usage_per_user': 1,
          'used_count': 10,
          'target_role_ids': [],
          'target_user_ids': [],
          'target_product_ids': [],
          'active': true,
          'exhausted': false,
          'expired': false,
        },
      };

      final validation = CouponValidationModel.fromJson(json);

      expect(validation.valid, true);
      expect(validation.discountAmount, 500);
      expect(validation.finalAmount, 2400);
      expect(validation.isFree, false);
      expect(validation.code, 'SAVE500');
    });

    test('serializes to json correctly including nested coupon', () {
      final model = CouponValidationModel(
        valid: true,
        discountAmount: 500,
        finalAmount: 2400,
        originalAmount: 2900,
        currency: 'usd',
        coupon: const CouponModel(
          id: 'c_val_1',
          title: 'Discount',
          code: 'DISCOUNT',
          couponType: CouponTypes.fixed,
          amount: 500,
          currency: 'usd',
          maxUsage: 10,
          maxUsagePerUser: 1,
          usedCount: 0,
          targetRoleIds: [],
          targetUserIds: [],
          targetProductIds: [],
          active: true,
          exhausted: false,
          expired: false,
        ),
      );

      final json = model.toJson();

      expect(json[PaymentKeys.valid], true);
      expect(json[PaymentKeys.discountAmount], 500);
      expect(json[PaymentKeys.finalAmount], 2400);
      expect(json[PaymentKeys.originalAmount], 2900);
      expect(json[PaymentKeys.currency], 'usd');
      expect(json[PaymentKeys.coupon], isA<Map<String, dynamic>>());
    });
  });

  group('UserCouponModel', () {
    test('parses redemption record correctly', () {
      final json = {
        ApiKeys.id: 'uc_1',
        PaymentKeys.couponId: 'c_1',
        PaymentKeys.userId: 'u_1',
        PaymentKeys.productId: 'p_1',
        PaymentKeys.purchaseId: 'trx_1',
        PaymentKeys.purchaseType: 'trx',
        PaymentKeys.discountAmount: 500,
        PaymentKeys.originalAmount: 2000,
        PaymentKeys.finalAmount: 1500,
        PaymentKeys.currency: 'usd',
        PaymentKeys.couponCode: 'SAVE5',
        PaymentKeys.couponTitle: 'Save \$5',
        PaymentKeys.createdAt: '2026-09-16T12:00:00Z',
      };

      final userCoupon = UserCouponModel.fromJson(json);

      expect(userCoupon.id, 'uc_1');
      expect(userCoupon.couponId, 'c_1');
      expect(userCoupon.userId, 'u_1');
      expect(userCoupon.couponCode, 'SAVE5');
      expect(userCoupon.couponTitle, 'Save \$5');
      expect(userCoupon.purchaseType, PurchaseTypes.trx);
      expect(userCoupon.discountAmount, 500);
      expect(userCoupon.finalAmount, 1500);

      final encoded = userCoupon.toJson();
      expect(encoded[PaymentKeys.couponId], 'c_1');
      expect(encoded[PaymentKeys.userId], 'u_1');
      expect(encoded[PaymentKeys.couponTitle], 'Save \$5');
    });
  });
}
