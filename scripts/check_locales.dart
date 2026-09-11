import 'dart:io';

Set<String> placeholders(String value) => RegExp(
  r'@([a-zA-Z0-9_]+)',
).allMatches(value).map((match) => match.group(1)!).toSet();

bool sameSet(Set<String> left, Set<String> right) =>
    left.length == right.length && left.containsAll(right);

Map<String, Set<String>> readLocaleEntries(String source, String locale) {
  final marker = "'$locale': {";
  final start = source.indexOf(marker);
  if (start < 0) return {};
  final end = source.indexOf('\n    },', start);
  if (end < 0) return {};
  final body = source.substring(start + marker.length, end);
  final entryPattern = RegExp(
    r'(AppLocales(?:\.[a-zA-Z_][a-zA-Z0-9_]*)+)\s*:\s*([\s\S]*?)(?=\n\s+AppLocales|$)',
  );

  return {
    for (final match in entryPattern.allMatches(body))
      match.group(1)!: placeholders(match.group(2)!),
  };
}

void main() {
  final root = Directory.current;
  final constantsSource = File(
    '${root.path}/lib/locales/app_locales.dart',
  ).readAsStringSync();
  final translationsSource = File(
    '${root.path}/lib/locales/app_translations.dart',
  ).readAsStringSync();
  final errors = <String>[];

  final supportedMatch = RegExp(
    r'supportedLocales\s*=\s*\{([\s\S]*?)\};',
  ).firstMatch(translationsSource);
  final supportedLocales = RegExp(r"'([a-z]{2}_[A-Z]{2})'\s*:")
      .allMatches(supportedMatch?.group(1) ?? '')
      .map((match) => match.group(1)!)
      .toSet();

  const referenceLocale = 'en_US';
  final locales = {
    for (final locale in supportedLocales)
      locale: readLocaleEntries(translationsSource, locale),
  };
  final reference = locales[referenceLocale] ?? const <String, Set<String>>{};
  final declaredKeys = RegExp(
    r'''['"]([a-z][a-z0-9_]*(?:\.[a-z0-9_]+)+)['"]''',
  ).allMatches(constantsSource).map((match) => match.group(1)!).toList();

  if (supportedLocales.isEmpty) errors.add('supportedLocales is empty');
  if (reference.isEmpty) {
    errors.add('$referenceLocale translations are missing');
  }
  if (declaredKeys.length != declaredKeys.toSet().length) {
    errors.add('AppLocales contains duplicate key values');
  }
  if (declaredKeys.toSet().length != reference.length) {
    errors.add(
      'AppLocales declares ${declaredKeys.toSet().length} keys but '
      '$referenceLocale translates ${reference.length}',
    );
  }

  for (final locale in supportedLocales) {
    final entries = locales[locale] ?? const <String, Set<String>>{};
    for (final key in reference.keys.toSet().difference(entries.keys.toSet())) {
      errors.add('$locale is missing $key');
    }
    for (final key in entries.keys.toSet().difference(reference.keys.toSet())) {
      errors.add('$locale has unexpected key $key');
    }
    for (final key in reference.keys.toSet().intersection(
      entries.keys.toSet(),
    )) {
      if (!sameSet(reference[key]!, entries[key]!)) {
        errors.add('$locale.$key has different interpolation placeholders');
      }
    }
  }

  final rawTranslation = RegExp(
    r'''["'][a-z][a-z0-9_]*(?:\.[a-z0-9_]+)+["']\s*\.tr(?:Params)?\b''',
  );
  final dartFiles = Directory('${root.path}/lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (file) =>
            file.path.endsWith('.dart') && !file.path.contains('/lib/locales/'),
      );
  for (final file in dartFiles) {
    final relative = file.path.replaceFirst('${root.path}/', '');
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      if (rawTranslation.hasMatch(lines[index])) {
        errors.add(
          '$relative:${index + 1}: raw translation key; use AppLocales',
        );
      }
    }
  }

  stdout.writeln(
    'Mobile locale report: ${supportedLocales.length} locales, '
    '${reference.length} translated keys.',
  );
  if (errors.isNotEmpty) {
    stderr.writeln('Mobile locale checks failed (${errors.length}):');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Mobile locale checks passed.');
}
