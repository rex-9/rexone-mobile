import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/locales/app_translations.dart';
import 'package:rexone_mobile/modules/media/media.dart';

import '../../../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioPlayerService fakePlayer;
  late AudioPlayerController controller;

  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    fakePlayer = FakeAudioPlayerService();
    Get.put<AudioPlayerService>(fakePlayer);
    controller = Get.put(AudioPlayerController());
  });

  tearDown(() {
    Get.reset();
  });

  group('AudioPlayerController', () {
    test('togglePlayback delegates to the player service', () async {
      await controller.togglePlayback();
      expect(fakePlayer.playResult, isTrue);
    });

    test('skipNext delegates to the player service', () async {
      await controller.skipNext();
      expect(fakePlayer.playResult, isTrue);
    });

    test('onClose clears isFullPlayerOpen', () {
      fakePlayer.isFullPlayerOpen.value = true;
      Get.delete<AudioPlayerController>();
      expect(fakePlayer.isFullPlayerOpen.value, isFalse);
    });

    test('closeAndExit dismisses player session', () async {
      fakePlayer.hasSession.value = true;
      await controller.closeAndExit();
      expect(fakePlayer.hasSession.value, isFalse);
    });
  });
}
