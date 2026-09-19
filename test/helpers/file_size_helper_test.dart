import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/helpers/file_size.helper.dart';

void main() {
  group('FileSizeHelper.formatBytes', () {
    test('returns empty string for null, zero, or negative bytes', () {
      expect(FileSizeHelper.formatBytes(null), '');
      expect(FileSizeHelper.formatBytes(0), '');
      expect(FileSizeHelper.formatBytes(-10), '');
    });

    test('formats bytes correctly', () {
      expect(FileSizeHelper.formatBytes(500), '500 B');
      expect(FileSizeHelper.formatBytes(1024), '1 KB');
      expect(FileSizeHelper.formatBytes(1536), '1.5 KB');
      expect(FileSizeHelper.formatBytes(1024 * 1024), '1 MB');
      expect(FileSizeHelper.formatBytes((4.2 * 1024 * 1024).round()), '4.2 MB');
      expect(FileSizeHelper.formatBytes(1024 * 1024 * 1024), '1 GB');
      expect(FileSizeHelper.formatBytes((2.5 * 1024 * 1024 * 1024).round()), '2.5 GB');
    });
  });

  group('FileSizeHelper.formatProgress', () {
    test('formats progress with downloaded and total bytes', () {
      final downloaded = (1.2 * 1024 * 1024).round();
      final total = (4.2 * 1024 * 1024).round();
      final result = FileSizeHelper.formatProgress(
        downloadedBytes: downloaded,
        totalBytes: total,
      );
      expect(result, '1.2 MB / 4.2 MB (29%)');
    });

    test('formats fallback progress when downloadedBytes is null', () {
      final total = (4.2 * 1024 * 1024).round();
      final result = FileSizeHelper.formatProgress(
        downloadedBytes: null,
        totalBytes: total,
        fallbackProgress: 0.5,
      );
      expect(result, '4.2 MB (50%)');
    });

    test('formats fallback percent when totalBytes is null', () {
      final result = FileSizeHelper.formatProgress(
        downloadedBytes: null,
        totalBytes: null,
        fallbackProgress: 0.75,
      );
      expect(result, '75%');
    });
  });
}
