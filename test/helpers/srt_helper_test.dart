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
      expect(
        SrtHelper.activeIndexAt(cues, Duration.zero),
        -1,
      );
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
}
