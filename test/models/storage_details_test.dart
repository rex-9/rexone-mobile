// test/models/asset_upload_response_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/media.model.dart';

void main() {
  group('StorageDetails', () {
    test('parses json with all fields', () {
      final json = {
        AssetKeys.storageKey: 'avatars/usr_123.jpg',
        AssetKeys.bytes: 2048,
        AssetKeys.format: 'jpg',
      };

      final details = StorageDetails.fromJson(json);

      expect(details.storageKey, equals('avatars/usr_123.jpg'));
      expect(details.bytes, equals(2048));
      expect(details.format, equals('jpg'));
    });

    test('handles missing or null fields gracefully', () {
      final details = StorageDetails.fromJson(const {});

      expect(details.storageKey, isEmpty);
      expect(details.bytes, equals(0));
      expect(details.format, isEmpty);
    });
  });
}
