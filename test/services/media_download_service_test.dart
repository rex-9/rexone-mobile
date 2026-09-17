import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/media_download_entry.model.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/media_download.service.dart';
import 'package:rexone_mobile/services/media_download_notification.service.dart';
import 'package:rexone_mobile/services/storage.service.dart';

import '../mocks/test_services.dart';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => '$root/tmp';

  @override
  Future<String?> getApplicationDocumentsPath() async => '$root/docs';

  @override
  Future<String?> getLibraryPath() async => '$root/library';
}

class _FakeMediaDownloadNotificationService
    extends MediaDownloadNotificationService {
  @override
  void onInit() {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> endAllLiveActivities() async {}

  @override
  Future<void> endLiveActivityFor(String assetId) async {}

  @override
  Future<void> onDownloadPaused({
    required String assetId,
    required String title,
    required double progress,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late FakeStorageService fakeStorage;
  late MediaDownloadService downloads;

  setUp(() async {
    Get.testMode = true;
    dotenv.loadFromString(
      envString: 'MEDIA_OFFLINE_ENCRYPTION_KEY=test-offline-key\n',
    );

    tempRoot = Directory.systemTemp.createTempSync('media_offline_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempRoot.path);

    fakeStorage = FakeStorageService();
    Get.put<StorageService>(fakeStorage);
    Get.put<MediaService>(FakeMediaService());
    Get.put<MediaDownloadNotificationService>(
      _FakeMediaDownloadNotificationService(),
    );

    downloads = Get.put(MediaDownloadService());
  });

  tearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
    Get.reset();
  });

  group('MediaDownloadEntry', () {
    test('toJson/fromJson round-trip preserves fields', () {
      final original = MediaDownloadEntry(
        assetId: 'ast_1',
        state: EMediaDownloadState.ready,
        progress: 1,
        mediaPath: 'ast_1.enc',
        subtitlePaths: {'sub_1': 'ast_1_sub_1.sub.enc'},
        downloadedAt: DateTime.utc(2026, 1, 15, 12),
        title: 'Track One',
        mediaFormat: AssetKeys.formatAudio,
      );

      final restored = MediaDownloadEntry.fromJson(original.toJson());

      expect(restored.assetId, original.assetId);
      expect(restored.state, EMediaDownloadState.ready);
      expect(restored.progress, 1);
      expect(restored.mediaPath, 'ast_1.enc');
      expect(restored.subtitlePaths, {'sub_1': 'ast_1_sub_1.sub.enc'});
      expect(restored.title, 'Track One');
      expect(restored.mediaFormat, AssetKeys.formatAudio);
      expect(restored.isReady, isTrue);
    });

    test('fromStorage round-trips paused state', () {
      expect(
        EMediaDownloadState.fromStorage('paused'),
        EMediaDownloadState.paused,
      );

      final entry = MediaDownloadEntry(
        assetId: 'ast_paused',
        state: EMediaDownloadState.paused,
        progress: 0.42,
        title: 'Halfway',
      );
      final restored = MediaDownloadEntry.fromJson(entry.toJson());
      expect(restored.state, EMediaDownloadState.paused);
      expect(restored.progress, 0.42);
    });
  });

  group('MediaDownloadService', () {
    test('storeEncryptedMedia encrypts, indexes, and decrypts for playback',
        () async {
      final plaintext = Uint8List.fromList(utf8.encode('offline-audio-bytes'));
      final subtitle = Uint8List.fromList(utf8.encode('1\n00:00:00,000 --> 00:00:01,000\nHi\n'));

      await downloads.storeEncryptedMedia(
        assetId: 'ast_audio',
        plaintext: plaintext,
        subtitles: {'sub_en': subtitle},
        title: 'Offline Track',
        mediaFormat: AssetKeys.formatAudio,
      );

      expect(downloads.isDownloaded('ast_audio'), isTrue);
      expect(downloads.stateFor('ast_audio'), EMediaDownloadState.ready);
      expect(downloads.progressFor('ast_audio'), 1);

      final entry = downloads.entryFor('ast_audio');
      expect(entry?.mediaPath, 'ast_audio.enc');
      expect(entry?.subtitlePaths.containsKey('sub_en'), isTrue);
      expect(fakeStorage.getMediaDownloadsIndex()?['ast_audio'], isNotNull);

      final mediaPath = await downloads.resolveDecryptedMediaPath('ast_audio');
      expect(mediaPath, isNotNull);
      expect(File(mediaPath!).readAsBytesSync(), plaintext);

      final asset = AssetModel(
        id: 'ast_audio',
        name: 'offline.mp3',
        url: '',
        type: 'general',
        format: AssetKeys.formatAudio,
        source: AssetKeys.sourceUpload,
        subtitles: const [
          ChildAssetModel(
            id: 'sub_en',
            url: 'https://example.com/sub.srt',
            status: AssetKeys.statusReady,
            name: 'English',
            extension: 'srt',
          ),
        ],
      );
      final offlineSubs =
          await downloads.resolveOfflineSubtitleTracks(asset);
      expect(offlineSubs, hasLength(1));
      expect(offlineSubs.first.id, 'sub_en');
      expect(offlineSubs.first.url, startsWith('file://'));

      final subtitlePath = await downloads.resolveDecryptedSubtitlePath(
        'ast_audio',
        'sub_en',
      );
      expect(subtitlePath, isNotNull);
      expect(File(subtitlePath!).readAsBytesSync(), subtitle);
    });

    test('deleteDownload removes files and index entry', () async {
      await downloads.storeEncryptedMedia(
        assetId: 'ast_del',
        plaintext: Uint8List.fromList([9, 8, 7]),
        title: 'Delete Me',
      );

      expect(downloads.isDownloaded('ast_del'), isTrue);

      await downloads.deleteDownload('ast_del');

      expect(downloads.isDownloaded('ast_del'), isFalse);
      expect(downloads.entryFor('ast_del'), isNull);
      expect(fakeStorage.getMediaDownloadsIndex()?['ast_del'], isNull);
      expect(
        await downloads.resolveDecryptedMediaPath('ast_del'),
        isNull,
      );
    });

    test('clearAllDownloads wipes library and storage index', () async {
      await downloads.storeEncryptedMedia(
        assetId: 'ast_a',
        plaintext: Uint8List.fromList([1]),
      );
      await downloads.storeEncryptedMedia(
        assetId: 'ast_b',
        plaintext: Uint8List.fromList([2]),
      );

      await downloads.clearAllDownloads();

      expect(downloads.entries, isEmpty);
      expect(fakeStorage.getMediaDownloadsIndex(), isNull);
    });
  });
}
