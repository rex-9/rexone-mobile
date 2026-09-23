import 'package:better_player/better_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/modules/media/video/services/video_player.service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoPlayerService buildDataSource', () {
    late VideoPlayerService service;

    setUp(() {
      service = VideoPlayerService();
    });

    test('network data source configures video cache and buffering', () {
      final dataSource = service.buildDataSource(
        'https://stream.example.com/video.mp4',
        cacheKey: 'asset_123',
      );

      expect(dataSource.type, DataSourceType.network);
      expect(dataSource.cacheConfiguration, isNotNull);
      expect(dataSource.cacheConfiguration!.useCache, isTrue);
      expect(
        dataSource.cacheConfiguration!.maxCacheSize,
        MediaPlaybackConstants.videoMaxCacheSizeBytes,
      );
      expect(
        dataSource.cacheConfiguration!.maxCacheFileSize,
        MediaPlaybackConstants.videoMaxCacheFileSizeBytes,
      );
      expect(dataSource.cacheConfiguration!.key, 'asset_123');

      expect(
        dataSource.bufferingConfiguration.minBufferMs,
        MediaPlaybackConstants.videoMinBufferMs,
      );
      expect(
        dataSource.bufferingConfiguration.maxBufferMs,
        MediaPlaybackConstants.videoMaxBufferMs,
      );
      expect(
        dataSource.bufferingConfiguration.bufferForPlaybackMs,
        MediaPlaybackConstants.videoBufferForPlaybackMs,
      );
      expect(
        dataSource.bufferingConfiguration.bufferForPlaybackAfterRebufferMs,
        MediaPlaybackConstants.videoBufferForPlaybackAfterRebufferMs,
      );
    });

    test('file data source disables network cache and overrides video extension', () {
      final dataSource = service.buildDataSource(
        '/var/mobile/Containers/Data/media.enc',
      );

      expect(dataSource.type, DataSourceType.file);
      expect(dataSource.cacheConfiguration, isNull);
      expect(dataSource.videoExtension, 'mp4');
    });

    test('seek updates position immediately', () async {
      expect(service.position.value, Duration.zero);
      await service.seek(const Duration(seconds: 15));
      expect(service.position.value, const Duration(seconds: 15));
    });

    test('dismiss resets position and session state', () async {
      await service.seek(const Duration(seconds: 15));
      expect(service.position.value, const Duration(seconds: 15));

      await service.dismiss();
      expect(service.position.value, Duration.zero);
      expect(service.hasSession.value, isFalse);
      expect(service.isPlaying.value, isFalse);
    });
  });
}

