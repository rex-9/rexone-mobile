import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/data/local/database.dart';
import 'package:rexone_mobile/data/local/extensions/local_asset.extension.dart';
import 'package:rexone_mobile/models/models.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase - Local Assets & Children', () {
    test('upsertAsset and getAssetById stores and retrieves asset metadata', () async {
      final asset = AssetModel(
        id: 'asset-1',
        name: 'intro.mp4',
        title: 'Introduction Video',
        description: 'First lesson',
        url: 'https://cdn.example.com/intro.mp4',
        type: 'lesson',
        format: AssetKeys.formatVideo,
        extension: 'mp4',
        sizeBytes: 1048576,
        durationSecs: 360,
        source: AssetKeys.sourceUpload,
      );

      await db.upsertAsset(
        asset.toCompanion(
          downloadState: 'ready',
          downloadProgress: 1.0,
          localFilePath: '/sandbox/intro.mp4',
          downloadedAt: DateTime(2026, 9, 19, 10, 0),
        ),
      );

      final fetched = await db.getAssetById('asset-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Introduction Video');
      expect(fetched.downloadState, 'ready');
      expect(fetched.localFilePath, '/sandbox/intro.mp4');
    });

    test('getDownloadedAssets returns only ready assets ordered by downloadedAt desc', () async {
      final now = DateTime.now();

      final v1 = AssetModel(
        id: 'v-1',
        name: 'v1.mp4',
        type: 'lesson',
        format: 'video',
        url: 'https://cdn.example.com/v1.mp4',
        source: AssetKeys.sourceUpload,
      );
      await db.upsertAsset(
        v1.toCompanion(
          downloadState: 'downloading',
          downloadProgress: 0.5,
        ),
      );

      final v2 = AssetModel(
        id: 'v-2',
        name: 'v2.mp4',
        type: 'lesson',
        format: 'video',
        url: 'https://cdn.example.com/v2.mp4',
        source: AssetKeys.sourceUpload,
      );
      await db.upsertAsset(
        v2.toCompanion(
          downloadState: 'ready',
          downloadProgress: 1.0,
          downloadedAt: now.subtract(const Duration(minutes: 10)),
        ),
      );

      final v3 = AssetModel(
        id: 'v-3',
        name: 'v3.mp4',
        type: 'lesson',
        format: 'video',
        url: 'https://cdn.example.com/v3.mp4',
        source: AssetKeys.sourceUpload,
      );
      await db.upsertAsset(
        v3.toCompanion(
          downloadState: 'ready',
          downloadProgress: 1.0,
          downloadedAt: now,
        ),
      );

      final downloaded = await db.getDownloadedAssets();
      expect(downloaded.length, 2);
      expect(downloaded.first.id, 'v-3');
      expect(downloaded.last.id, 'v-2');
    });

    test('upsertChildAsset and getChildAssets stores child assets', () async {
      const child = ChildAssetModel(
        id: 'sub-en',
        name: 'english.srt',
        title: 'English Subtitles',
        url: 'https://cdn.example.com/english.srt',
        type: 'subtitle',
        format: 'srt',
        extension: 'srt',
        status: AssetKeys.statusReady,
      );

      final parent = AssetModel(
        id: 'v-parent',
        name: 'parent.mp4',
        type: 'lesson',
        format: 'video',
        url: 'https://cdn.example.com/parent.mp4',
        source: AssetKeys.sourceUpload,
      );
      await db.upsertAsset(parent.toCompanion());

      await db.upsertChildAsset(
        child.toCompanion(
          'v-parent',
          localFilePath: '/sandbox/sub-en.srt',
          isDownloaded: true,
        ),
      );

      final children = await db.getChildAssets('v-parent');
      expect(children.length, 1);
      expect(children.first.id, 'sub-en');
      expect(children.first.parentAssetId, 'v-parent');
      expect(children.first.localFilePath, '/sandbox/sub-en.srt');
    });

    test('deleteAssetCascade removes both parent and all associated child assets', () async {
      final parent = AssetModel(
        id: 'v-parent',
        name: 'parent.mp4',
        type: 'lesson',
        format: 'video',
        url: 'https://cdn.example.com/parent.mp4',
        source: AssetKeys.sourceUpload,
      );
      await db.upsertAsset(parent.toCompanion());

      const child1 = ChildAssetModel(
        id: 'child-1',
        name: 'thumb.jpg',
        url: 'https://cdn.example.com/thumb.jpg',
        type: 'image',
        format: 'jpg',
        extension: 'jpg',
        status: AssetKeys.statusReady,
      );
      await db.upsertChildAsset(child1.toCompanion('v-parent'));

      const child2 = ChildAssetModel(
        id: 'child-2',
        name: 'sub.srt',
        url: 'https://cdn.example.com/sub.srt',
        type: 'subtitle',
        format: 'srt',
        extension: 'srt',
        status: AssetKeys.statusReady,
      );
      await db.upsertChildAsset(child2.toCompanion('v-parent'));

      expect((await db.getChildAssets('v-parent')).length, 2);

      await db.deleteAssetCascade('v-parent');

      expect(await db.getAssetById('v-parent'), isNull);
      expect((await db.getChildAssets('v-parent')).isEmpty, isTrue);
    });

    test('LocalAssetExtension toAssetModel maps parent and children into AssetModel', () async {
      final parentRow = LocalAssetsTableData(
        id: 'v-100',
        name: 'video.mp4',
        title: 'Test Video',
        url: 'https://cdn.example.com/video.mp4',
        format: 'video',
        type: 'lesson',
        source: AssetKeys.sourceUpload,
        downloadState: 'ready',
        downloadProgress: 1.0,
        localFilePath: '/sandbox/video.mp4',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final childSrt = LocalChildAssetsTableData(
        id: 'sub-1',
        parentAssetId: 'v-100',
        name: 'captions.srt',
        title: 'English',
        url: 'https://cdn.example.com/captions.srt',
        type: 'subtitle',
        format: 'srt',
        extension: 'srt',
        localFilePath: '/sandbox/captions.srt',
        isDownloaded: true,
      );

      final childThumb = LocalChildAssetsTableData(
        id: 'thumb-1',
        parentAssetId: 'v-100',
        name: 'thumbnail.jpg',
        title: 'Cover',
        url: 'https://cdn.example.com/thumb.jpg',
        type: 'image',
        format: 'jpg',
        extension: 'jpg',
        localFilePath: '/sandbox/thumb.jpg',
        isDownloaded: true,
      );

      final model = parentRow.toAssetModel(children: [childSrt, childThumb]);

      expect(model.id, 'v-100');
      expect(model.title, 'Test Video');
      expect(model.url, 'file:///sandbox/video.mp4');
      expect(model.subtitles.length, 1);
      expect(model.subtitles.first.url, 'file:///sandbox/captions.srt');
      expect(model.thumbnail, isNotNull);
      expect(model.thumbnail!.url, 'file:///sandbox/thumb.jpg');
    });

    test('AssetPlaybackProgress save and retrieve updates resume position', () async {
      const userId = 'user-123';
      await db.savePlaybackProgress(
        assetId: 'v-progress',
        userId: userId,
        positionMs: 125000,
        durationMs: 600000,
      );

      final progress = await db.getPlaybackProgress('v-progress', userId);
      expect(progress, isNotNull);
      expect(progress!.positionMs, 125000);
      expect(progress.durationMs, 600000);
      expect(progress.isCompleted, isFalse);

      // Now complete
      await db.savePlaybackProgress(
        assetId: 'v-progress',
        userId: userId,
        positionMs: 590000,
        durationMs: 600000,
        isCompleted: true,
      );

      final updated = await db.getPlaybackProgress('v-progress', userId);
      expect(updated!.positionMs, 590000);
      expect(updated.isCompleted, isTrue);
    });
  });
}
