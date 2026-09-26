// lib/models/user.model.dart
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/modules/payment/payment.dart';
import 'iam.model.dart';

class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? name;
  final String? provider;
  final String? photo;
  final IamModel? iam;
  final List<AccessModel> accesses;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.provider,
    this.photo,
    this.iam,
    this.accesses = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      email: json[AuthKeys.email]?.toString() ?? '',
      username: json[AuthKeys.username]?.toString(),
      name: json[AuthKeys.name]?.toString(),
      provider: json[AuthKeys.provider]?.toString(),
      photo: json[AuthKeys.avatarUrl]?.toString() ?? json[AuthKeys.photo]?.toString(),
      iam: json[AuthKeys.iam] is Map
          ? IamModel.fromJson(Map<String, dynamic>.from(json[AuthKeys.iam] as Map))
          : null,
      accesses:
          (json[PaymentKeys.accesses] as List?)
              ?.whereType<Map>()
              .map((item) => AccessModel.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    AuthKeys.email: email,
    AuthKeys.username: username,
    AuthKeys.name: name,
    AuthKeys.provider: provider,
    AuthKeys.avatarUrl: photo,
    AuthKeys.iam: iam?.toJson(),
    PaymentKeys.accesses: accesses.map((e) => e.toJson()).toList(),
  };
}
