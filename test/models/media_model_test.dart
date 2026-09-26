import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/media.model.dart';

void main() {
  group('MediaPlaybackModel', () {
    test('fromJson parses delivery, media, and multiple subtitles', () {
      final response = MediaPlaybackModel.fromJson({
        AssetKeys.assetId: 'asset-1',
        AssetKeys.delivery: {
          AssetKeys.type: 'progressive',
          AssetKeys.url: 'https://cdn.example.com/video.mp4?sig=abc',
          AssetKeys.expiresAt: '2026-09-14T15:00:00Z',
        },
        AssetKeys.media: {
          AssetKeys.contentType: 'video/mp4',
          AssetKeys.format: 'mp4',
          AssetKeys.sizeBytes: 10485760,
          AssetKeys.durationSecs: 120,
          AssetKeys.thumbnail: {
            ApiKeys.id: 'thumb-1',
            AssetKeys.url: 'https://cdn.example.com/thumb.webp',
            AssetKeys.status: 'ready',
          },
          AssetKeys.subtitles: [
            {
              ApiKeys.id: 'sub-en',
              AssetKeys.url: 'https://cdn.example.com/sub_en.srt',
              AssetKeys.status: 'ready',
              AssetKeys.extension: 'srt',
            },
            {
              ApiKeys.id: 'sub-my',
              AssetKeys.url: 'https://cdn.example.com/sub_my.srt',
              AssetKeys.status: 'ready',
              AssetKeys.extension: 'srt',
            },
          ],
        },
      });

      expect(response.assetId, 'asset-1');
      expect(response.delivery.type, 'progressive');
      expect(response.delivery.url, contains('video.mp4'));
      expect(response.expiresAt, isNotNull);
      expect(response.media.contentType, 'video/mp4');
      expect(response.media.durationSecs, 120);
      expect(response.media.thumbnail?.id, 'thumb-1');
      expect(response.media.playableSubtitles.length, 2);
      expect(response.media.playableSubtitles.first.id, 'sub-en');
    });

    test('isNearExpiry is true within 60 seconds of expires_at', () {
      final response = MediaPlaybackModel.fromJson({
        AssetKeys.assetId: 'asset-1',
        AssetKeys.delivery: {
          AssetKeys.type: 'progressive',
          AssetKeys.url: 'https://cdn.example.com/audio.mp3',
          AssetKeys.expiresAt: DateTime.now()
              .add(const Duration(seconds: 30))
              .toUtc()
              .toIso8601String(),
        },
        AssetKeys.media: {
          AssetKeys.contentType: 'audio/mpeg',
          AssetKeys.format: 'mp3',
        },
      });

      expect(response.isNearExpiry, isTrue);
      expect(response.isExpired, isFalse);
    });
  });
}
