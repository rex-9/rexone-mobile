import 'package:rexone_mobile/constants/constants.dart';

class CreateCheckoutRequest {
  final String productId;
  final String? successUrl;
  final String? cancelUrl;
  final String? couponCode;

  const CreateCheckoutRequest({
    required this.productId,
    this.successUrl,
    this.cancelUrl,
    this.couponCode,
  });

  Map<String, dynamic> toJson() => {
    PaymentKeys.productId: productId,
    PaymentKeys.successUrl: ?successUrl,
    PaymentKeys.cancelUrl: ?cancelUrl,
    PaymentKeys.couponCode: ?couponCode,
  };
}
