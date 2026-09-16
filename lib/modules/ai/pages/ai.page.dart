// lib/modules/ai/pages/ai_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import '../ai.dart';

/// AI chat page. Pure [GetView] \u2014 all state and UI controllers live in
/// [AiController]. No StatefulWidget, no initState, no setState.
class AiPage extends GetView<AiController> {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppPage(
        title: controller.currentRoomTitle.value,
        showBackButton: true,
        padding: EdgeInsets.zero,
        actions: [
          AppButton(
            type: EButtonType.icon,
            icon: Design.icons.forum,
            onPressed: () => _showRoomsBottomSheet(context),
          ),
          AppButton(
            type: EButtonType.icon,
            icon: Design.icons.deleteSweep,
            onPressed: () async {
              final ok = await AppDialog.confirm(
                context: context,
                title: AppLocales.setting.clearHistoryTitle.tr,
                message: AppLocales.setting.clearHistoryConfirmMsg.tr,
                confirmLabel: AppLocales.setting.confirmClear.tr,
              );
              if (ok) controller.clearHistory();
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  controller: controller.scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.all(Design.spacing.lg),
                  itemCount:
                      controller.messages.length +
                      (controller.isProcessing.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.messages.length &&
                        controller.isProcessing.value) {
                      return _buildThinkingBubble(context);
                    }
                    return _buildMessageBubble(
                      context,
                      controller.messages[index],
                    );
                  },
                ),
              ),
            ),
            _buildInputBar(context),
          ],
        ),
      ),
    );
  }

  void _showRoomsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Design.spacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Design.spacing.radiusLarge),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocales.ai.rooms.tr, style: context.typo.headline3),
                  AppButton(
                    type: EButtonType.text,
                    text: '+ ${AppLocales.ai.newChat.tr}',
                    onPressed: () {
                      Get.back();
                      controller.createNewRoom();
                    },
                  ),
                ],
              ),
              SizedBox(height: Design.spacing.md),
              Flexible(
                child: Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.rooms.length,
                    itemBuilder: (context, index) {
                      final room = controller.rooms[index];
                      final isSelected =
                          controller.currentRoomId.value == room.id;

                      return AppListTile(
                        leading: Icon(
                          Design.icons.chat,
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.textSecondary,
                        ),
                        title: Text(
                          room.title,
                          style: context.typo.bodyLarge.copyWith(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          AppLocales.ai.messagesCount.trParams({
                            'count': '${room.messageCount}',
                          }),
                          style: context.typo.caption,
                        ),
                        trailing: AppButton(
                          type: EButtonType.icon,
                          icon: Design.icons.delete,
                          color: context.colors.error,
                          onPressed: () async {
                            final ok = await AppDialog.confirm(
                              context: context,
                              title: AppLocales.setting.deleteRoomTitle.tr,
                              message:
                                  AppLocales.setting.deleteRoomConfirmMsg.tr,
                              confirmLabel: AppLocales.setting.confirmDelete.tr,
                            );
                            if (ok) {
                              controller.deleteRoom(room.id);
                            }
                          },
                        ),
                        onTap: () {
                          Get.back();
                          controller.selectRoom(room);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMessageBubble(BuildContext context, AiMessageModel msg) {
    final isUser = msg.isUser;
    final colors = context.colors;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: Design.spacing.md),
        padding: EdgeInsets.symmetric(
          horizontal: Design.spacing.lg,
          vertical: Design.spacing.md,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? colors.primary : colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Design.spacing.radiusMedium),
            bottomLeft: Radius.circular(Design.spacing.radiusMedium),
            bottomRight: Radius.circular(Design.spacing.radiusMedium),
            topRight: Radius.circular(
              isUser ? Design.spacing.radiusSmall : Design.spacing.radiusMedium,
            ),
          ),
          border: isUser ? null : Border.all(color: colors.border),
          boxShadow: isUser
              ? Design.colors.shadows.neon
              : Design.colors.shadows.sm,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: context.typo.bodyMedium.copyWith(
                color: isUser
                    ? context.colors.colorScheme.onPrimary
                    : colors.textPrimary,
              ),
            ),
            if (msg.isFailed) ...[
              SizedBox(height: Design.spacing.xs),
              Text(
                AppLocales.ai.aiResponseFailed.tr,
                style: context.typo.caption.copyWith(color: colors.error),
              ),
            ],
            if (!isUser && msg.content.trim().isNotEmpty) ...[
              SizedBox(height: Design.spacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(() => _buildTtsButton(context, msg)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTtsButton(BuildContext context, AiMessageModel msg) {
    final colors = context.colors;
    final isActive = controller.activeTtsMessageId.value == msg.id;
    final isDisabled =
        controller.isRecording.value ||
        (controller.activeTtsMessageId.value != null && !isActive);

    if (isActive && controller.isTtsLoading.value) {
      return Padding(
        padding: EdgeInsets.all(Design.spacing.xs),
        child: const AppLoading(
          type: LoadingType.dots,
          size: LoadingSize.small,
        ),
      );
    }

    final iconColor = isDisabled
        ? colors.textMuted
        : isActive
        ? colors.primary
        : colors.textSecondary;

    final icon = isActive && !controller.isTtsLoading.value && msg.hasAudio
        ? Design.icons.stop
        : msg.hasAudio
        ? Design.icons.play
        : Design.icons.speaker;

    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: Design.spacing.xxxl,
        minHeight: Design.spacing.xxxl,
      ),
      icon: Icon(icon, size: Design.spacing.iconSmall, color: iconColor),
      onPressed: isDisabled && !isActive
          ? null
          : () => controller.speakMessage(msg),
      tooltip: AppLocales.ai.listen.tr,
    );
  }

  Widget _buildThinkingBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: Design.spacing.md),
        padding: EdgeInsets.symmetric(
          horizontal: Design.spacing.lg,
          vertical: Design.spacing.md,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocales.ai.thinking.tr,
              style: context.typo.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(width: Design.spacing.sm),
            const AppLoading(type: LoadingType.dots, size: LoadingSize.small),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Design.spacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.divider)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (!controller.isRecording.value) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(bottom: Design.spacing.sm),
                child: VoiceLevelBars(level: controller.voiceLevel.value),
              );
            }),
            Obx(() => _buildTextInputBar(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputBar(BuildContext context) {
    final isListening = controller.isRecording.value;
    final isDisabled = controller.isProcessing.value || isListening;
    final mutedColor = context.colors.textMuted;
    final activeColor = context.colors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isListening)
          IconButton(
            icon: Icon(Design.icons.close, color: context.colors.textSecondary),
            onPressed: controller.cancelListening,
            tooltip: AppLocales.ai.cancelListening.tr,
          ),
        Expanded(
          child: AppInputField(
            controller: controller.textController,
            enabled: !controller.isProcessing.value,
            readOnly: isListening,
            minLines: 1,
            maxLines: AppConstants.chatInputMaxLines,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textAlignVertical: TextAlignVertical.top,
            hint: AppLocales.ai.typeMessage.tr,
            onSubmitted: controller.handleSend,
            suffixIcon: IconButton(
              onPressed: controller.isProcessing.value
                  ? null
                  : controller.toggleListening,
              icon: Icon(
                isListening ? Design.icons.stop : Design.icons.mic,
                color: controller.isProcessing.value
                    ? mutedColor
                    : isListening
                    ? context.colors.error
                    : activeColor,
                size: Design.spacing.iconMedium,
              ),
            ),
          ),
        ),
        SizedBox(width: Design.spacing.sm),
        IconButton(
          icon: Icon(
            Design.icons.send,
            color: isDisabled ? mutedColor : activeColor,
          ),
          onPressed: isDisabled ? null : controller.handleSend,
        ),
      ],
    );
  }
}
