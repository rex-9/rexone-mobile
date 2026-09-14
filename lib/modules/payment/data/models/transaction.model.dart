import 'package:rexone_mobile/constants/constants.dart';

class TransactionModel {
  final String id;
  final String? productId;
  final int unitAmount;
  final String currency;
  final bool paid;
  final String status;
  final String? productName;
  final String? createdAt;

  TransactionModel({
    required this.id,
    this.productId,
    required this.unitAmount,
    required this.currency,
    required this.paid,
    required this.status,
    this.productName,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      productId: json[PaymentKeys.productId]?.toString(),
      unitAmount: json[PaymentKeys.unitAmount] is int
          ? json[PaymentKeys.unitAmount] as int
          : int.tryParse(
                  json[PaymentKeys.unitAmount]?.toString() ?? '0',
                ) ??
                0,
      currency: json[PaymentKeys.currency]?.toString() ?? 'usd',
      paid:
          json[PaymentKeys.paid] == true ||
          json[PaymentKeys.status] == 'succeeded',
      status: json[PaymentKeys.status]?.toString() ?? '',
      productName: json[PaymentKeys.productName]?.toString(),
      createdAt: json[PaymentKeys.createdAt]?.toString(),
    );
  }
}
