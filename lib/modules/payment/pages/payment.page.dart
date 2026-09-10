// lib/modules/payment/pages/payment_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';

import '../payment.dart';

class PaymentPage extends GetView<PaymentController> {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Plans & Pricing',
      showBackButton: true,
      child: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Choose Your Plan',
                  style: context.typo.headline1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Design.spacing.xs),
                Text(
                  'Select the option that works best for you',
                  style: context.typo.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Design.spacing.xxl),

                // Products List
                if (controller.products.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(Design.spacing.xl),
                      child: Text(
                        'No products available right now.',
                        style: context.typo.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...controller.products.map(
                    (product) =>
                        _buildProductCard(context, controller, product),
                  ),

                // Transactions History
                if (controller.transactions.isNotEmpty) ...[
                  SizedBox(height: Design.spacing.xxxl),
                  Text('Order History', style: context.typo.headline3),
                  SizedBox(height: Design.spacing.md),
                  ...controller.transactions.map(
                    (tx) => _buildTransactionTile(context, tx),
                  ),
                ],
                SizedBox(height: Design.spacing.xxxl),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    PaymentController controller,
    ProductModel product,
  ) {
    final isFree = product.isFree;
    final hasAccess = controller.hasActiveAccess(product.id);
    final activeSub = controller.getActiveSubscription(product.id);
    final canceledSub = controller.getCanceledSubscription(product.id);
    final fullyCanceledSub = controller.getFullyCanceledSubscription(
      product.id,
    );
    final purchaseCount = controller.getPurchaseCount(product.id);

    return AppCard(
      margin: EdgeInsets.only(bottom: Design.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(product.name, style: context.typo.headline3),
              ),
              if (isFree && hasAccess)
                AppBadge(
                  text: 'Claimed',
                  type: BadgeType.success,
                  icon: Design.icons.activeSubscription,
                )
              else if (!product.recurring && hasAccess)
                AppBadge(
                  text: 'Active',
                  type: BadgeType.success,
                  icon: Design.icons.activeSubscription,
                )
              else if (activeSub != null)
                AppBadge(
                  text: 'Active',
                  type: BadgeType.success,
                  icon: Design.icons.activeSubscription,
                )
              else if (canceledSub != null)
                AppBadge(
                  text: 'Expiring',
                  type: BadgeType.warning,
                  icon: Design.icons.scheduledCancel,
                )
              else if (fullyCanceledSub != null)
                AppBadge(
                  text: 'Ended',
                  type: BadgeType.error,
                  icon: Design.icons.canceledSubscription,
                ),
            ],
          ),
          SizedBox(height: Design.spacing.xs),
          Text(product.description, style: context.typo.bodyMedium),
          SizedBox(height: Design.spacing.lg),

          // Pricing
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                product.price,
                style: context.typo.headline1.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: Design.spacing.xs),
              Text(
                product.recurring ? '/ ${product.periodLabel}' : ' (one-time)',
                style: context.typo.bodySmall,
              ),
            ],
          ),
          SizedBox(height: Design.spacing.xl),

          // Actions
          _buildActionButtons(
            context,
            controller,
            product,
            isFree,
            hasAccess,
            activeSub,
            canceledSub,
            fullyCanceledSub,
            purchaseCount,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PaymentController controller,
    ProductModel product,
    bool isFree,
    bool hasAccess,
    SubscriptionModel? activeSub,
    SubscriptionModel? canceledSub,
    SubscriptionModel? fullyCanceledSub,
    int purchaseCount,
  ) {
    // 1. Free Product Flow
    if (isFree) {
      if (hasAccess) {
        return AppButton(
          type: EButtonType.secondary,
          text: 'Claimed',
          onPressed: null,
        );
      }

      return AppButton(
        text: 'Claim Now',
        onPressed: () => controller.startCheckout(product.id),
      );
    }

    // 2. Active subscription -> Cancel button
    if (activeSub != null) {
      final periodEnd = activeSub.currentPeriodEnd != null
          ? AppDateTime.formatLocalDate(activeSub.currentPeriodEnd)
          : 'end of period';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Renews automatically on $periodEnd',
            style: context.typo.caption,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Design.spacing.md),
          AppButton(
            type: EButtonType.secondary,
            text: 'Cancel Subscription',
            onPressed: () async {
              final ok = await AppDialog.confirm(
                context: context,
                title: AppLocales.setting.cancelSubTitle.tr,
                message: AppLocales.setting.cancelSubConfirmMsg.tr,
                confirmLabel: AppLocales.setting.cancelSubTitle.tr,
              );
              if (ok) controller.cancelSubscription(activeSub.id);
            },
          ),
        ],
      );
    }

    // 3. Canceled (pending end of cycle) -> Resume button
    if (canceledSub != null) {
      final periodEnd = canceledSub.currentPeriodEnd != null
          ? AppDateTime.formatLocalDate(canceledSub.currentPeriodEnd)
          : 'end of period';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Access remains active until $periodEnd',
            style: context.typo.caption.copyWith(color: Design.colors.warning),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Design.spacing.md),
          AppButton(
            type: EButtonType.secondary,
            text: 'Resume Subscription',
            onPressed: () => controller.resumeSubscription(canceledSub.id),
          ),
        ],
      );
    }

    // 4. Fully canceled / ended -> Subscribe again
    if (fullyCanceledSub != null) {
      return AppButton(
        text: 'Subscribe Again',
        onPressed: () => controller.startCheckout(product.id),
      );
    }

    // 5. One-time purchase product with active access
    if (!product.recurring && hasAccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            text: 'Buy Again',
            onPressed: () => controller.startCheckout(product.id),
          ),
          if (purchaseCount > 0) ...[
            SizedBox(height: Design.spacing.xs),
            Text(
              'Purchased $purchaseCount time${purchaseCount > 1 ? "s" : ""}',
              style: context.typo.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    // 6. One-time purchase product previously purchased
    if (!product.recurring && purchaseCount > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            text: 'Buy Again',
            onPressed: () => controller.startCheckout(product.id),
          ),
          SizedBox(height: Design.spacing.xs),
          Text(
            'Purchased $purchaseCount time${purchaseCount > 1 ? "s" : ""}',
            style: context.typo.caption,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // 7. Default Subscribe / Buy button
    return AppButton(
      text: product.recurring ? 'Subscribe Now' : 'Buy Now',
      onPressed: () => controller.startCheckout(product.id),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel tx) {
    return AppCard(
      margin: EdgeInsets.only(bottom: Design.spacing.sm),
      padding: EdgeInsets.symmetric(
        horizontal: Design.spacing.md,
        vertical: Design.spacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tx.productName ?? 'Payment', style: context.typo.bodyLarge),
              if (tx.createdAt != null)
                Text(
                  AppDateTime.formatLocalDate(tx.createdAt),
                  style: context.typo.caption,
                ),
            ],
          ),
          AppBadge(
            text: tx.paid ? 'Paid' : tx.status,
            type: tx.paid ? BadgeType.success : BadgeType.warning,
          ),
        ],
      ),
    );
  }
}
