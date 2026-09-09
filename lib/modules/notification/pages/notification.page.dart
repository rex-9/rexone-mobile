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

  void _handleNotificationTap(NotificationModel item) {
    _controller.handleNotificationTap(item);
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
        backgroundColor: item.read
            ? colors.surface
            : colors.primary.withValues(alpha: 0.05),
        borderColor: item.read
            ? colors.border
            : colors.primary.withValues(alpha: 0.3),
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
                        child: Text(
                          item.title,
                          style: item.read
                              ? typo.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w500,
                                )
                              : typo.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
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
                    style: typo.bodyMedium.copyWith(
                      color: item.read
                          ? colors.textSecondary
                          : colors.textPrimary,
                    ),
                  ),
                  if (item.link != null && item.link!.isNotEmpty) ...[
                    SizedBox(height: Design.spacing.sm),
                    Row(
                      children: [
                        Icon(
                          Design.icons.openLink,
                          size: 14,
                          color: colors.primary,
                        ),
                        SizedBox(width: Design.spacing.xs),
                        Text(
                          item.link!,
                          style: typo.caption.copyWith(
                            color: colors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
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
              onPressed: () {
                _controller.deleteNotification(item);
                AppSnackbar.info(AppLocales.notification.deleted.tr);
              },
            ),
          ],
        ),
      ),
    );
  }
}
