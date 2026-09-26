import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';

void main() {
  group('VersionModel', () {
    test('parses version JSON correctly', () {
      final json = {
        ApiKeys.id: 'v_100',
        VersionKeys.number: '1.2.0',
        VersionKeys.title: 'Major Update',
        VersionKeys.description: 'New payment features',
        VersionKeys.status: 'released',
        VersionKeys.releasedAt: '2026-09-01T12:00:00Z',
        VersionKeys.updateRequired: true,
        VersionKeys.mustUpdate: false,
        VersionKeys.skipPremium: false,
        VersionKeys.storeUrl: 'https://play.google.com/store/apps/details?id=com.rexone',
      };

      final version = VersionModel.fromJson(json);

      expect(version.id, 'v_100');
      expect(version.number, '1.2.0');
      expect(version.title, 'Major Update');
      expect(version.description, 'New payment features');
      expect(version.status, 'released');
      expect(version.releasedAt, isNotNull);
      expect(version.updateRequired, isTrue);
      expect(version.mustUpdate, isFalse);
      expect(version.skipPremium, isFalse);
      expect(version.storeUrl, 'https://play.google.com/store/apps/details?id=com.rexone');
    });

    test('serializes VersionModel to JSON correctly', () {
      final version = VersionModel(
        id: 'v_200',
        number: '2.0.0',
        title: 'V2',
        updateRequired: false,
        mustUpdate: true,
        skipPremium: true,
      );

      final json = version.toJson();

      expect(json[ApiKeys.id], 'v_200');
      expect(json[VersionKeys.number], '2.0.0');
      expect(json[VersionKeys.title], 'V2');
      expect(json[VersionKeys.updateRequired], isFalse);
      expect(json[VersionKeys.mustUpdate], isTrue);
      expect(json[VersionKeys.skipPremium], isTrue);
      expect(json.containsKey(VersionKeys.releasedAt), isFalse);
      expect(json.containsKey(VersionKeys.storeUrl), isFalse);
    });
  });

  group('UserVersionModel', () {
    test('parses user version JSON with string/int buildNumber tolerance', () {
      final jsonWithInt = {
        ApiKeys.id: 'uv_1',
        VersionKeys.platform: 'android',
        VersionKeys.number: '1.0.5',
        VersionKeys.buildNumber: 42,
        VersionKeys.lastSeenAt: '2026-09-20T10:00:00Z',
        VersionKeys.versionId: 'v_100',
      };

      final uv1 = UserVersionModel.fromJson(jsonWithInt);
      expect(uv1.id, 'uv_1');
      expect(uv1.platform, 'android');
      expect(uv1.number, '1.0.5');
      expect(uv1.buildNumber, 42);
      expect(uv1.lastSeenAt, isNotNull);
      expect(uv1.versionId, 'v_100');

      final jsonWithString = {
        ApiKeys.id: 'uv_2',
        VersionKeys.number: '1.0.6',
        VersionKeys.buildNumber: '43',
      };

      final uv2 = UserVersionModel.fromJson(jsonWithString);
      expect(uv2.buildNumber, 43);
    });

    test('serializes UserVersionModel to JSON correctly', () {
      final uv = UserVersionModel(
        id: 'uv_3',
        number: '1.1.0',
        platform: 'ios',
        buildNumber: 50,
      );

      final json = uv.toJson();

      expect(json[ApiKeys.id], 'uv_3');
      expect(json[VersionKeys.number], '1.1.0');
      expect(json[VersionKeys.platform], 'ios');
      expect(json[VersionKeys.buildNumber], 50);
      expect(json.containsKey(VersionKeys.lastSeenAt), isFalse);
      expect(json.containsKey(VersionKeys.versionId), isFalse);
    });
  });
}
