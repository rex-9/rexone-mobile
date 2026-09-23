// lib/locales/app_localizations.dart
import 'package:better_player/better_player.dart';
// ignore: implementation_imports
import 'package:better_player/src/controls/better_player_cupertino_localizations_delegate.dart';
// ignore: implementation_imports
import 'package:better_player/src/controls/better_player_material_localizations_delegate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_translations.dart';

/// Official Flutter localization system for RexOne Mobile.
///
/// Bridges the Flutter framework's [Localizations] and [LocalizationsDelegate] architecture
/// with our centralized translation dictionary ([AppTranslations]).
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  /// Retrieves the [AppLocalizations] instance from the given [context].
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// The standard Flutter localization delegate for [AppLocalizations].
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Centralized list of all delegates needed across the application:
  /// - [AppLocalizations.delegate] (App strings)
  /// - [BetterPlayerMaterialLocalizationsDelegate] (Player material controls)
  /// - [BetterPlayerCupertinoLocalizationsDelegate] (Player cupertino controls)
  /// - [GlobalMaterialLocalizations.delegate] (Flutter Material widgets)
  /// - [GlobalWidgetsLocalizations.delegate] (Flutter widget directionality)
  /// - [GlobalCupertinoLocalizations.delegate] (Flutter Cupertino widgets)
  static List<LocalizationsDelegate<dynamic>> get delegates => [
        delegate,
        BetterPlayerMaterialLocalizationsDelegate(PlayerTranslations()),
        BetterPlayerCupertinoLocalizationsDelegate(PlayerTranslations()),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Supported locales derived dynamically from [AppTranslations.supportedLocales].
  static List<Locale> get supportedLocales =>
      AppTranslations.supportedLocales.keys.map((code) {
        final parts = code.split('_');
        return Locale(parts[0], parts.length > 1 ? parts[1] : '');
      }).toList();

  /// Translates a key using the current locale's dictionary, with fallback to en_US.
  String translate(String key, [Map<String, String>? params]) {
    final countryCode = locale.countryCode;
    final localeKey = countryCode != null && countryCode.isNotEmpty
        ? '${locale.languageCode}_$countryCode'
        : locale.languageCode;

    final allTranslations = AppTranslations().keys;
    final dict = allTranslations[localeKey] ??
        allTranslations[locale.languageCode] ??
        allTranslations['en_US'] ??
        const {};

    String value = dict[key] ?? allTranslations['en_US']?[key] ?? key;

    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
        value = value.replaceAll('@$paramKey', paramValue);
      });
    }

    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final languageCode = locale.languageCode;
    for (final key in AppTranslations.supportedLocales.keys) {
      if (key.startsWith(languageCode)) return true;
    }
    return false;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for convenient Flutter widget tree translation access via `context.l10n`.
extension AppLocalizationsContextX on BuildContext {
  AppLocalizations? get l10n => AppLocalizations.of(this);
}
