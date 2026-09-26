// lib/models/user.model.dart
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/modules/payment/payment.dart';
import 'package:rexone_mobile/services/api.service.dart';

class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? name;
  final String? provider;
  final String? photo;
  final UserIamModel? iam;
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
          ? UserIamModel.fromJson(Map<String, dynamic>.from(json[AuthKeys.iam] as Map))
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

class UserIamModel {
  final bool isAdmin;
  final bool isSuperAdmin;
  final List<UserIamRoleModel> roles;
  final List<UserIamRoleModel> adminRoles;
  final List<UserIamRoleModel> nonAdminRoles;
  final List<UserIamPermissionModel> permissions;
  final List<UserIamPermissionModel> adminPermissions;
  final List<UserIamPermissionModel> nonAdminPermissions;

  const UserIamModel({
    required this.isAdmin,
    required this.isSuperAdmin,
    this.roles = const [],
    this.adminRoles = const [],
    this.nonAdminRoles = const [],
    this.permissions = const [],
    this.adminPermissions = const [],
    this.nonAdminPermissions = const [],
  });

  factory UserIamModel.fromJson(Map<String, dynamic> json) => UserIamModel(
    isAdmin: json[AuthKeys.isAdmin] == true,
    isSuperAdmin: json[AuthKeys.isSuperAdmin] == true,
    roles: parseList(json[AuthKeys.roles], UserIamRoleModel.fromJson),
    adminRoles: parseList(json[AuthKeys.adminRoles], UserIamRoleModel.fromJson),
    nonAdminRoles: parseList(json[AuthKeys.nonAdminRoles], UserIamRoleModel.fromJson),
    permissions: parseList(json[AuthKeys.permissions], UserIamPermissionModel.fromJson),
    adminPermissions: parseList(json[AuthKeys.adminPermissions], UserIamPermissionModel.fromJson),
    nonAdminPermissions: parseList(json[AuthKeys.nonAdminPermissions], UserIamPermissionModel.fromJson),
  );

  Map<String, dynamic> toJson() => {
    AuthKeys.isAdmin: isAdmin,
    AuthKeys.isSuperAdmin: isSuperAdmin,
    AuthKeys.roles: roles.map((e) => e.toJson()).toList(),
    AuthKeys.adminRoles: adminRoles.map((e) => e.toJson()).toList(),
    AuthKeys.nonAdminRoles: nonAdminRoles.map((e) => e.toJson()).toList(),
    AuthKeys.permissions: permissions.map((e) => e.toJson()).toList(),
    AuthKeys.adminPermissions: adminPermissions.map((e) => e.toJson()).toList(),
    AuthKeys.nonAdminPermissions: nonAdminPermissions.map((e) => e.toJson()).toList(),
  };

  static List<T> parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => parser(Map<String, dynamic>.from(item)))
        .toList();
  }
}

class UserIamRoleModel {
  final String id;
  final String name;
  final String? description;
  final bool system;

  const UserIamRoleModel({
    required this.id,
    required this.name,
    this.description,
    this.system = false,
  });

  factory UserIamRoleModel.fromJson(Map<String, dynamic> json) {
    final flat = ApiService.flattenRecord(json);
    return UserIamRoleModel(
      id: flat[ApiKeys.id]?.toString() ?? '',
      name: flat[AuthKeys.name]?.toString() ?? '',
      description: flat[AuthKeys.description]?.toString(),
      system: flat[AuthKeys.system] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    AuthKeys.name: name,
    if (description != null) AuthKeys.description: description,
    AuthKeys.system: system,
  };
}

class UserIamPermissionModel {
  final String id;
  final String name;
  final String action;
  final String resource;

  const UserIamPermissionModel({
    required this.id,
    required this.name,
    required this.action,
    required this.resource,
  });

  factory UserIamPermissionModel.fromJson(Map<String, dynamic> json) {
    final flat = ApiService.flattenRecord(json);
    return UserIamPermissionModel(
      id: flat[ApiKeys.id]?.toString() ?? '',
      name: flat[AuthKeys.name]?.toString() ?? '',
      action: flat[AuthKeys.action]?.toString() ?? '',
      resource: flat[AuthKeys.resource]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    AuthKeys.name: name,
    AuthKeys.action: action,
    AuthKeys.resource: resource,
  };
}
