import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import '../services/audio_player.service.dart';

/// Apple Music-style synced lyrics panel for the audio full player.
class AudioLyricsView extends StatefulWidget {
  const AudioLyricsView({super.key, required this.player});

  final AudioPlayerService player;

  @override
  State<AudioLyricsView> createState() => _AudioLyricsViewState();
}

class _AudioLyricsViewState extends State<AudioLyricsView> {
  static const _userScrollPause = Duration(seconds: 3);

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _activeLineKey = GlobalKey();

  int _lastScrolledIndex = -1;
  int? _previousActiveIndex;
  String? _trackedAssetId;
  bool _userScrolling = false;
  Timer? _userScrollResetTimer;

  @override
  void dispose() {
    _userScrollResetTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onUserScroll() {
    _userScrolling = true;
    _userScrollResetTimer?.cancel();
    _userScrollResetTimer = Timer(_userScrollPause, () {
      if (mounted) _userScrolling = false;
    });
  }

  void _resetScrollState(String? assetId) {
    if (assetId == _trackedAssetId) return;
    _trackedAssetId = assetId;
    _lastScrolledIndex = -1;
    _previousActiveIndex = null;
  }

  void _scrollToActive(int activeIndex) {
    if (_userScrolling || activeIndex < 0) return;
    if (activeIndex == _lastScrolledIndex) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = _activeLineKey.currentContext;
      if (targetContext == null) return;
      _lastScrolledIndex = activeIndex;
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.5,
        duration: Design.timers.medium,
        curve: Design.timers.easeOut,
      );
    });
  }

  void _scheduleScrollIfNeeded(int activeIndex) {
    if (activeIndex == _previousActiveIndex) return;
    final isSeekJump = _previousActiveIndex != null &&
        (activeIndex - _previousActiveIndex!).abs() > 1;
    if (isSeekJump && _userScrolling) {
      _userScrolling = false;
      _userScrollResetTimer?.cancel();
    }
    _previousActiveIndex = activeIndex;
    _scrollToActive(activeIndex);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Obx(() {
      final player = widget.player;
      final assetId = player.currentAsset?.id;
      _resetScrollState(assetId);

      if (player.lyricsLoading.value) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLoading(color: colors.primary),
              SizedBox(height: Design.spacing.md),
              Text(
                AppLocales.audio.lyricsLoading.tr,
                style: typo.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        );
      }

      final cues = player.lyrics;
      final hasError = player.lyricsError.value.isNotEmpty;

      if (hasError || cues.isEmpty) {
        final message = hasError
            ? _unavailableMessage(player.lyricsError.value)
            : AppLocales.audio.lyricsUnavailable.tr;
        return Center(
          child: Padding(
            padding: Design.spacing.paddingSymmetric(h: Design.spacing.lg),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: typo.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
        );
      }

      player.position.value;
      final activeIndex = player.activeLyricsIndex;
      _scheduleScrollIfNeeded(activeIndex);

      Widget buildCueItem(int index, SubtitleCue cue) {
        final isActive = index == activeIndex;
        final isPast = activeIndex >= 0 && index < activeIndex;

        return Padding(
          key: isActive ? _activeLineKey : null,
          padding: Design.spacing.paddingSymmetric(
            v: isActive ? Design.spacing.xxxl : Design.spacing.sm,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _userScrolling = false;
              _userScrollResetTimer?.cancel();
              _scrollToActive(index);
              player.seek(cue.start);
            },
            child: AnimatedDefaultTextStyle(
              duration: Design.timers.short,
              curve: Design.timers.easeOut,
              style: isActive
                  ? typo.headline3.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    )
                  : typo.bodyMedium.copyWith(
                      color: isPast
                          ? colors.textSecondary
                          : colors.textSecondary.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w400,
                    ),
              child: Text(
                cue.text,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: isActive ? null : 1,
                overflow: isActive ? null : TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is UserScrollNotification &&
              notification.direction != ScrollDirection.idle) {
            _onUserScroll();
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = Design.spacing.paddingSymmetric(
              h: Design.spacing.md,
              v: constraints.maxHeight * 0.42,
            );

            if (cues.length <= 250) {
              return SingleChildScrollView(
                controller: _scrollController,
                clipBehavior: Clip.none,
                padding: padding,
                child: Column(
                  children: [
                    for (var i = 0; i < cues.length; i++)
                      buildCueItem(i, cues[i]),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              scrollCacheExtent: const ScrollCacheExtent.pixels(1500),
              clipBehavior: Clip.none,
              padding: padding,
              itemCount: cues.length,
              itemBuilder: (context, index) => buildCueItem(index, cues[index]),
            );
          },
        ),
      );
    });
  }

  String _unavailableMessage(String errorCode) {
    switch (errorCode) {
      case MediaPlaybackConstants.lyricsErrorEmpty:
        return AppLocales.audio.lyricsUnavailable.tr;
      case MediaPlaybackConstants.lyricsErrorFetchFailed:
      default:
        return AppLocales.audio.lyricsLoadFailed.tr;
    }
  }
}
