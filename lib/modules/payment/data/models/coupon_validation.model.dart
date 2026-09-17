import 'package:rexone_mobile/constants/constants.dart';
import 'coupon.model.dart';

class CouponValidationModel {
  final bool valid;
  final int discountAmount;
  final int finalAmount;
  final int originalAmount;
  final String currency;
  final CouponModel? coupon;
  final int? remainingAttempts;
  final int? cooldownRemaining;

  CouponValidationModel({
    required this.valid,
    required this.discountAmount,
    required this.finalAmount,
    required this.originalAmount,
    required this.currency,
    this.coupon,
    this.remainingAttempts,
    this.cooldownRemaining,
  });

  bool get isFree => finalAmount == 0;

  factory CouponValidationModel.fromJson(Map<String, dynamic> json) {
    return CouponValidationModel(
      valid: json[PaymentKeys.valid] == true,
      discountAmount: json[PaymentKeys.discountAmount] is int
          ? json[PaymentKeys.discountAmount] as int
          : int.tryParse(json[PaymentKeys.discountAmount]?.toString() ?? '0') ?? 0,
      finalAmount: json[PaymentKeys.finalAmount] is int
          ? json[PaymentKeys.finalAmount] as int
          : int.tryParse(json[PaymentKeys.finalAmount]?.toString() ?? '0') ?? 0,
      originalAmount: json[PaymentKeys.originalAmount] is int
          ? json[PaymentKeys.originalAmount] as int
          : int.tryParse(json[PaymentKeys.originalAmount]?.toString() ?? '0') ?? 0,
      currency: json[PaymentKeys.currency]?.toString() ?? 'usd',
      coupon: json[PaymentKeys.coupon] is Map<String, dynamic>
          ? CouponModel.fromJson(json[PaymentKeys.coupon] as Map<String, dynamic>)
          : null,
      remainingAttempts: json[PaymentKeys.remainingAttempts] is int
          ? json[PaymentKeys.remainingAttempts] as int
          : int.tryParse(json[PaymentKeys.remainingAttempts]?.toString() ?? ''),
      cooldownRemaining: json[PaymentKeys.cooldownRemaining] is int
          ? json[PaymentKeys.cooldownRemaining] as int
          : int.tryParse(json[PaymentKeys.cooldownRemaining]?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    PaymentKeys.valid: valid,
    PaymentKeys.discountAmount: discountAmount,
    PaymentKeys.finalAmount: finalAmount,
    PaymentKeys.originalAmount: originalAmount,
    PaymentKeys.currency: currency,
    if (coupon != null) PaymentKeys.coupon: coupon!.toJson(),
    if (remainingAttempts != null)
      PaymentKeys.remainingAttempts: remainingAttempts,
    if (cooldownRemaining != null)
      PaymentKeys.cooldownRemaining: cooldownRemaining,
  };
}
