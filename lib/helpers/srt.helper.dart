// lib/helpers/srt.helper.dart

class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
  });
}

class SrtHelper {
  const SrtHelper._();

  static final _timestampPattern = RegExp(
    r'(\d{2}):(\d{2}):(\d{2})([,.])(\d{3})\s*-->\s*'
    r'(\d{2}):(\d{2}):(\d{2})([,.])(\d{3})',
  );
  static final _htmlTagPattern = RegExp(r'<[^>]+>');

  /// Parses SRT / WebVTT-style timed text into ordered cues.
  static List<SubtitleCue> parse(String raw) {
    if (raw.trim().isEmpty) return const [];

    final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = normalized.split(RegExp(r'\n\s*\n'));
    final cues = <SubtitleCue>[];

    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      var index = 0;
      if (RegExp(r'^\d+$').hasMatch(lines.first)) {
        index = 1;
      }
      if (index >= lines.length) continue;

      final match = _timestampPattern.firstMatch(lines[index]);
      if (match == null) continue;

      final start = _durationFromMatch(match, 1);
      final end = _durationFromMatch(match, 6);
      if (end <= start) continue;

      final textLines = lines.sublist(index + 1);
      if (textLines.isEmpty) continue;

      final text = textLines
          .map(_stripTags)
          .where((line) => line.isNotEmpty)
          .join(' ')
          .trim();
      if (text.isEmpty) continue;

      cues.add(SubtitleCue(start: start, end: end, text: text));
    }

    cues.sort((a, b) => a.start.compareTo(b.start));
    return cues;
  }

  /// Returns the index of the cue active at [position], or -1 if none.
  static int activeIndexAt(List<SubtitleCue> cues, Duration position) {
    if (cues.isEmpty) return -1;

    var low = 0;
    var high = cues.length - 1;
    var result = -1;

    while (low <= high) {
      final mid = low + ((high - low) >> 1);
      final cue = cues[mid];
      if (position < cue.start) {
        high = mid - 1;
      } else {
        result = mid;
        if (position < cue.end) return mid;
        low = mid + 1;
      }
    }

    if (result >= 0 &&
        position >= cues[result].start &&
        position < cues[result].end) {
      return result;
    }

    // Fall back: hold the last started cue until the next one begins.
    for (var i = cues.length - 1; i >= 0; i--) {
      if (position >= cues[i].start) return i;
    }
    return -1;
  }

  /// Formats [duration] as a standard SRT timestamp: `HH:MM:SS,mmm`.
  static String formatTimestamp(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final millis = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$millis';
  }

  /// Normalizes raw SRT content by bridging small inter-cue gaps (<= [maxGap])
  /// between consecutive subtitles and extending cue endings with a small cushion.
  ///
  /// Prevents blank subtitle flickers when seeking or rewinding into brief pauses
  /// between dialogue segments.
  static String bridgeSmallGaps(
    String raw, {
    Duration maxGap = const Duration(milliseconds: 800),
  }) {
    final cues = parse(raw);
    if (cues.isEmpty) return raw;

    final buffer = StringBuffer();
    for (var i = 0; i < cues.length; i++) {
      final cue = cues[i];
      var cueEnd = cue.end;

      if (i + 1 < cues.length) {
        final nextStart = cues[i + 1].start;
        final gap = nextStart - cueEnd;
        if (gap > Duration.zero && gap <= maxGap) {
          cueEnd = nextStart;
        } else if (gap > maxGap) {
          final extended = cueEnd + const Duration(milliseconds: 300);
          cueEnd = extended < nextStart ? extended : nextStart;
        }
      } else {
        cueEnd += const Duration(milliseconds: 500);
      }

      buffer.writeln('${i + 1}');
      buffer.writeln(
        '${formatTimestamp(cue.start)} --> ${formatTimestamp(cueEnd)}',
      );
      buffer.writeln(cue.text);
      buffer.writeln();
    }

    return buffer.toString().trimRight();
  }

  static Duration _durationFromMatch(RegExpMatch match, int startGroup) {
    final hours = int.parse(match.group(startGroup)!);
    final minutes = int.parse(match.group(startGroup + 1)!);
    final seconds = int.parse(match.group(startGroup + 2)!);
    final millis = int.parse(match.group(startGroup + 4)!);
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: millis,
    );
  }

  static String _stripTags(String value) {
    return value.replaceAll(_htmlTagPattern, '').trim();
  }
}
