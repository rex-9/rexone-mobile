import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/locales/app_translations.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/media/media.dart';
import 'package:rexone_mobile/services/media.service.dart';

import '../../../mocks/test_services.dart';

class _PagingFakeMediaService extends FakeMediaService {
  _PagingFakeMediaService(this.pages);

  final Map<int, PaginatedResponse<AssetModel>> pages;

  @override
  Future<PaginatedResponse<AssetModel>> getAssets({
    String? type,
    int page = 1,
    int limit = 10,
  }) async {
    lastAssetsPage = page;
    lastAssetsLimit = limit;
    return pages[page] ??
        const PaginatedResponse<AssetModel>(
          records: [],
          message: 'OK',
          statusCode: 200,
          success: true,
        );
  }
}

AssetModel _asset({
  required String id,
  required String format,
}) =>
    AssetModel(
      id: id,
      name: '$id.${format == AssetKeys.formatVideo ? 'mp4' : 'mp3'}',
      url: 'https://example.com/$id',
      type: 'general',
      format: format,
      source: AssetKeys.sourceUpload,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeMediaService fakeMedia;
  late FakeAudioPlayerService fakeAudioPlayer;
  late FakeVideoPlayerService fakeVideoPlayer;

  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    fakeMedia = FakeMediaService();
    fakeAudioPlayer = FakeAudioPlayerService();
    fakeVideoPlayer = FakeVideoPlayerService();
    Get.put<MediaService>(fakeMedia);
    Get.put<AudioPlayerService>(fakeAudioPlayer);
    Get.put<VideoPlayerService>(fakeVideoPlayer);
    fakeMedia.assetsResponse = const PaginatedResponse<AssetModel>(
      records: [],
      message: 'OK',
      statusCode: 200,
      success: true,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('MediaPlaylistController', () {
    test('fetchAssets keeps playable media and syncs both players', () async {
      final controller = Get.put(MediaPlaylistController());

      fakeMedia.assetsResponse = PaginatedResponse<AssetModel>(
        records: [
          _asset(id: 'a1', format: AssetKeys.formatAudio),
          _asset(id: 'v1', format: AssetKeys.formatVideo),
          _asset(id: 'a2', format: AssetKeys.formatAudio),
        ],
        message: 'OK',
        statusCode: 200,
        success: true,
        pagination: const PaginationMeta(
          currentPage: 1,
          totalPages: 1,
          totalCount: 3,
          limit: MediaLayoutConstants.playlistPageLimit,
        ),
      );

      await controller.fetchAssets(refresh: true);

      expect(fakeMedia.lastAssetsType, isNull);
      expect(controller.assets.length, 3);
      expect(controller.assets.every((item) => item.isPlayableMedia), isTrue);
      expect(fakeAudioPlayer.assets.length, 2);
      expect(fakeVideoPlayer.assets.length, 1);
    });

    test('loadMore appends the next page of playable media', () async {
      final pagingMedia = _PagingFakeMediaService({
        1: PaginatedResponse<AssetModel>(
          records: List.generate(
            MediaLayoutConstants.playlistPageLimit,
            (index) => _asset(
              id: 'a$index',
              format: AssetKeys.formatAudio,
            ),
          ),
          message: 'OK',
          statusCode: 200,
          success: true,
          pagination: const PaginationMeta(
            currentPage: 1,
            totalPages: 2,
            totalCount: 20,
            limit: MediaLayoutConstants.playlistPageLimit,
            nextPage: 2,
          ),
        ),
        2: PaginatedResponse<AssetModel>(
          records: [_asset(id: 'v-next', format: AssetKeys.formatVideo)],
          message: 'OK',
          statusCode: 200,
          success: true,
          pagination: const PaginationMeta(
            currentPage: 2,
            totalPages: 2,
            totalCount: 20,
            limit: MediaLayoutConstants.playlistPageLimit,
          ),
        ),
      });
      Get.delete<MediaPlaylistController>(force: true);
      Get.delete<MediaService>(force: true);
      Get.put<MediaService>(pagingMedia);

      final controller = Get.put(MediaPlaylistController());
      await Future<void>.delayed(Duration.zero);

      await controller.fetchAssets(refresh: true);
      expect(controller.assets.length, MediaLayoutConstants.playlistPageLimit);
      expect(controller.hasMore.value, isTrue);

      await controller.loadMore();

      expect(pagingMedia.lastAssetsPage, 2);
      expect(controller.assets.length, MediaLayoutConstants.playlistPageLimit + 1);
      expect(controller.hasMore.value, isFalse);
    });

    test('prefetches extra pages when the first page has few playable items',
        () async {
      final pagingMedia = _PagingFakeMediaService({
        1: PaginatedResponse<AssetModel>(
          records: [
            _asset(id: 'doc1', format: 'pdf'),
            _asset(id: 'a1', format: AssetKeys.formatAudio),
          ],
          message: 'OK',
          statusCode: 200,
          success: true,
          pagination: const PaginationMeta(
            currentPage: 1,
            totalPages: 3,
            totalCount: 6,
            limit: MediaLayoutConstants.playlistPageLimit,
            nextPage: 2,
          ),
        ),
        2: PaginatedResponse<AssetModel>(
          records: [
            _asset(id: 'v1', format: AssetKeys.formatVideo),
            _asset(id: 'a2', format: AssetKeys.formatAudio),
          ],
          message: 'OK',
          statusCode: 200,
          success: true,
          pagination: const PaginationMeta(
            currentPage: 2,
            totalPages: 2,
            totalCount: 3,
            limit: MediaLayoutConstants.playlistPageLimit,
          ),
        ),
      });
      Get.delete<MediaPlaylistController>(force: true);
      Get.delete<MediaService>(force: true);
      Get.put<MediaService>(pagingMedia);

      final controller = Get.put(MediaPlaylistController());
      await Future<void>.delayed(Duration.zero);

      await controller.fetchAssets(refresh: true);

      expect(controller.assets.map((item) => item.id), ['a1', 'v1', 'a2']);
      expect(pagingMedia.lastAssetsPage, 2);
    });

    test('playAt starts audio playback for a different track', () async {
      final controller = Get.put(MediaPlaylistController());

      controller.assets.assignAll([
        _asset(id: 'a1', format: AssetKeys.formatAudio),
        _asset(id: 'a2', format: AssetKeys.formatAudio),
      ]);
      fakeAudioPlayer.assets.assignAll(controller.assets);
      fakeAudioPlayer.hasSession.value = true;
      fakeAudioPlayer.currentIndex.value = 0;

      await controller.playAt(1);

      expect(fakeAudioPlayer.lastPlayedIndex, 1);
    });

    test('playAt starts video playback before navigating to the player', () async {
      final controller = Get.put(MediaPlaylistController());

      controller.assets.assignAll([
        _asset(id: 'a1', format: AssetKeys.formatAudio),
        _asset(id: 'v1', format: AssetKeys.formatVideo),
        _asset(id: 'v2', format: AssetKeys.formatVideo),
      ]);
      fakeVideoPlayer.assets.assignAll([
        _asset(id: 'v1', format: AssetKeys.formatVideo),
        _asset(id: 'v2', format: AssetKeys.formatVideo),
      ]);

      await controller.playAt(2);

      expect(fakeVideoPlayer.lastPlayedIndex, 1);
    });

    test('next from audio continues to video in mixed queue order', () async {
      Get.put(MediaPlaylistController());
      final mixed = [
        _asset(id: 'a1', format: AssetKeys.formatAudio),
        _asset(id: 'v1', format: AssetKeys.formatVideo),
        _asset(id: 'a2', format: AssetKeys.formatAudio),
      ];

      fakeAudioPlayer.setQueue(mixed);
      fakeAudioPlayer.assets.assignAll([
        mixed[0],
        mixed[2],
      ]);
      fakeVideoPlayer.assets.assignAll([mixed[1]]);
      fakeAudioPlayer.hasSession.value = true;
      fakeAudioPlayer.currentIndex.value = 0;
      fakeAudioPlayer.queueIndex.value = 0;

      await fakeAudioPlayer.next();

      expect(fakeAudioPlayer.lastQueueIndex, 1);
      expect(fakeVideoPlayer.lastPlayedIndex, 0);
    });
  });
}
