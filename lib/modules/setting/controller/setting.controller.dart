import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/design/design.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import '../../../services/storage.service.dart';
import '../../../locales/app_translations.dart';
import 'package:rexone_mobile/constants/constants.dart';

/// Theme + locale settings, persisted with GetStorage.
class SettingController extends GetxController {
  final StorageService _storage = Get.find();

  // ===== OBSERVABLES =====
  var isDarkMode = false.obs; // true = dark, false = light
  var localeCode = 'en_US'.obs; // e.g. 'en_US', 'es_ES', 'my_MM'
  var appVersion = ''.obs; // e.g. '1.0.0'

  // ===== THEME MODE =====
  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  IconData get themeIcon =>
      isDarkMode.value ? Design.icons.darkMode : Design.icons.lightMode;

  String get themeLabel => isDarkMode.value ? 'Dark' : 'Light';

  // ===== LOCALE =====
  Locale get locale {
    final parts = localeCode.value.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : '');
  }

  String get currentLanguageName =>
      AppTranslations.supportedLocales[localeCode.value] ?? 'English';

  List<MapEntry<String, String>> get supportedLocales =>
      AppTranslations.supportedLocales.entries.toList();

  // ===== INIT =====
  @override
  void onInit() {
    super.onInit();
    Get.addTranslations(AppTranslations().keys);
    final savedTheme = _storage.getThemeName();
    isDarkMode.value = savedTheme == EThemePreference.dark.name;
    localeCode.value = _storage.getLocaleCode() ?? 'en_US';
    _loadAppVersion();
  }

  // ===== APP VERSION =====
  void _loadAppVersion() {
    appVersion.value = AppInfo.version;
  }

  // ===== THEME METHODS =====
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.setThemeName(
      isDarkMode.value
          ? EThemePreference.dark.name
          : EThemePreference.light.name,
    );
    Get.changeThemeMode(themeMode);
    update();
  }

  void setDarkMode(bool isDark) {
    isDarkMode.value = isDark;
    _storage.setThemeName(
      isDark ? EThemePreference.dark.name : EThemePreference.light.name,
    );
    Get.changeThemeMode(themeMode);
  }

  // ===== LOCALE METHODS =====
  void setLocale(String code) {
    localeCode.value = code;
    _storage.setLocaleCode(code);
    Get.updateLocale(locale);
    update();
  }

  void changeLocale(String code) => setLocale(code);

  void cycleLocale() {
    final keys = AppTranslations.supportedLocales.keys.toList();
    final currentIndex = keys.indexOf(localeCode.value);
    final nextIndex = (currentIndex + 1) % keys.length;
    setLocale(keys[nextIndex]);
  }

  // ===== CONVENIENCE =====
  bool isLocale(String code) => localeCode.value == code;

  // ===== RESET =====
  void resetToDefaults() {
    isDarkMode.value = Get.isDarkMode;
    _storage.setThemeName(
      isDarkMode.value
          ? EThemePreference.dark.name
          : EThemePreference.light.name,
    );
    Get.changeThemeMode(themeMode);
    setLocale('en_US');
  }
}
