// lib/models/iam.model.dart
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/services/api.service.dart';

class IamModel {
  final bool isAdmin;
  final bool isSuperAdmin;
  final List<IamRoleModel> roles;
  final List<IamRoleModel> adminRoles;
  final List<IamRoleModel> nonAdminRoles;
  final List<IamPermissionModel> permissions;
  final List<IamPermissionModel> adminPermissions;
  final List<IamPermissionModel> nonAdminPermissions;

  const IamModel({
    required this.isAdmin,
    required this.isSuperAdmin,
    this.roles = const [],
    this.adminRoles = const [],
    this.nonAdminRoles = const [],
    this.permissions = const [],
    this.adminPermissions = const [],
    this.nonAdminPermissions = const [],
  });

  factory IamModel.fromJson(Map<String, dynamic> json) => IamModel(
    isAdmin: json[AuthKeys.isAdmin] == true,
    isSuperAdmin: json[AuthKeys.isSuperAdmin] == true,
    roles: parseList(json[AuthKeys.roles], IamRoleModel.fromJson),
    adminRoles: parseList(json[AuthKeys.adminRoles], IamRoleModel.fromJson),
    nonAdminRoles: parseList(json[AuthKeys.nonAdminRoles], IamRoleModel.fromJson),
    permissions: parseList(json[AuthKeys.permissions], IamPermissionModel.fromJson),
    adminPermissions: parseList(json[AuthKeys.adminPermissions], IamPermissionModel.fromJson),
    nonAdminPermissions: parseList(json[AuthKeys.nonAdminPermissions], IamPermissionModel.fromJson),
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

class IamRoleModel {
  final String id;
  final String name;
  final String? description;
  final bool system;

  const IamRoleModel({
    required this.id,
    required this.name,
    this.description,
    this.system = false,
  });

  factory IamRoleModel.fromJson(Map<String, dynamic> json) {
    final flat = ApiService.flattenRecord(json);
    return IamRoleModel(
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

class IamPermissionModel {
  final String id;
  final String name;
  final String action;
  final String resource;

  const IamPermissionModel({
    required this.id,
    required this.name,
    required this.action,
    required this.resource,
  });

  factory IamPermissionModel.fromJson(Map<String, dynamic> json) {
    final flat = ApiService.flattenRecord(json);
    return IamPermissionModel(
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
