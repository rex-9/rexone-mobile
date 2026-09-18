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
    return _api.parsePaginatedResponse<ProductModel>(
      response,
      (data) => ProductModel.fromJson(data),
    );
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
    return _api.parsePaginatedResponse<SubscriptionModel>(
      response,
      (data) => SubscriptionModel.fromJson(data),
    );
  }

  Future<ApiResponse<dynamic>> cancelSubscription(String subscriptionId) async {
    final response = await _api.post(
      ServerRoutes.paymentSubscriptionCancel(subscriptionId),
      {},
    );
    return _api.parseResponse(response, (data) => data);
  }

  Future<ApiResponse<dynamic>> resumeSubscription(String subscriptionId) async {
    final response = await _api.post(
      ServerRoutes.paymentSubscriptionResume(subscriptionId),
      {},
    );
    return _api.parseResponse(response, (data) => data);
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
    return _api.parsePaginatedResponse<TransactionModel>(
      response,
      (data) => TransactionModel.fromJson(data),
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
    final response = await _api.get(
      ServerRoutes.activeAccesses,
      query: query,
    );
    return _api.parsePaginatedResponse<AccessModel>(
      response,
      (data) => AccessModel.fromJson(data),
    );
  }

  Future<PaginatedResponse<AccessModel>> getAccesses({
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (page != null) query[ApiKeys.page] = page.toString();
    if (limit != null) query[ApiKeys.limit] = limit.toString();
    final response = await _api.get(
      ServerRoutes.accesses,
      query: query,
    );
    return _api.parsePaginatedResponse<AccessModel>(
      response,
      (data) => AccessModel.fromJson(data),
    );
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
    return _api.parseResponse<Map<String, dynamic>>(
      response,
      (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getSessionStatus(
    String sessionId,
  ) async {
    final response = await _api.get(
      ServerRoutes.paymentSessionStatus(sessionId),
    );
    return _api.parseResponse<Map<String, dynamic>>(
      response,
      (data) => data is Map ? Map<String, dynamic>.from(data) : {},
    );
  }

  // ============================================================
  // COUPONS
  // ============================================================
  Future<ApiResponse<CouponValidationModel>> validateCoupon(
    String code,
    String productId,
  ) async {
    final response = await _api.post(
      ServerRoutes.paymentCouponsValidate,
      {
        PaymentKeys.code: code,
        PaymentKeys.productId: productId,
      },
    );
    return _api.parseResponse<CouponValidationModel>(
      response,
      (data) => data is Map<String, dynamic>
          ? CouponValidationModel.fromJson(data)
          : CouponValidationModel.fromJson(
              Map<String, dynamic>.from(data as Map),
            ),
    );
  }
}
