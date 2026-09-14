import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/helpers/date_time.helper.dart';

void main() {
  group('AppDateTime', () {
    test('treats zone-less API timestamps as UTC before local display', () {
      final actual = AppDateTime.fromUtc('2026-09-02T14:30:00');

      expect(actual, isNotNull);
      expect(actual!.toUtc(), DateTime.utc(2026, 9, 2, 14, 30));
    });

    test('serializes local values as UTC ISO 8601', () {
      final local = DateTime(2026, 9, 2, 14, 30);

      expect(AppDateTime.toUtcIso(local), local.toUtc().toIso8601String());
    });

    test('exposes the device timezone and UTC offset', () {
      expect(AppDateTime.timeZoneName, isNotEmpty);
      expect(AppDateTime.utcOffset, startsWith('UTC'));
    });
  });
}
