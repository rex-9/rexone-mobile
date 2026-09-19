import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/asset.model.dart';

void main() {
  group('ChildAssetModel', () {
    test('fromJson parses child asset fields', () {
      final child = ChildAssetModel.fromJson({
        ApiKeys.id: 'child-1',
        AssetKeys.name: 'user/subtitle_en.srt',
        AssetKeys.title: 'English',
        AssetKeys.description: 'English captions',
        AssetKeys.url: 'https://example.com/thumb.webp',
        AssetKeys.status: 'ready',
        AssetKeys.sizeBytes: 512,
        AssetKeys.extension: 'srt',
      });

      expect(child.id, 'child-1');
      expect(child.url, 'https://example.com/thumb.webp');
      expect(child.status, 'ready');
      expect(child.sizeBytes, 512);
      expect(child.title, 'English');
      expect(child.description, 'English captions');
      expect(child.displayLabel, 'English');
      expect(child.isPlayableSubtitle, isTrue);
    });

    test('displayLabel falls back to basename without extension', () {
      final child = ChildAssetModel.fromJson({
        ApiKeys.id: 'child-1',
        AssetKeys.name: 'user/subtitle_en.srt',
        AssetKeys.url: 'https://example.com/sub.srt',
        AssetKeys.status: 'ready',
        AssetKeys.extension: 'srt',
      });

      expect(child.displayLabel, 'subtitle_en');
    });

    test('isPlayableSubtitle rejects non-srt extension', () {
      final child = ChildAssetModel.fromJson({
        ApiKeys.id: 'child-1',
        AssetKeys.url: 'https://example.com/sub.vtt',
        AssetKeys.status: 'ready',
        AssetKeys.extension: 'vtt',
      });

      expect(child.isPlayableSubtitle, isFalse);
    });
  });

  group('AssetModel', () {
    test('fromJson parses children.thumbnail and children.subtitles', () {
      final asset = AssetModel.fromJson({
        ApiKeys.id: 'video-1',
        AssetKeys.name: 'user/demo.mp4',
        AssetKeys.url: 'https://example.com/demo.mp4',
        AssetKeys.type: AssetKeys.typeVideo,
        AssetKeys.source: AssetKeys.sourceUpload,
        AssetKeys.durationSecs: 125,
        AssetKeys.children: {
          AssetKeys.thumbnail: {
            ApiKeys.id: 'thumb-1',
            AssetKeys.name: 'user/thumb.webp',
            AssetKeys.url: 'https://example.com/thumb.webp',
            AssetKeys.status: 'ready',
            AssetKeys.sizeBytes: 512,
          },
          AssetKeys.subtitles: [
            {
              ApiKeys.id: 'sub-en',
              AssetKeys.name: 'user/subtitle_en.srt',
              AssetKeys.url: 'https://example.com/sub_en.srt',
              AssetKeys.status: 'ready',
              AssetKeys.extension: 'srt',
            },
            {
              ApiKeys.id: 'sub-my',
              AssetKeys.name: 'user/subtitle_my.srt',
              AssetKeys.url: 'https://example.com/sub_my.srt',
              AssetKeys.status: 'ready',
              AssetKeys.extension: 'srt',
            },
          ],
        },
      });

      expect(asset.thumbnail?.url, 'https://example.com/thumb.webp');
      expect(asset.subtitles.length, 2);
      expect(asset.playableSubtitles.length, 2);
      expect(asset.primarySubtitle?.id, 'sub-en');
      expect(asset.displayThumbnailUrl, 'https://example.com/thumb.webp');
      expect(asset.hasPlayableSubtitle, isTrue);
      expect(asset.subtitleUrl, 'https://example.com/sub_en.srt');
      expect(asset.subtitleUrlAt(1), 'https://example.com/sub_my.srt');
    });

    test('fromJson legacy flat thumbnail and subtitle still parse', () {
      final asset = AssetModel.fromJson({
        ApiKeys.id: 'video-1',
        AssetKeys.name: 'user/demo.mp4',
        AssetKeys.url: 'https://example.com/demo.mp4',
        AssetKeys.type: AssetKeys.typeVideo,
        AssetKeys.source: AssetKeys.sourceUpload,
        AssetKeys.thumbnail: {
          ApiKeys.id: 'thumb-1',
          AssetKeys.url: 'https://example.com/thumb.webp',
          AssetKeys.status: 'ready',
        },
        AssetKeys.subtitle: {
          ApiKeys.id: 'sub-1',
          AssetKeys.url: 'https://example.com/sub.srt',
          AssetKeys.status: 'ready',
          AssetKeys.extension: 'srt',
        },
      });

      expect(asset.thumbnail?.url, 'https://example.com/thumb.webp');
      expect(asset.subtitles.single.url, 'https://example.com/sub.srt');
      expect(asset.hasPlayableSubtitle, isTrue);
    });

    test('displayTitle prefers title over filename-derived name', () {
      final asset = AssetModel.fromJson({
        ApiKeys.id: 'video-1',
        AssetKeys.name: 'user/demo.mp4',
        AssetKeys.title: 'My Demo Video',
        AssetKeys.url: 'https://example.com/demo.mp4',
        AssetKeys.type: AssetKeys.typeVideo,
        AssetKeys.source: AssetKeys.sourceUpload,
      });

      expect(asset.title, 'My Demo Video');
      expect(asset.displayTitle, 'My Demo Video');
    });

    test('displayTitle falls back to basename without extension', () {
      final asset = AssetModel.fromJson({
        ApiKeys.id: 'video-1',
        AssetKeys.name: 'user/demo.mp4',
        AssetKeys.url: 'https://example.com/demo.mp4',
        AssetKeys.type: AssetKeys.typeVideo,
        AssetKeys.source: AssetKeys.sourceUpload,
      });

      expect(asset.displayTitle, 'demo');
    });

    test('displayDuration formats mm:ss', () {
      final asset = AssetModel.fromJson({
        ApiKeys.id: 'video-1',
        AssetKeys.name: 'demo.mp4',
        AssetKeys.url: 'https://example.com/demo.mp4',
        AssetKeys.type: AssetKeys.typeVideo,
        AssetKeys.source: AssetKeys.sourceUpload,
        AssetKeys.durationSecs: 125,
      });

      expect(asset.displayDuration, '2:05');
    });

    test('hasPlayableSubtitle is false when subtitles missing', () {
      final asset = AssetModel.fromJson({
        ApiKeys.id: 'video-1',
        AssetKeys.name: 'demo.mp4',
        AssetKeys.url: 'https://example.com/demo.mp4',
        AssetKeys.type: AssetKeys.typeVideo,
        AssetKeys.source: AssetKeys.sourceUpload,
        AssetKeys.children: {
          AssetKeys.subtitles: [],
        },
      });

      expect(asset.hasPlayableSubtitle, isFalse);
      expect(asset.subtitleUrl, isEmpty);
    });
  });
}
