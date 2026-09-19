// test/constants/storage_keys_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';

void main() {
  group('StorageKeys Cross-Platform Parity', () {
    test('core storage keys match rexone-web exactly', () {
      expect(StorageKeys.locale, 'locale');
      expect(StorageKeys.token, 'token');
      expect(StorageKeys.user, 'user');
      expect(StorageKeys.theme, 'theme');
    });

    test('mobile session keys are defined correctly', () {
      expect(StorageKeys.routes, 'routes');
      expect(StorageKeys.userEmail, 'user_email');
      expect(StorageKeys.remainingAttempts, 'remainingAttempts');
      expect(StorageKeys.hasFailureHistory, 'hasFailureHistory');
      expect(StorageKeys.skipPremium, 'skip_premium');
      expect(StorageKeys.audioSession, 'audio_session');
    });
  });
}
