// lib/modules/payment/services/payment.service.dart
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

import '../data/requests/requests.dart';
import '../data/models/models.dart';

class PaymentService extends GetxService {
  late final ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  // ============================================================
  // PRODUCTS
  // ============================================================
  Future<PaginatedResponse<ProductModel>> getProducts({
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (page != null) query[ApiKeys.page] = page.toString();
    if (limit != null) query[ApiKeys.limit] = limit.toString();
    final response = await _api.get(ServerRoutes.paymentProducts, query: query);
    return _api.parsePagyList<ProductModel>(response, ProductModel.fromJson);
  }

  // ============================================================
  // SUBSCRIPTIONS
  // ============================================================
  Future<PaginatedResponse<SubscriptionModel>> getSubscriptions({
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (page != null) query[ApiKeys.page] = page.toString();
    if (limit != null) query[ApiKeys.limit] = limit.toString();
    final response = await _api.get(
      ServerRoutes.paymentSubscriptions,
      query: query,
    );
    return _api.parsePagyList<SubscriptionModel>(
      response,
      SubscriptionModel.fromJson,
    );
  }

  Future<ApiResponse<SubscriptionModel>> cancelSubscription(
    String subscriptionId,
  ) async {
    final response = await _api.post(
      ServerRoutes.paymentSubscriptionCancel(subscriptionId),
      {},
    );
    return _api.parseRecord<SubscriptionModel>(
      response,
      SubscriptionModel.fromJson,
    );
  }

  Future<ApiResponse<SubscriptionModel>> resumeSubscription(
    String subscriptionId,
  ) async {
    final response = await _api.post(
      ServerRoutes.paymentSubscriptionResume(subscriptionId),
      {},
    );
    return _api.parseRecord<SubscriptionModel>(
      response,
      SubscriptionModel.fromJson,
    );
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================
  Future<PaginatedResponse<TransactionModel>> getTransactions({
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (page != null) query[ApiKeys.page] = page.toString();
    if (limit != null) query[ApiKeys.limit] = limit.toString();
    final response = await _api.get(
      ServerRoutes.paymentTransactions,
      query: query,
    );
    return _api.parsePagyList<TransactionModel>(
      response,
      TransactionModel.fromJson,
    );
  }

  // ============================================================
  // ACCESSES
  // ============================================================
  Future<PaginatedResponse<AccessModel>> getActiveAccesses({
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (page != null) query[ApiKeys.page] = page.toString();
    if (limit != null) query[ApiKeys.limit] = limit.toString();
    final response = await _api.get(ServerRoutes.activeAccesses, query: query);
    return _api.parsePagyList<AccessModel>(response, AccessModel.fromJson);
  }

  Future<PaginatedResponse<AccessModel>> getAccesses({
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (page != null) query[ApiKeys.page] = page.toString();
    if (limit != null) query[ApiKeys.limit] = limit.toString();
    final response = await _api.get(ServerRoutes.accesses, query: query);
    return _api.parsePagyList<AccessModel>(response, AccessModel.fromJson);
  }

  // ============================================================
  // CHECKOUT SESSION
  // ============================================================
  Future<ApiResponse<Map<String, dynamic>>> createCheckout(
    CreateCheckoutRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.paymentSession,
      request.toJson(),
    );
    return _api.parseRecord<Map<String, dynamic>>(response);
  }

  Future<ApiResponse<Map<String, dynamic>>> getSessionStatus(
    String sessionId,
  ) async {
    final response = await _api.get(
      ServerRoutes.paymentSessionStatus(sessionId),
    );
    return _api.parseRecord<Map<String, dynamic>>(response);
  }

  // ============================================================
  // COUPONS
  // ============================================================
  Future<ApiResponse<CouponValidationModel>> validateCoupon(
    String code,
    String productId,
  ) async {
    final response = await _api.post(ServerRoutes.paymentCouponsValidate, {
      PaymentKeys.code: code,
      PaymentKeys.productId: productId,
    });
    return _api.parseRecord<CouponValidationModel>(
      response,
      CouponValidationModel.fromJson,
    );
  }
}
