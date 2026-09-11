// test/modules/payment/controllers/payment_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/payment/payment.dart';
import '../../../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePaymentService fakePayment;
  late PaymentController controller;

  setUp(() {
    Get.testMode = true;
    fakePayment = FakePaymentService();
    Get.put<PaymentService>(fakePayment);
    controller = Get.put(PaymentController());
  });

  tearDown(() {
    Get.reset();
  });

  group('PaymentController - Fetch and State', () {
    test(
      'fetchData populates products, subscriptions, transactions, and accesses',
      () async {
        final mockProduct = ProductModel(
          id: 'prod_1',
          name: 'Pro Plan',
          description: 'Pro subscription',
          price: '\$19.99',
          unitAmount: 1999,
          currency: 'USD',
          interval: 'month',
          periodLabel: 'monthly',
          recurring: true,
          active: true,
        );

        final mockAccess = AccessModel(
          id: 'acc_1',
          status: 'active',
          productId: 'prod_1',
          active: true,
        );

        final mockSub = SubscriptionModel(
          id: 'sub_1',
          status: 'active',
          productId: 'prod_1',
          stripeSubscriptionItemId: 'si_1',
          stripePriceId: 'price_1',
          currency: 'usd',
          unitAmount: 1999,
          quantity: 1,
          interval: 'month',
          intervalCount: 1,
          active: true,
          canceled: false,
          scheduledForCancellation: false,
        );

        final mockTx = TransactionModel(
          id: 'tx_1',
          productId: 'prod_1',
          unitAmount: 1999,
          currency: 'USD',
          paid: true,
          status: 'succeeded',
        );

        fakePayment.productsResponse = PaginatedResponse<ProductModel>(
          records: [mockProduct],
          message: 'OK',
          statusCode: 200,
          success: true,
        );

        fakePayment.accessesResponse = PaginatedResponse<AccessModel>(
          records: [mockAccess],
          message: 'OK',
          statusCode: 200,
          success: true,
        );

        fakePayment.subscriptionsResponse =
            PaginatedResponse<SubscriptionModel>(
              records: [mockSub],
              message: 'OK',
              statusCode: 200,
              success: true,
            );

        fakePayment.transactionsResponse = PaginatedResponse<TransactionModel>(
          records: [mockTx],
          message: 'OK',
          statusCode: 200,
          success: true,
        );

        await controller.fetchData();

        expect(controller.products.length, equals(1));
        expect(controller.products.first.id, equals('prod_1'));
        expect(controller.accesses.length, equals(1));
        expect(controller.subscriptions.length, equals(1));
        expect(controller.transactions.length, equals(1));

        expect(controller.hasActiveAccess('prod_1'), isTrue);
        expect(controller.hasActiveAccess('prod_unknown'), isFalse);
        expect(controller.getActiveSubscription('prod_1'), isNotNull);
        expect(controller.getPurchaseCount('prod_1'), equals(1));
      },
    );
  });

  group('PaymentController - Actions and Socket Events', () {
    test('cancelSubscription calls service and triggers data reload', () async {
      fakePayment.cancelResponse = ApiResponse.success(
        message: 'Canceled successfully',
        statusCode: 200,
      );

      await controller.cancelSubscription('sub_1');
      expect(controller.subscriptions, isEmpty);
    });

    test('resumeSubscription calls service and triggers data reload', () async {
      fakePayment.resumeResponse = ApiResponse.success(
        message: 'Resumed successfully',
        statusCode: 200,
      );

      await controller.resumeSubscription('sub_1');
      expect(controller.subscriptions, isEmpty);
    });

    test('onSocketEvent refreshes data on paymentSuccess', () async {
      final mockProduct = ProductModel(
        id: 'prod_premium',
        name: 'Premium',
        description: 'Yearly access',
        price: '\$49.99',
        unitAmount: 4999,
        currency: 'USD',
        interval: 'year',
        periodLabel: 'yearly',
        recurring: true,
        active: true,
      );

      fakePayment.productsResponse = PaginatedResponse<ProductModel>(
        records: [mockProduct],
        message: 'OK',
        statusCode: 200,
        success: true,
      );

      await controller.onSocketEvent(EWsEventType.paymentSuccess, 'Success!');

      expect(controller.products.any((p) => p.id == 'prod_premium'), isTrue);
    });
  });
}
