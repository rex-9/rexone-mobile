// lib/models/user.model.dart
import 'package:rexone_mobile/constants/constants.dart';

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
    final attributes = Map<String, dynamic>.from(
      json[AuthKeys.attributes] as Map? ?? json,
    );
    return UserIamRoleModel(
      id:
          json[ApiKeys.id]?.toString() ??
          attributes[ApiKeys.id]?.toString() ??
          '',
      name: attributes[AuthKeys.name]?.toString() ?? '',
      description: attributes[AuthKeys.description]?.toString(),
      system: attributes[AuthKeys.system] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    AuthKeys.resourceType: AuthKeys.roleResourceType,
    AuthKeys.attributes: {
      ApiKeys.id: id,
      AuthKeys.name: name,
      AuthKeys.description: description,
      AuthKeys.system: system,
    },
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
    final attributes = Map<String, dynamic>.from(
      json[AuthKeys.attributes] as Map? ?? json,
    );
    return UserIamPermissionModel(
      id:
          json[ApiKeys.id]?.toString() ??
          attributes[ApiKeys.id]?.toString() ??
          '',
      name: attributes[AuthKeys.name]?.toString() ?? '',
      action: attributes[AuthKeys.action]?.toString() ?? '',
      resource: attributes[AuthKeys.resource]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    ApiKeys.id: id,
    AuthKeys.resourceType: AuthKeys.permissionResourceType,
    AuthKeys.attributes: {
      ApiKeys.id: id,
      AuthKeys.name: name,
      AuthKeys.action: action,
      AuthKeys.resource: resource,
    },
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
    roles: _parseList(json[AuthKeys.roles], UserIamRoleModel.fromJson),
    adminRoles: _parseList(
      json[AuthKeys.adminRoles],
      UserIamRoleModel.fromJson,
    ),
    nonAdminRoles: _parseList(
      json[AuthKeys.nonAdminRoles],
      UserIamRoleModel.fromJson,
    ),
    permissions: _parseList(
      json[AuthKeys.permissions],
      UserIamPermissionModel.fromJson,
    ),
    adminPermissions: _parseList(
      json[AuthKeys.adminPermissions],
      UserIamPermissionModel.fromJson,
    ),
    nonAdminPermissions: _parseList(
      json[AuthKeys.nonAdminPermissions],
      UserIamPermissionModel.fromJson,
    ),
  );

  Map<String, dynamic> toJson() => {
    AuthKeys.isAdmin: isAdmin,
    AuthKeys.isSuperAdmin: isSuperAdmin,
    AuthKeys.roles: roles.map((item) => item.toJson()).toList(),
    AuthKeys.adminRoles: adminRoles.map((item) => item.toJson()).toList(),
    AuthKeys.nonAdminRoles: nonAdminRoles.map((item) => item.toJson()).toList(),
    AuthKeys.permissions: permissions.map((item) => item.toJson()).toList(),
    AuthKeys.adminPermissions: adminPermissions
        .map((item) => item.toJson())
        .toList(),
    AuthKeys.nonAdminPermissions: nonAdminPermissions
        .map((item) => item.toJson())
        .toList(),
  };

  static List<T> _parseList<T>(
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

class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? name;
  final String? provider;
  final String? photo;
  final UserIamModel? iam;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.provider,
    this.photo,
    this.iam,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[ApiKeys.id]?.toString() ?? '',
      email: json[AuthKeys.email] ?? '',
      username: json[AuthKeys.username],
      name: json[AuthKeys.name],
      provider: json[AuthKeys.provider],
      photo: json[AuthKeys.avatarUrl] ?? json[AuthKeys.photo],
      iam: json[AuthKeys.iam] is Map
          ? UserIamModel.fromJson(Map<String, dynamic>.from(json[AuthKeys.iam]))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKeys.id: id,
      AuthKeys.email: email,
      AuthKeys.username: username,
      AuthKeys.name: name,
      AuthKeys.provider: provider,
      AuthKeys.avatarUrl: photo,
      AuthKeys.iam: iam?.toJson(),
    };
  }
}
