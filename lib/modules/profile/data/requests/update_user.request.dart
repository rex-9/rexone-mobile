import 'package:rexone_mobile/constants/constants.dart';

class UpdateUserRequest {
  final String name;
  final String username;

  const UpdateUserRequest({
    required this.name,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
    AuthKeys.user: {
      AuthKeys.name: name,
      AuthKeys.username: username,
    },
  };
}
