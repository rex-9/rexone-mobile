import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';

void main() {
  test('analytics events keep the shared action_noun contract stable', () {
    expect(
      <String>[
        AnalyticsConstants.eventSignUp,
        AnalyticsConstants.eventSignIn,
        AnalyticsConstants.eventSignOut,
        AnalyticsConstants.eventBeginOnboarding,
        AnalyticsConstants.eventCompleteOnboarding,
        AnalyticsConstants.eventViewPage,
        AnalyticsConstants.eventViewProduct,
        AnalyticsConstants.eventPurchaseProduct,
        AnalyticsConstants.eventOpenNotification,
      ],
      <String>[
        'sign_up',
        'sign_in',
        'sign_out',
        'begin_onboarding',
        'complete_onboarding',
        'view_page',
        'view_product',
        'purchase_product',
        'open_notification',
      ],
    );
  });

  test('uses the shared purchase amount parameter', () {
    expect(AnalyticsConstants.paramUnitAmount, 'unit_amount');
  });
}
