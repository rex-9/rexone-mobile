import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/design.dart';

import '../services/video_player.service.dart';
import 'video_bottom_sheet.dart';
import 'video_settings_speed_panel.dart';
import 'video_settings_volume_panel.dart';
import 'video_sheet_header.dart';
import 'video_sheet_option.dart';

enum _SettingsPanel { main, speed, volume }

/// YouTube-style dark settings sheet for playback speed and volume.
class VideoSettingsSheet {
  const VideoSettingsSheet._();

  static Future<void> show(
    BuildContext context,
    VideoPlayerService player,
  ) {
    return VideoBottomSheet.show(
      context,
      child: _VideoSettingsSheetBody(player: player),
    );
  }
}

class _VideoSettingsSheetBody extends StatefulWidget {
  const _VideoSettingsSheetBody({required this.player});

  final VideoPlayerService player;

  @override
  State<_VideoSettingsSheetBody> createState() =>
      _VideoSettingsSheetBodyState();
}

class _VideoSettingsSheetBodyState extends State<_VideoSettingsSheetBody> {
  _SettingsPanel _panel = _SettingsPanel.main;
  late double _volume = widget.player.volume;

  String _speedLabel(double rate) {
    if (rate == 1.0) return AppLocales.video.speedNormal.tr;
    final text = rate.toStringAsFixed(2);
    return '${text.replaceAll(RegExp(r'\.?0+$'), '')}x';
  }

  String _percentLabel(double normalized) =>
      '${(normalized.clamp(0.0, 1.0) * 100).round()}%';

  IconData _volumeIcon(double volume) {
    if (volume <= 0) return Design.icons.volumeOff;
    if (volume < 50) return Design.icons.volumeDown;
    return Design.icons.speaker;
  }

  void _goToMain() => setState(() => _panel = _SettingsPanel.main);

  @override
  Widget build(BuildContext context) {
    final currentRate = widget.player.rate;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: switch (_panel) {
              _SettingsPanel.speed => VideoSettingsSpeedPanel(
                title: AppLocales.video.playbackSpeed.tr,
                onBack: _goToMain,
                children: MediaPlaybackConstants.videoSpeedSteps
                    .map(
                      (speed) => VideoSheetOption(
                        label: _speedLabel(speed),
                        selected: (currentRate - speed).abs() < 0.01,
                        onTap: () {
                          unawaited(widget.player.setRate(speed));
                          Get.back();
                        },
                      ),
                    )
                    .toList(),
              ),
              _SettingsPanel.volume => VideoSettingsVolumePanel(
                title: AppLocales.video.volume.tr,
                icon: _volumeIcon(_volume),
                value: _volume.clamp(0.0, 100.0),
                min: 0,
                max: 100,
                onBack: _goToMain,
                onChanged: (value) {
                  setState(() => _volume = value);
                  unawaited(widget.player.setVolume(value));
                },
              ),
              _SettingsPanel.main => ListView(
                shrinkWrap: true,
                padding: Design.spacing.zero,
                children: [
                  VideoSheetHeader(title: AppLocales.video.settings.tr),
                  VideoSheetOption(
                    label: AppLocales.video.playbackSpeed.tr,
                    trailing: _speedLabel(currentRate),
                    showChevron: true,
                    onTap: () =>
                        setState(() => _panel = _SettingsPanel.speed),
                  ),
                  VideoSheetOption(
                    label: AppLocales.video.volume.tr,
                    trailing: _percentLabel(_volume / 100),
                    showChevron: true,
                    onTap: () =>
                        setState(() => _panel = _SettingsPanel.volume),
                  ),
                ],
              ),
            },
          ),
          SizedBox(height: Design.spacing.sm),
        ],
      ),
    );
  }
}
