// lib/constants/json_keys/payment.keys.dart
/// Request/response keys for payment, product, coupon, subscription, and transaction payloads.
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
  static const accesses = 'accesses';
  static const productCode = 'product_code';
  static const grantedAt = 'granted_at';
  static const expiresAt = 'expires_at';
  static const revokedAt = 'revoked_at';
  static const expiredAt = 'expired_at';
  static const daysRemaining = 'days_remaining';

  // ===== Transaction =====
  static const paid = 'paid';
  static const createdAt = 'created_at';

  // ===== Coupon =====
  static const couponCode = 'coupon_code';
  static const code = 'code';
  static const title = 'title';
  static const couponType = 'coupon_type';
  static const amount = 'amount';
  static const maxUsage = 'max_usage';
  static const maxUsagePerUser = 'max_usage_per_user';
  static const usedCount = 'used_count';
  static const referrerId = 'referrer_id';
  static const targetRoleIds = 'target_role_ids';
  static const targetUserIds = 'target_user_ids';
  static const targetProductIds = 'target_product_ids';
  static const exhausted = 'exhausted';
  static const expired = 'expired';
  static const valid = 'valid';
  static const discountAmount = 'discount_amount';
  static const finalAmount = 'final_amount';
  static const coupon = 'coupon';
  static const couponId = 'coupon_id';
  static const userId = 'user_id';
  static const couponTitle = 'coupon_title';
  static const userEmail = 'user_email';
  static const purchaseId = 'purchase_id';
  static const purchaseType = 'purchase_type';
  static const originalAmount = 'original_amount';
  static const remainingAttempts = 'remaining_attempts';
  static const cooldownRemaining = 'cooldown_remaining';
  static const metadata = 'metadata';
}
