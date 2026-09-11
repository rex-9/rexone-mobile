// lib/modules/payment/controllers/payment.controller.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/analytics.service.dart';

import '../payment.dart';

class PaymentController extends GetxController {
  late final PaymentService _payment;
  late final AnalyticsService _analytics;
  final Set<String> _viewedProductIds = <String>{};

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<AccessModel> accesses = <AccessModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _payment = Get.find<PaymentService>();
    _analytics = Get.find<AnalyticsService>();
  }

  @override
  void onReady() {
    super.onReady();
    fetchData();
  }

  // ============================================================
  // SOCKET EVENT HANDLER (called by SocketController)
  // ============================================================

  /// Called by [SocketController] for every inbound notification event.
  ///
  /// Payment success/failure: dismiss the checkout WebView (if open) so the
  /// user lands back on the payment page; then refresh data.
  /// The success snackbar is shown globally by [SocketController].
  ///
  /// Subscription cancel/resume: just refresh data so the card updates.
  Future<void> onSocketEvent(EWsEventType eventType, String? message) async {
    switch (eventType) {
      case EWsEventType.paymentSuccess:
      case EWsEventType.subscriptionCreated:
      case EWsEventType.subscriptionUpdated:
      case EWsEventType.paymentIntentSucceeded:
      case EWsEventType.paymentFailed:
      case EWsEventType.paymentIntentPaymentFailed:
        // Pop the checkout WebView back to the payment page.
        if (Get.currentRoute == AppRoutes.checkout) {
          Get.back();
        }
        await fetchData();
        break;
      case EWsEventType.subscriptionCanceled:
      case EWsEventType.subscriptionResumed:
        await fetchData();
        break;
      default:
        break;
    }
  }

  // ============================================================
  // DATA FETCHING
  // ============================================================

  Future<void> fetchData() async {
    try {
      await Future.wait([
        _fetchProductsWithRetry(),
        _payment.getSubscriptions().then((res) {
          if (res.success) {
            subscriptions.assignAll(res.records);
          }
        }),
        _payment.getTransactions().then((res) {
          if (res.success) {
            transactions.assignAll(res.records);
          }
        }),
        _payment.getActiveAccesses().then((res) {
          if (res.success) {
            accesses.assignAll(res.records);
          }
        }),
      ]);
    } catch (e, stk) {
      debugPrint(
        '💳 [PaymentController] Failed to fetch payment data: $e\n$stk',
      );
    }
  }

  Future<void> _fetchProductsWithRetry() async {
    var res = await _payment.getProducts();
    if (!res.success && products.isEmpty) {
      debugPrint(
        '💳 [PaymentController] getProducts failed (${res.statusCode}), retrying in 400ms...',
      );
      await Future.delayed(const Duration(milliseconds: 400));
      res = await _payment.getProducts();
    }
    debugPrint(
      '💳 [PaymentController] getProducts success=${res.success} (status ${res.statusCode}), count=${res.records.length}',
    );
    if (res.success) {
      products.assignAll(res.records);
      for (final product in res.records) {
        if (_viewedProductIds.add(product.id)) {
          _analytics.logViewProduct(
            productId: product.id,
            productName: product.name,
          );
        }
      }
    }
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> startCheckout(String productId) async {
    try {
      final response = await _payment.createCheckout(
        CreateCheckoutRequest(productId: productId),
      );
      if (response.success && response.data != null) {
        final isFreeAccessGranted =
            response.data![PaymentKeys.freeAccessGranted] == true;

        if (isFreeAccessGranted) {
          AppSnackbar.success('Free access claimed successfully! 🎉');
          await fetchData();
          return;
        }

        final checkoutUrl = response.data![PaymentKeys.checkoutUrl]?.toString();

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          // Navigate to the in-app WebView — Flutter stays in foreground so
          // the WebSocket connection is preserved throughout checkout.
          AppRoutes.toCheckout(url: checkoutUrl);
        } else {
          AppSnackbar.error(response.error ?? 'Invalid checkout response');
        }
      } else {
        AppSnackbar.error(response.error ?? response.message);
      }
    } catch (e) {
      AppSnackbar.error('Checkout failed: $e');
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      final res = await _payment.cancelSubscription(subscriptionId);
      if (res.success) {
        AppSnackbar.info(res.message);
        await fetchData();
      } else {
        AppSnackbar.error(res.error ?? res.message);
      }
    } catch (e) {
      AppSnackbar.error('Failed to cancel subscription');
    }
  }

  Future<void> resumeSubscription(String subscriptionId) async {
    try {
      final res = await _payment.resumeSubscription(subscriptionId);
      if (res.success) {
        AppSnackbar.success(res.message);
        await fetchData();
      } else {
        AppSnackbar.error(res.error ?? res.message);
      }
    } catch (e) {
      AppSnackbar.error('Failed to resume subscription');
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool hasActiveAccess(String productId) {
    return accesses.any((a) => a.productId == productId && a.active);
  }

  SubscriptionModel? getActiveSubscription(String productId) {
    try {
      return subscriptions.firstWhere(
        (s) =>
            s.productId == productId &&
            s.active &&
            !s.scheduledForCancellation &&
            s.canceledAt == null &&
            s.endedAt == null,
      );
    } catch (_) {
      return null;
    }
  }

  SubscriptionModel? getCanceledSubscription(String productId) {
    try {
      return subscriptions.firstWhere(
        (s) =>
            s.productId == productId &&
            (s.scheduledForCancellation || s.canceledAt != null) &&
            s.endedAt == null &&
            s.status != 'canceled',
      );
    } catch (_) {
      return null;
    }
  }

  SubscriptionModel? getFullyCanceledSubscription(String productId) {
    try {
      return subscriptions.firstWhere(
        (s) =>
            s.productId == productId &&
            (s.status == 'canceled' || s.endedAt != null),
      );
    } catch (_) {
      return null;
    }
  }

  int getPurchaseCount(String productId) {
    return transactions.where((t) => t.productId == productId && t.paid).length;
  }
}
