import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/helpers/srt.helper.dart';

void main() {
  group('SrtHelper.parse', () {
    test('parses a single SRT cue with comma milliseconds', () {
      const raw = '''
1
00:00:01,500 --> 00:00:04,000
Hello world
''';

      final cues = SrtHelper.parse(raw);

      expect(cues, hasLength(1));
      expect(cues.first.start, const Duration(milliseconds: 1500));
      expect(cues.first.end, const Duration(milliseconds: 4000));
      expect(cues.first.text, 'Hello world');
    });

    test('parses dot millisecond separators', () {
      const raw = '''
1
00:00:12.500 --> 00:00:15.000
Line with dots
''';

      final cues = SrtHelper.parse(raw);

      expect(cues, hasLength(1));
      expect(cues.first.start, const Duration(milliseconds: 12500));
      expect(cues.first.end, const Duration(milliseconds: 15000));
    });

    test('joins multi-line cue text and strips HTML tags', () {
      const raw = '''
2
00:00:05,000 --> 00:00:08,000
<i>First line</i>
Second line
''';

      final cues = SrtHelper.parse(raw);

      expect(cues, hasLength(1));
      expect(cues.first.text, 'First line Second line');
    });

    test('returns empty list for blank input', () {
      expect(SrtHelper.parse(''), isEmpty);
      expect(SrtHelper.parse('   \n\n  '), isEmpty);
    });

    test('parses multiple cues in order', () {
      const raw = '''
2
00:00:10,000 --> 00:00:12,000
Second

1
00:00:01,000 --> 00:00:03,000
First
''';

      final cues = SrtHelper.parse(raw);

      expect(cues, hasLength(2));
      expect(cues.first.text, 'First');
      expect(cues.last.text, 'Second');
    });
  });

  group('SrtHelper.activeIndexAt', () {
    final cues = SrtHelper.parse('''
1
00:00:01,000 --> 00:00:03,000
One

2
00:00:05,000 --> 00:00:07,000
Two
''');

    test('returns -1 before first cue', () {
      expect(SrtHelper.activeIndexAt(cues, Duration.zero), -1);
    });

    test('returns active cue index during playback', () {
      expect(
        SrtHelper.activeIndexAt(cues, const Duration(milliseconds: 2000)),
        0,
      );
      expect(
        SrtHelper.activeIndexAt(cues, const Duration(milliseconds: 6000)),
        1,
      );
    });

    test('holds last started cue in gap between cues', () {
      expect(
        SrtHelper.activeIndexAt(cues, const Duration(milliseconds: 4000)),
        0,
      );
    });
  });

  group('SrtHelper.formatTimestamp', () {
    test('formats duration into standard SRT timestamp HH:MM:SS,mmm', () {
      expect(
        SrtHelper.formatTimestamp(
          const Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 456),
        ),
        '01:02:03,456',
      );
      expect(SrtHelper.formatTimestamp(Duration.zero), '00:00:00,000');
    });
  });

  group('SrtHelper.bridgeSmallGaps', () {
    test('bridges small inter-cue gaps <= maxGap', () {
      const raw = '''
1
00:00:01,000 --> 00:00:03,000
Hello

2
00:00:03,500 --> 00:00:06,000
World
''';

      final bridged = SrtHelper.bridgeSmallGaps(
        raw,
        maxGap: const Duration(milliseconds: 800),
      );

      final parsed = SrtHelper.parse(bridged);
      expect(parsed, hasLength(2));
      // Cue 1 end extended to Cue 2 start (03,500)
      expect(parsed[0].end, const Duration(milliseconds: 3500));
      expect(parsed[1].start, const Duration(milliseconds: 3500));
    });

    test('preserves large gaps with modest tail cushion', () {
      const raw = '''
1
00:00:01,000 --> 00:00:03,000
Hello

2
00:00:07,000 --> 00:00:09,000
World
''';

      final bridged = SrtHelper.bridgeSmallGaps(
        raw,
        maxGap: const Duration(milliseconds: 800),
      );

      final parsed = SrtHelper.parse(bridged);
      expect(parsed, hasLength(2));
      // Extended by 300ms cushion
      expect(parsed[0].end, const Duration(milliseconds: 3300));
      expect(parsed[1].start, const Duration(milliseconds: 7000));
    });

    test('returns original string if empty or blank', () {
      expect(SrtHelper.bridgeSmallGaps(''), '');
      expect(SrtHelper.bridgeSmallGaps('   '), '   ');
    });
  });
}
