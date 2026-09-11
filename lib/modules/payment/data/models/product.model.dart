// lib/modules/payment/data/models/product.model.dart
import 'package:rexone_mobile/constants/constants.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final int unitAmount;
  final String currency;
  final String? interval;
  final String periodLabel;
  final bool recurring;
  final bool active;
  final bool free;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unitAmount,
    required this.currency,
    this.interval,
    required this.periodLabel,
    required this.recurring,
    required this.active,
    this.free = false,
  });

  bool get isFree => free || unitAmount == 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final amount = json[PaymentKeys.unitAmount] is int
        ? json[PaymentKeys.unitAmount] as int
        : int.tryParse(
                json[PaymentKeys.unitAmount]?.toString() ?? '0',
              ) ??
              0;

    return ProductModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      name: json[PaymentKeys.name]?.toString() ?? '',
      description: json[PaymentKeys.description]?.toString() ?? '',
      price: json[PaymentKeys.price]?.toString() ?? (amount == 0 ? 'Free' : '\$0.00'),
      unitAmount: amount,
      currency: json[PaymentKeys.currency]?.toString() ?? 'usd',
      interval: json[PaymentKeys.interval]?.toString(),
      periodLabel: json[PaymentKeys.periodLabel]?.toString() ?? '',
      recurring: json[PaymentKeys.recurring] == true,
      active: json[PaymentKeys.active] != false,
      free: json[PaymentKeys.free] == true || amount == 0,
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    PaymentKeys.name: name,
    PaymentKeys.description: description,
    PaymentKeys.price: price,
    PaymentKeys.unitAmount: unitAmount,
    PaymentKeys.currency: currency,
    PaymentKeys.interval: interval,
    PaymentKeys.periodLabel: periodLabel,
    PaymentKeys.recurring: recurring,
    PaymentKeys.active: active,
    PaymentKeys.free: isFree,
  };
}
