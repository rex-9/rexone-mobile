import 'package:rexone_mobile/constants/constants.dart';

class SubscriptionModel {
  final String id;
  final String status;
  final String productId;
  final String stripeSubscriptionItemId;
  final String stripePriceId;
  final String currency;
  final int unitAmount;
  final int quantity;
  final String interval;
  final int intervalCount;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final String? startedAt;
  final String? endedAt;
  final String? canceledAt;
  final bool active;
  final bool canceled;
  final bool scheduledForCancellation;
  final String? productName;
  final String? price;
  final String? periodLabel;

  SubscriptionModel({
    required this.id,
    required this.status,
    required this.productId,
    required this.stripeSubscriptionItemId,
    required this.stripePriceId,
    required this.currency,
    required this.unitAmount,
    required this.quantity,
    required this.interval,
    required this.intervalCount,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.startedAt,
    this.endedAt,
    this.canceledAt,
    required this.active,
    required this.canceled,
    required this.scheduledForCancellation,
    this.productName,
    this.price,
    this.periodLabel,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final status = json[PaymentKeys.status]?.toString() ?? '';
    final canceledAt = json[PaymentKeys.canceledAt]?.toString();
    final endedAt = json[PaymentKeys.endedAt]?.toString();
    final active = json[PaymentKeys.active] == true || status == 'active';
    final scheduled = canceledAt != null && endedAt == null && active;

    return SubscriptionModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      status: status,
      productId: json[PaymentKeys.productId]?.toString() ?? '',
      stripeSubscriptionItemId:
          json[PaymentKeys.stripeSubscriptionItemId]?.toString() ?? '',
      stripePriceId: json[PaymentKeys.stripePriceId]?.toString() ?? '',
      currency: json[PaymentKeys.currency]?.toString() ?? '',
      unitAmount: (json[PaymentKeys.unitAmount] as num?)?.toInt() ?? 0,
      quantity: (json[PaymentKeys.quantity] as num?)?.toInt() ?? 1,
      interval: json[PaymentKeys.interval]?.toString() ?? '',
      intervalCount: (json[PaymentKeys.intervalCount] as num?)?.toInt() ?? 1,
      currentPeriodStart: json[PaymentKeys.currentPeriodStart]?.toString(),
      currentPeriodEnd: json[PaymentKeys.currentPeriodEnd]?.toString(),
      startedAt: json[PaymentKeys.startedAt]?.toString(),
      endedAt: endedAt,
      canceledAt: canceledAt,
      active: active,
      canceled: json[PaymentKeys.canceled] == true || status == 'canceled',
      scheduledForCancellation:
          json[PaymentKeys.scheduledForCancellation] == true || scheduled,
      productName: json[PaymentKeys.productName]?.toString(),
      price: json[PaymentKeys.price]?.toString(),
      periodLabel: json[PaymentKeys.periodLabel]?.toString(),
    );
  }

  bool get isActive => active;
  bool get isCanceled => canceled;
  bool get isScheduledForCancellation => scheduledForCancellation;
}
