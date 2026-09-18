// lib/modules/payment/controllers/checkout.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutController extends GetxController {
  late final WebViewController webController;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final url = Get.arguments?['url'] as String? ?? '';

    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => isLoading.value = true,
          onPageFinished: (_) => isLoading.value = false,
          onWebResourceError: (_) => isLoading.value = false,

          // Stripe redirects to success_url / cancel_url after payment.
          // Those point to localhost:4000 — not reachable from WebView and
          // blocked by Android cleartext rules. Pop back instead: the socket
          // event handles the actual outcome via PaymentController.
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('localhost:4000') ||
                request.url.contains('localhost:3000/payment')) {
              WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (url.isNotEmpty) {
      webController.loadRequest(Uri.parse(url));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
    }
  }
}
