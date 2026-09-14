// lib/constants/json_keys/payment.keys.dart
/// Request/response keys for payment, product, subscription, and transaction payloads.
class PaymentKeys {
  const PaymentKeys._();

  // ===== Checkout session =====
  static const checkoutUrl = 'checkout_url';
  static const productId = 'product_id';
  static const successUrl = 'success_url';
  static const cancelUrl = 'cancel_url';
  static const freeAccessGranted = 'free_access_granted';
  static const accessId = 'access_id';

  // ===== Product =====
  static const name = 'name';
  static const description = 'description';
  static const price = 'price';
  static const unitAmount = 'unit_amount';
  static const currency = 'currency';
  static const periodLabel = 'period_label';
  static const recurring = 'recurring';
  static const active = 'active';
  static const free = 'free';

  // ===== Subscription =====
  static const status = 'status';
  static const stripeSubscriptionItemId = 'stripe_subscription_item_id';
  static const stripePriceId = 'stripe_price_id';
  static const quantity = 'quantity';
  static const interval = 'interval';
  static const intervalCount = 'interval_count';
  static const currentPeriodStart = 'current_period_start';
  static const currentPeriodEnd = 'current_period_end';
  static const startedAt = 'started_at';
  static const endedAt = 'ended_at';
  static const canceledAt = 'canceled_at';
  static const canceled = 'canceled';
  static const scheduledForCancellation = 'scheduled_for_cancellation';
  static const productName = 'product_name';

  // ===== Access =====
  static const grantedAt = 'granted_at';
  static const expiresAt = 'expires_at';
  static const revokedAt = 'revoked_at';
  static const expiredAt = 'expired_at';
  static const daysRemaining = 'days_remaining';

  // ===== Transaction =====
  static const paid = 'paid';
  static const createdAt = 'created_at';
}
