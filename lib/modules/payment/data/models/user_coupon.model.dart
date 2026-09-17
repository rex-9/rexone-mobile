import 'package:rexone_mobile/constants/constants.dart';

class UserCouponModel {
  final String id;
  final String couponId;
  final String userId;
  final String productId;
  final String purchaseId;
  final String purchaseType;
  final int discountAmount;
  final int originalAmount;
  final int finalAmount;
  final String currency;
  final String? couponCode;
  final String? couponTitle;
  final String? userEmail;
  final String? productName;
  final String? createdAt;

  UserCouponModel({
    required this.id,
    required this.couponId,
    required this.userId,
    required this.productId,
    required this.purchaseId,
    required this.purchaseType,
    required this.discountAmount,
    required this.originalAmount,
    required this.finalAmount,
    required this.currency,
    this.couponCode,
    this.couponTitle,
    this.userEmail,
    this.productName,
    this.createdAt,
  });

  factory UserCouponModel.fromJson(Map<String, dynamic> json) {
    return UserCouponModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      couponId: json[PaymentKeys.couponId]?.toString() ?? '',
      userId: json[PaymentKeys.userId]?.toString() ?? '',
      productId: json[PaymentKeys.productId]?.toString() ?? '',
      purchaseId: json[PaymentKeys.purchaseId]?.toString() ?? '',
      purchaseType: json[PaymentKeys.purchaseType]?.toString() ?? PurchaseTypes.trx,
      discountAmount: json[PaymentKeys.discountAmount] is int
          ? json[PaymentKeys.discountAmount] as int
          : int.tryParse(json[PaymentKeys.discountAmount]?.toString() ?? '0') ?? 0,
      originalAmount: json[PaymentKeys.originalAmount] is int
          ? json[PaymentKeys.originalAmount] as int
          : int.tryParse(json[PaymentKeys.originalAmount]?.toString() ?? '0') ?? 0,
      finalAmount: json[PaymentKeys.finalAmount] is int
          ? json[PaymentKeys.finalAmount] as int
          : int.tryParse(json[PaymentKeys.finalAmount]?.toString() ?? '0') ?? 0,
      currency: json[PaymentKeys.currency]?.toString() ?? 'usd',
      couponCode: json[PaymentKeys.couponCode]?.toString(),
      couponTitle: json[PaymentKeys.couponTitle]?.toString(),
      userEmail: json[PaymentKeys.userEmail]?.toString(),
      productName: json[PaymentKeys.productName]?.toString(),
      createdAt: json[PaymentKeys.createdAt]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    PaymentKeys.couponId: couponId,
    PaymentKeys.userId: userId,
    PaymentKeys.productId: productId,
    PaymentKeys.purchaseId: purchaseId,
    PaymentKeys.purchaseType: purchaseType,
    PaymentKeys.discountAmount: discountAmount,
    PaymentKeys.originalAmount: originalAmount,
    PaymentKeys.finalAmount: finalAmount,
    PaymentKeys.currency: currency,
    PaymentKeys.couponCode: couponCode,
    PaymentKeys.couponTitle: couponTitle,
    PaymentKeys.userEmail: userEmail,
    PaymentKeys.productName: productName,
    PaymentKeys.createdAt: createdAt,
  };
}
