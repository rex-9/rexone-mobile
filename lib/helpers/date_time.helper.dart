// lib/helpers/date_time.helper.dart

class AppDateTime {
  const AppDateTime._();

  static DateTime? fromUtc(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    final utc = parsed.isUtc
        ? parsed
        : DateTime.utc(
            parsed.year,
            parsed.month,
            parsed.day,
            parsed.hour,
            parsed.minute,
            parsed.second,
            parsed.millisecond,
            parsed.microsecond,
          );
    return utc.toLocal();
  }

  static String? toUtcIso(DateTime? value) => value?.toUtc().toIso8601String();

  static String get timeZoneName => DateTime.now().timeZoneName;

  static String get utcOffset {
    final offset = DateTime.now().timeZoneOffset;
    if (offset == Duration.zero) return 'UTC';
    final sign = offset.isNegative ? '−' : '+';
    final minutes = offset.inMinutes.abs();
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return 'UTC$sign$hours${remainder == 0 ? '' : ':${remainder.toString().padLeft(2, '0')}'}';
  }

  static String formatLocalDate(dynamic value) {
    final date = fromUtc(value);
    if (date == null) return '—';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
