// lib/modules/notification/pages/notification.page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import '../controllers/notification.controller.dart';
import '../data/models/notification.model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final NotificationController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMore();
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  bool _isOverflowing(NotificationModel item) {
    return item.message.length > 85 ||
        item.message.contains('\n') ||
        item.title.length > 50;
  }

  Widget? _resolveBadge(NotificationModel item) {
    final typeStr = (item.metadata['type'] ??
            item.metadata['category'] ??
            item.metadata['operation_type'] ??
            '')
        .toString()
        .toLowerCase();
    if (typeStr.isEmpty) return null;

    if (typeStr.contains('error') || typeStr.contains('fail')) {
      return const AppBadge(text: 'Error', type: EBadgeVariant.error);
    }
    if (typeStr.contains('warn')) {
      return const AppBadge(text: 'Warning', type: EBadgeVariant.warning);
    }
    if (typeStr.contains('success') ||
        typeStr.contains('complete') ||
        typeStr.contains('paid')) {
      return const AppBadge(text: 'Success', type: EBadgeVariant.success);
    }
    if (typeStr.contains('marketing') || typeStr.contains('promo')) {
      return const AppBadge(text: 'Promo', type: EBadgeVariant.secondary);
    }
    if (typeStr.contains('system') ||
        typeStr.contains('iam') ||
        typeStr.contains('broadcast')) {
      return const AppBadge(text: 'System', type: EBadgeVariant.info);
    }
    return null;
  }

  void _showDetailBottomSheet(NotificationModel item) {
    final colors = context.colors;
    final typo = context.typo;
    final ctaText = item.ctaText?.isNotEmpty == true
        ? item.ctaText!
        : (item.metadata['cta_text'] as String?)?.isNotEmpty == true
            ? item.metadata['cta_text'] as String
            : AppLocales.notification.openLink.tr;
    final badge = _resolveBadge(item);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Design.spacing.radiusLarge),
          ),
          border: Border.all(color: colors.border),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Design.spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: EdgeInsets.only(bottom: Design.spacing.md),
                    decoration: BoxDecoration(
                      color: colors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (badge != null) ...[
                      badge,
                      SizedBox(width: Design.spacing.sm),
                    ],
                    const Spacer(),
                    Text(
                      _formatTimeAgo(item.createdAt),
                      style: typo.caption.copyWith(
                        color: colors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Design.spacing.sm),
                Text(
                  item.title,
                  style: typo.headline3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: Design.spacing.md),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      item.message,
                      style: typo.bodyLarge.copyWith(
                        color: colors.textPrimary.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Design.spacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: AppLocales.common.cancel.tr,
                        type: EButtonType.secondary,
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ),
                    if (item.link != null && item.link!.isNotEmpty) ...[
                      SizedBox(width: Design.spacing.md),
                      Expanded(
                        child: AppButton(
                          text: ctaText,
                          type: EButtonType.primary,
                          icon: Design.icons.openLink,
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _controller.handleNotificationTap(item);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel item) {
    if (_isOverflowing(item)) {
      _controller.markAsRead(item);
      _showDetailBottomSheet(item);
    } else {
      _controller.handleNotificationTap(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return AppPage(
      title: AppLocales.notification.title.tr,
      showBackButton: true,
      actions: [
        Obx(() {
          final hasUnread = _controller.unreadCount.value > 0;
          return AppButton(
            type: EButtonType.icon,
            icon: Design.icons.checkAll,
            tooltip: AppLocales.notification.markAllAsRead.tr,
            color: hasUnread
                ? colors.primary
                : colors.textSecondary.withValues(alpha: 0.5),
            onPressed: hasUnread
                ? () {
                    _controller.markAllAsRead();
                    AppSnackbar.success(
                      AppLocales.notification.markAllAsRead.tr,
                    );
                  }
                : null,
          );
        }),
      ],
      child: Column(
        children: [
          // ── Filter Segment Bar ──────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Design.spacing.lg,
              vertical: Design.spacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                bottom: BorderSide(color: colors.border, width: 1),
              ),
            ),
            child: Obx(
              () => Row(
                children: [
                  _buildFilterTab(
                    label: AppLocales.notification.all.tr,
                    filter: NotificationConstants.filterAll,
                    isActive:
                        _controller.currentFilter.value ==
                        NotificationConstants.filterAll,
                  ),
                  SizedBox(width: Design.spacing.sm),
                  _buildFilterTab(
                    label: AppLocales.notification.unread.tr,
                    filter: NotificationConstants.filterUnread,
                    badgeCount: _controller.unreadCount.value,
                    isActive:
                        _controller.currentFilter.value ==
                        NotificationConstants.filterUnread,
                  ),
                  SizedBox(width: Design.spacing.sm),
                  _buildFilterTab(
                    label: AppLocales.notification.read.tr,
                    filter: NotificationConstants.filterRead,
                    isActive:
                        _controller.currentFilter.value ==
                        NotificationConstants.filterRead,
                  ),
                ],
              ),
            ),
          ),

          // ── Notifications List ─────────────────────────────
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value &&
                  _controller.notifications.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: colors.primary),
                );
              }

              if (_controller.notifications.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () =>
                      _controller.fetchNotifications(refresh: true),
                  color: colors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Design.icons.bell,
                              size: 64,
                              color: colors.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            SizedBox(height: Design.spacing.md),
                            Text(
                              AppLocales.notification.empty.tr,
                              style: typo.bodyLarge.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _controller.fetchNotifications(refresh: true),
                color: colors.primary,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Design.spacing.lg,
                    vertical: Design.spacing.md,
                  ),
                  itemCount:
                      _controller.notifications.length +
                      (_controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      SizedBox(height: Design.spacing.sm),
                  itemBuilder: (context, index) {
                    if (index == _controller.notifications.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Design.spacing.lg,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      );
                    }

                    final item = _controller.notifications[index];
                    return _buildNotificationCard(context, item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required String filter,
    int? badgeCount,
    required bool isActive,
  }) {
    final colors = context.colors;
    final typo = context.typo;

    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.changeFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: Design.spacing.sm),
          decoration: BoxDecoration(
            color: isActive
                ? colors.primary.withValues(alpha: 0.15)
                : colors.surface,
            borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
            border: Border.all(
              color: isActive ? colors.primary : colors.border,
              width: isActive ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: typo.labelLarge.copyWith(
                  color: isActive ? colors.primary : colors.textSecondary,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (badgeCount != null && badgeCount > 0) ...[
                SizedBox(width: Design.spacing.xs),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Design.spacing.xs + 2,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(
                      Design.spacing.radiusMedium,
                    ),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: typo.caption.copyWith(
                      color: colors.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel item) {
    final colors = context.colors;
    final typo = context.typo;

    return Dismissible(
      key: Key('notif_${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await AppDialog.confirm(
          context: context,
          title: AppLocales.notification.deleteTitle.tr,
          message: AppLocales.notification.deleteConfirm.tr,
          confirmLabel: AppLocales.common.delete.tr,
        );
      },
      onDismissed: (_) {
        _controller.deleteNotification(item);
        AppSnackbar.info(AppLocales.notification.deleted.tr);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: Design.spacing.xl),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
        ),
        child: Icon(Design.icons.delete, color: colors.onError),
      ),
      child: AppCard(
        padding: EdgeInsets.all(Design.spacing.md),
        backgroundColor: colors.surface,
        borderColor: item.read
            ? colors.border
            : colors.primary.withValues(alpha: 0.25),
        onTap: () => _handleNotificationTap(item),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread Dot or Icon
            Container(
              margin: EdgeInsets.only(
                top: Design.spacing.xs,
                right: Design.spacing.md,
              ),
              child: item.read
                  ? Icon(
                      Design.icons.bell,
                      size: 20,
                      color: colors.textSecondary.withValues(alpha: 0.6),
                    )
                  : Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        boxShadow: Design.colors.shadows.neon,
                      ),
                    ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_resolveBadge(item) != null) ...[
                              _resolveBadge(item)!,
                              SizedBox(height: Design.spacing.xs),
                            ],
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: item.read
                                  ? typo.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colors.textSecondary,
                                    )
                                  : typo.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Design.spacing.sm),
                      Text(
                        _formatTimeAgo(item.createdAt),
                        style: typo.caption.copyWith(
                          color: colors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Design.spacing.xs),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typo.bodyMedium.copyWith(
                      color: item.read
                          ? colors.textSecondary
                          : colors.textPrimary,
                    ),
                  ),
                  if (_isOverflowing(item)) ...[
                    SizedBox(height: Design.spacing.xs),
                    Text(
                      AppLocales.notification.readMore.tr,
                      style: typo.caption.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (!_isOverflowing(item) &&
                      item.link != null &&
                      item.link!.isNotEmpty) ...[
                    SizedBox(height: Design.spacing.sm),
                    AppButton(
                      text: item.ctaText?.isNotEmpty == true
                          ? item.ctaText!
                          : (item.metadata['cta_text'] as String?)?.isNotEmpty == true
                              ? item.metadata['cta_text'] as String
                              : AppLocales.notification.openLink.tr,
                      type: EButtonType.secondary,
                      icon: Design.icons.openLink,
                      onPressed: () => _controller.handleNotificationTap(item),
                    ),
                  ],
                ],
              ),
            ),

            // Delete Action
            IconButton(
              icon: Icon(
                Design.icons.close,
                size: 16,
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: AppLocales.common.delete.tr,
              onPressed: () async {
                final confirmed = await AppDialog.confirm(
                  context: context,
                  title: AppLocales.notification.deleteTitle.tr,
                  message: AppLocales.notification.deleteConfirm.tr,
                  confirmLabel: AppLocales.common.delete.tr,
                );
                if (confirmed) {
                  _controller.deleteNotification(item);
                  AppSnackbar.info(AppLocales.notification.deleted.tr);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
