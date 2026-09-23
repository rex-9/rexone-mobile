import 'package:rexone_mobile/constants/constants.dart';

class CouponModel {
  final String id;
  final String title;
  final String? description;
  final String code;
  final String couponType;
  final int amount;
  final String? currency;
  final int maxUsage;
  final int maxUsagePerUser;
  final int usedCount;
  final String? expiresAt;
  final String? referrerId;
  final List<String> targetRoleIds;
  final List<String> targetUserIds;
  final List<String> targetProductIds;
  final bool active;
  final bool exhausted;
  final bool expired;
  final Map<String, dynamic>? metadata;

  CouponModel({
    required this.id,
    required this.title,
    this.description,
    required this.code,
    required this.couponType,
    required this.amount,
    this.currency,
    required this.maxUsage,
    required this.maxUsagePerUser,
    required this.usedCount,
    this.expiresAt,
    this.referrerId,
    required this.targetRoleIds,
    required this.targetUserIds,
    required this.targetProductIds,
    required this.active,
    required this.exhausted,
    required this.expired,
    this.metadata,
  });

  bool get isPercentage => couponType == CouponTypes.percentage;
  bool get isFixed => couponType == CouponTypes.fixed;

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      title: json[PaymentKeys.title]?.toString() ?? '',
      description: json[PaymentKeys.description]?.toString(),
      code: json[PaymentKeys.code]?.toString() ?? '',
      couponType: json[PaymentKeys.couponType]?.toString() ?? CouponTypes.percentage,
      amount: json[PaymentKeys.amount] is int
          ? json[PaymentKeys.amount] as int
          : int.tryParse(json[PaymentKeys.amount]?.toString() ?? '0') ?? 0,
      currency: json[PaymentKeys.currency]?.toString(),
      maxUsage: json[PaymentKeys.maxUsage] is int
          ? json[PaymentKeys.maxUsage] as int
          : int.tryParse(json[PaymentKeys.maxUsage]?.toString() ?? '0') ?? 0,
      maxUsagePerUser: json[PaymentKeys.maxUsagePerUser] is int
          ? json[PaymentKeys.maxUsagePerUser] as int
          : int.tryParse(json[PaymentKeys.maxUsagePerUser]?.toString() ?? '1') ?? 1,
      usedCount: json[PaymentKeys.usedCount] is int
          ? json[PaymentKeys.usedCount] as int
          : int.tryParse(json[PaymentKeys.usedCount]?.toString() ?? '0') ?? 0,
      expiresAt: json[PaymentKeys.expiresAt]?.toString(),
      referrerId: json[PaymentKeys.referrerId]?.toString(),
      targetRoleIds: (json[PaymentKeys.targetRoleIds] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      targetUserIds: (json[PaymentKeys.targetUserIds] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      targetProductIds: (json[PaymentKeys.targetProductIds] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      active: json[PaymentKeys.active] != false,
      exhausted: json[PaymentKeys.exhausted] == true,
      expired: json[PaymentKeys.expired] == true,
      metadata: json[PaymentKeys.metadata] is Map
          ? Map<String, dynamic>.from(json[PaymentKeys.metadata] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    PaymentKeys.title: title,
    PaymentKeys.description: description,
    PaymentKeys.code: code,
    PaymentKeys.couponType: couponType,
    PaymentKeys.amount: amount,
    PaymentKeys.currency: currency,
    PaymentKeys.maxUsage: maxUsage,
    PaymentKeys.maxUsagePerUser: maxUsagePerUser,
    PaymentKeys.usedCount: usedCount,
    PaymentKeys.expiresAt: expiresAt,
    PaymentKeys.referrerId: referrerId,
    PaymentKeys.targetRoleIds: targetRoleIds,
    PaymentKeys.targetUserIds: targetUserIds,
    PaymentKeys.targetProductIds: targetProductIds,
    PaymentKeys.active: active,
    PaymentKeys.exhausted: exhausted,
    PaymentKeys.expired: expired,
    if (metadata != null) PaymentKeys.metadata: metadata,
  };
}
