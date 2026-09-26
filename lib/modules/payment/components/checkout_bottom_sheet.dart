import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../controllers/payment.controller.dart';
import '../data/models/models.dart';

class CheckoutBottomSheet extends StatefulWidget {
  final ProductModel product;

  const CheckoutBottomSheet({super.key, required this.product});

  static Future<void> show(BuildContext context, ProductModel product) {
    final controller = Get.find<PaymentController>();
    controller.removeCoupon();

    return Get.bottomSheet<void>(
      CheckoutBottomSheet(product: product),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  late final TextEditingController _codeController;
  late final PaymentController _controller;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _controller = Get.find<PaymentController>();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _formatMoney(int cents, String currency) {
    if (cents == 0) return AppLocales.payment.free.tr;
    final value = cents / 100.0;
    final curr = currency.toLowerCase();
    final symbol = curr == PaymentCurrencies.mmk
        ? PaymentCurrencies.mmkSymbol
        : curr == PaymentCurrencies.sgd
        ? PaymentCurrencies.sgdSymbol
        : PaymentCurrencies.usdSymbol;
    return '$symbol${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Container(
      padding: EdgeInsets.only(
        left: Design.spacing.lg,
        right: Design.spacing.lg,
        top: Design.spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + Design.spacing.xxl,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Design.spacing.radiusXLarge),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppHandleBar(),
            SizedBox(height: Design.spacing.md),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: context.typo.headline2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                AppButton(
                  type: EButtonType.icon,
                  icon: Design.icons.close,
                  color: context.colors.textSecondary,
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            if (product.description.isNotEmpty) ...[
              SizedBox(height: Design.spacing.xs),
              Text(
                product.description,
                style: context.typo.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
            SizedBox(height: Design.spacing.lg),

            // Coupon Code Box
            Obx(() {
              final applied = _controller.appliedCoupon.value;
              final isLoading = _controller.isValidatingCoupon.value;
              final errorMsg = _controller.couponError.value;
              final cooldownLeft = _controller.couponCooldownSecondsLeft.value;
              final isCooldown = cooldownLeft > 0;
              final isButtonDisabled = isLoading || isCooldown;

              if (applied != null && applied.valid) {
                return Container(
                  padding: EdgeInsets.all(Design.spacing.md),
                  decoration: BoxDecoration(
                    color: Design.colors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      Design.spacing.radiusMedium,
                    ),
                    border: Border.all(
                      color: Design.colors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Design.icons.coupon,
                        color: Design.colors.success,
                        size: 20,
                      ),
                      SizedBox(width: Design.spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              applied.code.isNotEmpty
                                  ? applied.code
                                  : AppLocales.payment.promoCode.tr,
                              style: context.typo.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Design.colors.success,
                              ),
                            ),
                            Text(
                              AppLocales.payment.discountApplied.trParams({
                                'discount': applied.isPercentage
                                    ? '${applied.amount}%'
                                    : _formatMoney(
                                        applied.discountAmount,
                                        applied.currency,
                                      ),
                              }),
                              style: context.typo.caption.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        type: EButtonType.icon,
                        icon: Design.icons.close,
                        color: context.colors.textSecondary,
                        onPressed: () {
                          _controller.removeCoupon();
                          _codeController.clear();
                        },
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppInputField(
                          controller: _codeController,
                          hint: AppLocales.payment.promoCodeHint.tr,
                          prefixIcon: Icon(
                            Design.icons.coupon,
                            color: context.colors.textSecondary,
                            size: 20,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: () {
                            if (!isButtonDisabled &&
                                _codeController.text.trim().isNotEmpty) {
                              _controller.applyCoupon(
                                _codeController.text,
                                product.id,
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(width: Design.spacing.sm),
                      AppButton(
                        text: isLoading
                            ? AppLocales.common.loading.tr
                            : isCooldown
                            ? '${cooldownLeft}s'
                            : AppLocales.payment.apply.tr,
                        type: EButtonType.secondary,
                        onPressed: isButtonDisabled
                            ? null
                            : () {
                                if (_codeController.text.trim().isNotEmpty) {
                                  _controller.applyCoupon(
                                    _codeController.text,
                                    product.id,
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                  if (errorMsg.isNotEmpty) ...[
                    SizedBox(height: Design.spacing.xs),
                    Text(
                      errorMsg,
                      style: context.typo.caption.copyWith(
                        color: Design.colors.error,
                      ),
                    ),
                  ],
                ],
              );
            }),

            SizedBox(height: Design.spacing.lg),

            // Order Summary
            Container(
              padding: EdgeInsets.all(Design.spacing.md),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(
                  Design.spacing.radiusMedium,
                ),
              ),
              child: Obx(() {
                final applied = _controller.appliedCoupon.value;
                final originalCents =
                    applied?.originalAmount ?? product.unitAmount;
                final finalCents = applied?.finalAmount ?? product.unitAmount;
                final discountCents = applied?.discountAmount ?? 0;
                final currency = applied?.currency ?? product.currency;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocales.payment.orderSummary.tr,
                      style: context.typo.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Design.spacing.sm),

                    // Subtotal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: context.typo.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        Text(
                          _formatMoney(originalCents, currency),
                          style: context.typo.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                            decoration: discountCents > 0
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),

                    // Discount (if any)
                    if (discountCents > 0) ...[
                      SizedBox(height: Design.spacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocales.payment.discount.tr,
                            style: context.typo.bodySmall.copyWith(
                              color: Design.colors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '-${_formatMoney(discountCents, currency)}',
                            style: context.typo.bodySmall.copyWith(
                              color: Design.colors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    Divider(
                      height: Design.spacing.lg,
                      color: context.colors.divider,
                    ),

                    // Total Due
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocales.payment.totalDue.tr,
                          style: context.typo.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Text(
                          finalCents == 0
                              ? AppLocales.payment.free.tr
                              : _formatMoney(finalCents, currency),
                          style: context.typo.headline3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: finalCents == 0
                                ? Design.colors.success
                                : context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),

            SizedBox(height: Design.spacing.xl),

            // Checkout Button
            Obx(() {
              final applied = _controller.appliedCoupon.value;
              final isFree =
                  product.isFree || (applied != null && applied.isFree);

              return AppButton(
                text: isFree
                    ? AppLocales.payment.claimFreeAccess.tr
                    : AppLocales.payment.proceedToCheckout.tr,
                type: EButtonType.primary,
                isExpanded: true,
                onPressed: () {
                  Get.back();
                  _controller.startCheckout(
                    product.id,
                    couponCode: applied?.code,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
