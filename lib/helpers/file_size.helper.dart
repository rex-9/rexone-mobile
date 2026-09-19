import 'dart:math';

/// Utility class for formatting byte sizes and transfer progress into human-readable strings.
class FileSizeHelper {
  const FileSizeHelper._();

  static const List<String> _units = ['B', 'KB', 'MB', 'GB', 'TB'];

  /// Formats a raw byte count into a human-readable string (e.g. `4.2 MB`, `512 KB`, `1.5 GB`).
  ///
  /// Returns an empty string if [bytes] is null or less than or equal to 0.
  static String formatBytes(int? bytes, {int decimals = 1}) {
    if (bytes == null || bytes <= 0) return '';

    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroup = digitGroups.clamp(0, _units.length - 1);
    final value = bytes / pow(1024, clampedGroup);

    if (clampedGroup == 0) {
      return '$bytes ${_units[0]}';
    }

    final formattedValue = value.toStringAsFixed(decimals);
    final cleanValue = formattedValue.endsWith('.0')
        ? formattedValue.substring(0, formattedValue.length - 2)
        : formattedValue;

    return '$cleanValue ${_units[clampedGroup]}';
  }

  /// Formats download transfer progress (e.g. `1.2 MB / 4.2 MB (28%)`).
  static String formatProgress({
    required int? downloadedBytes,
    required int? totalBytes,
    double? fallbackProgress,
  }) {
    final totalFormatted = formatBytes(totalBytes);
    final downloadedFormatted = formatBytes(downloadedBytes);

    final percent = totalBytes != null && totalBytes > 0 && downloadedBytes != null
        ? ((downloadedBytes / totalBytes) * 100).clamp(0, 100).round()
        : ((fallbackProgress ?? 0).clamp(0.0, 1.0) * 100).round();

    if (downloadedFormatted.isNotEmpty && totalFormatted.isNotEmpty) {
      return '$downloadedFormatted / $totalFormatted ($percent%)';
    } else if (totalFormatted.isNotEmpty) {
      return '$totalFormatted ($percent%)';
    } else {
      return '$percent%';
    }
  }
}
