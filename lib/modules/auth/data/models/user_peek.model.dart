import 'package:rexone_mobile/constants/constants.dart';

class UserPeekModel {
  final bool userExists;
  final bool confirmed;

  const UserPeekModel({
    required this.userExists,
    required this.confirmed,
  });

  factory UserPeekModel.fromJson(Map<String, dynamic> json) {
    return UserPeekModel(
      userExists: json[AuthKeys.userExists] as bool? ?? false,
      confirmed: json[AuthKeys.confirmed] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    AuthKeys.userExists: userExists,
    AuthKeys.confirmed: confirmed,
  };
}
