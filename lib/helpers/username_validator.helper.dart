import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';

class FullnameValidator {
  const FullnameValidator._();

  static String? error(String name) {
    if (name.trim().length < AppConstants.minNameLength) {
      return AppLocales.auth.signUpInfo.enterFullName.tr;
    }
    return null;
  }
}

class UsernameValidator {
  const UsernameValidator._();

  static final pattern = RegExp(r'^[a-z0-9_]+$');

  static String? error(String username) {
    final value = username.trim().toLowerCase();
    if (value.length < AppConstants.minUsernameLength) {
      return AppLocales.auth.signUpInfo.usernameMinLength.tr;
    }
    if (!pattern.hasMatch(value)) {
      return AppLocales.auth.signUpInfo.usernameCharset.tr;
    }
    return null;
  }
}
