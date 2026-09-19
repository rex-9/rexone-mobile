// test/locales_test.dart
import 'dart:io';
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
      expect(AppLocales.video.title, 'video.title');
    });

    test('AppTranslations contains no duplicate keys in locale maps', () {
      final file = File('lib/locales/app_translations.dart');
      if (!file.existsSync()) return;
      final source = file.readAsStringSync();
      for (final locale in ['en_US', 'my_MM']) {
        final marker = "'$locale': {";
        final start = source.indexOf(marker);
        if (start < 0) continue;
        final end = source.indexOf('\n    },', start);
        if (end < 0) continue;
        final body = source.substring(start + marker.length, end);
        final entryPattern = RegExp(
          r'(AppLocales(?:\.[a-zA-Z_][a-zA-Z0-9_]*)+)\s*:',
        );
        final keys = entryPattern.allMatches(body).map((m) => m.group(1)!).toList();
        final duplicates = <String>{};
        final seen = <String>{};
        for (final k in keys) {
          if (!seen.add(k)) duplicates.add(k);
        }
        expect(duplicates, isEmpty, reason: 'Duplicate keys in $locale: $duplicates');
      }
    });
  });
}
