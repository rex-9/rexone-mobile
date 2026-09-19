import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:rexone_mobile/constants/constants.dart';

/// AES-256-GCM helpers for offline media blobs.
class MediaEncryptionHelper {
  MediaEncryptionHelper._();

  static final AesGcm _algorithm = AesGcm.with256bits();
  static final Sha256 _sha256 = Sha256();

  static Future<SecretKey> _secretKey(String encryptionKey) async {
    final trimmed = encryptionKey.trim();
    if (trimmed.isEmpty) {
      throw StateError('MEDIA_OFFLINE_ENCRYPTION_KEY is not configured');
    }

    final hash = await _sha256.hash(
      utf8.encode('$trimmed${MediaDownloadConstants.keySalt}'),
    );
    return SecretKey(hash.bytes);
  }

  static Future<Uint8List> encrypt({
    required Uint8List plaintext,
    required String encryptionKey,
  }) async {
    final secretKey = await _secretKey(encryptionKey);
    final secretBox = await _algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
    );
    return Uint8List.fromList(secretBox.concatenation());
  }

  static Future<Uint8List> decrypt({
    required Uint8List ciphertext,
    required String encryptionKey,
  }) async {
    final secretKey = await _secretKey(encryptionKey);
    final secretBox = SecretBox.fromConcatenation(
      ciphertext,
      nonceLength: _algorithm.nonceLength,
      macLength: 16,
    );
    final plaintext = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );
    return Uint8List.fromList(plaintext);
  }
}
