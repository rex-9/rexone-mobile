import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/locales/app_translations.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/media/media.dart';

import '../../../mocks/test_services.dart';

AssetModel _videoAsset(String id) => AssetModel(
      id: id,
      name: '$id.mp4',
      url: 'https://example.com/$id.mp4',
      type: AssetKeys.typeVideo,
      source: AssetKeys.sourceUpload,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVideoPlayerService fakePlayer;
  late VideoPlayerController controller;

  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    fakePlayer = FakeVideoPlayerService();
    Get.put<VideoPlayerService>(fakePlayer);
    controller = Get.put(VideoPlayerController());
  });

  tearDown(() {
    Get.reset();
  });

  group('VideoPlayerController', () {
    test('playAt starts playback for a new index', () async {
      fakePlayer.assets.assignAll([_videoAsset('v1'), _videoAsset('v2')]);

      await controller.playAt(1);

      expect(fakePlayer.lastPlayedIndex, 1);
      expect(fakePlayer.toggleCalled, isFalse);
    });

    test('playAt toggles when the same track is already active', () async {
      fakePlayer.assets.assignAll([_videoAsset('v1')]);
      fakePlayer.hasSession.value = true;
      fakePlayer.currentIndex.value = 0;

      await controller.playAt(0);

      expect(fakePlayer.toggleCalled, isTrue);
      expect(fakePlayer.lastPlayedIndex, isNull);
    });
  });
}
