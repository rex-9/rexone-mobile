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
      padding: Design.spacing.zero,
      child: Obx(() {
        final filterOptions = [
          const AppDropdownOption<String>(
            value: PaymentController.filterAll,
            label: 'All Plans',
          ),
          const AppDropdownOption<String>(
            value: PaymentController.filterSubscription,
            label: 'Subscriptions',
            icon: Icons.repeat_rounded,
          ),
          const AppDropdownOption<String>(
            value: PaymentController.filterOneTime,
            label: 'One-Time',
            icon: Icons.flash_on_rounded,
          ),
        ];

        final searchHeader = Column(
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
            SizedBox(height: Design.spacing.lg),

            // Search and Filter Bar
            AppSearchBar(
              hint: 'Search plans...',
              initialQuery: controller.searchQuery.value,
              onSearchChanged: controller.onSearchChanged,
              isSearching:
                  controller.isLoading.value && controller.items.isNotEmpty,
              filterOptions: filterOptions,
              selectedFilterId: controller.selectedFilterId,
              onFilterChanged: (id) =>
                  controller.selectFilterId(id ?? PaymentController.filterAll),
            ),
          ],
        );

        return AppPagyListView<ProductModel>(
          items: controller.products,
          isLoading: controller.isLoading.value,
          isLoadingMore: controller.isLoadingMore.value,
          hasMore: controller.hasMore,
          errorMessage: controller.errorMessage.value,
          onRefresh: controller.fetchData,
          onLoadMore: controller.loadMore,
          header: searchHeader,
          emptyMessage:
              'No products available matching your search or filters.',
          itemBuilder: (context, product, index) {
            final isLast = index == controller.products.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProductCard(context, controller, product),
                if (isLast && controller.purchases.isNotEmpty) ...[
                  SizedBox(height: Design.spacing.xxxl),
                  Text(
                    AppLocales.payment.purchases.tr,
                    style: context.typo.headline3,
                  ),
                  SizedBox(height: Design.spacing.md),
                  ...controller.purchases.map(
                    (p) => _buildPurchaseTile(context, p),
                  ),
                  SizedBox(height: Design.spacing.xxl),
                ],
              ],
            );
          },
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

          // Visual useAccess Entitlement Status Banner
          if (hasAccess) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Design.spacing.md,
                vertical: Design.spacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
                border: Border.all(
                  color: context.colors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: context.colors.success,
                    size: 20,
                  ),
                  SizedBox(width: Design.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Access Unlocked',
                          style: context.typo.bodySmall.copyWith(
                            color: context.colors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Entitlement active via useAccess',
                          style: context.typo.caption.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AppSnackbar.success(
                        'useAccess verified: Entitlement active for ${product.name}',
                      );
                    },
                    borderRadius: BorderRadius.circular(Design.spacing.radiusSmall),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Design.spacing.xs,
                        vertical: 2.0,
                      ),
                      child: Text(
                        'Verify',
                        style: context.typo.caption.copyWith(
                          color: context.colors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Design.spacing.md),
          ],

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
          text: 'Claimed (Unlocked)',
          onPressed: () {
            AppSnackbar.success(
              'useAccess verified: Free entitlement active for ${product.name}',
            );
          },
        );
      }

      return AppButton(
        text: 'Claim Now',
        onPressed: () => controller.startCheckout(product.id),
      );
    }

    // 2. Active subscription -> Unlocked button + Cancel button
    if (activeSub != null) {
      final periodEnd = activeSub.currentPeriodEnd != null
          ? AppDateTime.formatLocalDate(activeSub.currentPeriodEnd)
          : 'end of period';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            text: 'Access Unlocked 🎉',
            onPressed: () {
              AppSnackbar.success(
                'useAccess verified: Subscription active for ${product.name}',
              );
            },
          ),
          SizedBox(height: Design.spacing.sm),
          Text(
            'Renews automatically on $periodEnd',
            style: context.typo.caption,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Design.spacing.xs),
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

    // 3. Canceled (pending end of cycle) -> Unlocked + Resume button
    if (canceledSub != null) {
      final periodEnd = canceledSub.currentPeriodEnd != null
          ? AppDateTime.formatLocalDate(canceledSub.currentPeriodEnd)
          : 'end of period';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            text: 'Access Unlocked (Expiring)',
            onPressed: () {
              AppSnackbar.success(
                'useAccess verified: Access active until $periodEnd',
              );
            },
          ),
          SizedBox(height: Design.spacing.sm),
          Text(
            'Access remains active until $periodEnd',
            style: context.typo.caption.copyWith(color: Design.colors.warning),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Design.spacing.xs),
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
        onPressed: () => CheckoutBottomSheet.show(context, product),
      );
    }

    // 5. One-time purchase product with active access
    if (!product.recurring && hasAccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            text: 'Access Unlocked 🎉',
            onPressed: () {
              AppSnackbar.success(
                'useAccess verified: Lifetime entitlement active for ${product.name}',
              );
            },
          ),
          SizedBox(height: Design.spacing.xs),
          AppButton(
            type: EButtonType.secondary,
            text: 'Buy Again',
            onPressed: () => CheckoutBottomSheet.show(context, product),
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
            onPressed: () => CheckoutBottomSheet.show(context, product),
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
      onPressed: () => CheckoutBottomSheet.show(context, product),
    );
  }

  Widget _buildPurchaseTile(BuildContext context, PurchaseModel p) {
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
              Text(p.productName ?? 'Payment', style: context.typo.bodyLarge),
              if (p.createdAt != null)
                Text(
                  AppDateTime.formatLocalDate(p.createdAt),
                  style: context.typo.caption,
                ),
            ],
          ),
          AppBadge(
            text: p.paid ? 'Paid' : p.status,
            type: p.paid ? BadgeType.success : BadgeType.warning,
          ),
        ],
      ),
    );
  }
}
