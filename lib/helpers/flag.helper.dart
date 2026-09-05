// lib/helpers/flag.helper.dart
class FlagHelper {
  static String getEmoji(String localeCode) {
    switch (localeCode) {
      case 'en_US':
        return '🇺🇸';
      case 'my_MM':
        return '🇲🇲';
      default:
        return '🌐';
    }
  }
}
