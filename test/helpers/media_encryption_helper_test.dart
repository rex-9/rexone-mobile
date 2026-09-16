import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/helpers/media_encryption.helper.dart';

void main() {
  group('MediaEncryptionHelper', () {
    const key = 'test-offline-encryption-key';

    test('encrypt then decrypt returns original bytes', () async {
      final plaintext = Uint8List.fromList(utf8.encode('offline media payload'));

      final encrypted = await MediaEncryptionHelper.encrypt(
        plaintext: plaintext,
        encryptionKey: key,
      );
      final decrypted = await MediaEncryptionHelper.decrypt(
        ciphertext: encrypted,
        encryptionKey: key,
      );

      expect(decrypted, plaintext);
      expect(encrypted, isNot(equals(plaintext)));
    });

    test('decrypt fails with a different key', () async {
      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5]);
      final encrypted = await MediaEncryptionHelper.encrypt(
        plaintext: plaintext,
        encryptionKey: key,
      );

      expect(
        MediaEncryptionHelper.decrypt(
          ciphertext: encrypted,
          encryptionKey: 'different-key',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('encrypt throws when key is empty', () async {
      expect(
        () => MediaEncryptionHelper.encrypt(
          plaintext: Uint8List.fromList([1]),
          encryptionKey: '',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
