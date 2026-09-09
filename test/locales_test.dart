// test/locales_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/locales/app_locales.dart';
import 'package:rexone_mobile/locales/app_translations.dart';

void main() {
  group('AppLocales & AppTranslations', () {
    test('All languages have 100% complete translation keys without omission', () {
      final trans = AppTranslations().keys;
      final en = trans['en_US']!;
      final my = trans['my_MM']!;

      expect(en.isNotEmpty, true);
      expect(my.isNotEmpty, true);

      final missingInMy = en.keys.where((k) => !my.containsKey(k)).toList();
      expect(missingInMy, isEmpty, reason: 'Missing keys in my_MM: $missingInMy');

      final missingInEnFromMy = my.keys.where((k) => !en.containsKey(k)).toList();
      expect(missingInEnFromMy, isEmpty, reason: 'Missing keys in en_US: $missingInEnFromMy');
    });

    test('AppLocales namespaces contain expected keys', () {
      expect(AppLocales.common.home, 'common.home');
      expect(AppLocales.auth.initial.title, 'auth.initial.title');
      expect(AppLocales.auth.signInPasscode.title, 'auth.signin_passcode.title');
      expect(AppLocales.setting.settings, 'settings.title');
      expect(AppLocales.feedback.title, 'feedback.title');
      expect(AppLocales.ai.title, 'ai.title');
      expect(AppLocales.payment.title, 'payment.title');
      expect(AppLocales.notification.title, 'notification.title');
      expect(AppLocales.update.title, 'update.title');
      expect(AppLocales.audio.title, 'audio.title');
    });
  });
}
