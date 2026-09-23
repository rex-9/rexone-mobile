import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/locales/app_translations.dart';
import 'package:rexone_mobile/modules/media/media.dart';

import '../../../mocks/test_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioPlayerService fakePlayer;
  late MiniPlayerController controller;

  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    fakePlayer = FakeAudioPlayerService();
    Get.put<AudioPlayerService>(fakePlayer);
    controller = Get.put(MiniPlayerController());
  });

  tearDown(() {
    Get.reset();
  });

  group('MiniPlayerController', () {
    test('isRegistered reports true when service registered', () {
      expect(controller.isRegistered, isTrue);
    });

    test('togglePlayPause delegates to service', () async {
      await controller.togglePlayPause();
      expect(fakePlayer.playResult, isTrue);
    });

    test('playNext delegates to service', () async {
      await controller.playNext();
      expect(fakePlayer.playResult, isTrue);
    });

    test('dismiss calls dismiss on service', () {
      fakePlayer.hasSession.value = true;
      controller.dismiss();
      expect(fakePlayer.hasSession.value, isFalse);
    });
  });
}
