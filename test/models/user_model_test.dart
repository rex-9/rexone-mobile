import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/payment/payment.dart';

void main() {
  group('UserModel - Serialization', () {
    test('parses complete user JSON including IAM and Accesses', () {
      final json = {
        ApiKeys.id: 'usr_abc',
        AuthKeys.email: 'rex@example.com',
        AuthKeys.username: 'rexdev',
        AuthKeys.name: 'Rex Dev',
        AuthKeys.provider: 'email',
        AuthKeys.avatarUrl: 'https://cdn.rexone.com/avatars/rex.png',
        AuthKeys.iam: {
          AuthKeys.isAdmin: true,
          AuthKeys.isSuperAdmin: false,
          AuthKeys.roles: [
            {
              ApiKeys.id: 'role_1',
              AuthKeys.name: 'Moderator',
              AuthKeys.description: 'Content moderator',
              AuthKeys.system: false,
            },
          ],
          AuthKeys.adminRoles: [],
          AuthKeys.nonAdminRoles: [],
          AuthKeys.permissions: [
            {
              ApiKeys.id: 'perm_1',
              AuthKeys.name: 'Manage Posts',
              AuthKeys.action: 'manage',
              AuthKeys.resource: 'posts',
            },
          ],
          AuthKeys.adminPermissions: [],
          AuthKeys.nonAdminPermissions: [],
        },
        PaymentKeys.accesses: [
          {
            ApiKeys.id: 'acc_1',
            PaymentKeys.status: 'active',
            PaymentKeys.productId: 'prod_pass',
            PaymentKeys.productCode: 'PASS',
            PaymentKeys.productName: 'Full Pass',
            PaymentKeys.active: true,
          },
        ],
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'usr_abc');
      expect(user.email, 'rex@example.com');
      expect(user.username, 'rexdev');
      expect(user.name, 'Rex Dev');
      expect(user.provider, 'email');
      expect(user.photo, 'https://cdn.rexone.com/avatars/rex.png');

      // IAM verification
      expect(user.iam, isNotNull);
      expect(user.iam!.isAdmin, isTrue);
      expect(user.iam!.isSuperAdmin, isFalse);
      expect(user.iam!.roles.length, 1);
      expect(user.iam!.roles.first.id, 'role_1');
      expect(user.iam!.roles.first.name, 'Moderator');
      expect(user.iam!.permissions.length, 1);
      expect(user.iam!.permissions.first.id, 'perm_1');
      expect(user.iam!.permissions.first.action, 'manage');
      expect(user.iam!.permissions.first.resource, 'posts');

      // Accesses verification
      expect(user.accesses.length, 1);
      expect(user.accesses.first.id, 'acc_1');
      expect(user.accesses.first.productId, 'prod_pass');
      expect(user.accesses.first.isCurrentlyActive, isTrue);
    });

    test('serializes UserModel to JSON roundtrip', () {
      final user = UserModel(
        id: 'usr_xyz',
        email: 'test@example.com',
        username: 'testguy',
        name: 'Test Guy',
        provider: 'google',
        photo: 'https://cdn.rexone.com/avatar.jpg',
        iam: const UserIamModel(
          isAdmin: false,
          isSuperAdmin: false,
          roles: [],
          permissions: [],
        ),
        accesses: [
          AccessModel(
            id: 'acc_2',
            status: 'active',
            productId: 'prod_sub',
            active: true,
          ),
        ],
      );

      final json = user.toJson();

      expect(json[ApiKeys.id], 'usr_xyz');
      expect(json[AuthKeys.email], 'test@example.com');
      expect(json[AuthKeys.username], 'testguy');
      expect(json[AuthKeys.name], 'Test Guy');
      expect(json[AuthKeys.provider], 'google');
      expect(json[AuthKeys.avatarUrl], 'https://cdn.rexone.com/avatar.jpg');
      expect(json[AuthKeys.iam], isA<Map>());
      expect(json[PaymentKeys.accesses], isA<List>());
      expect((json[PaymentKeys.accesses] as List).length, 1);
    });

    test('handles minimal JSON gracefully with default empty accesses and null IAM', () {
      final json = {
        ApiKeys.id: 'usr_min',
        AuthKeys.email: 'min@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'usr_min');
      expect(user.email, 'min@example.com');
      expect(user.username, isNull);
      expect(user.name, isNull);
      expect(user.photo, isNull);
      expect(user.iam, isNull);
      expect(user.accesses, isEmpty);
    });
  });

  group('UserIamRoleModel & UserIamPermissionModel', () {
    test('UserIamRoleModel flattens JSON:API envelope correctly', () {
      final json = {
        ApiKeys.id: 'role_admin',
        'type': 'role',
        ApiKeys.attributes: {
          AuthKeys.name: 'Administrator',
          AuthKeys.description: 'System administrator',
          AuthKeys.system: true,
        },
      };

      final role = UserIamRoleModel.fromJson(json);

      expect(role.id, 'role_admin');
      expect(role.name, 'Administrator');
      expect(role.description, 'System administrator');
      expect(role.system, isTrue);
    });

    test('UserIamPermissionModel flattens JSON:API envelope correctly', () {
      final json = {
        ApiKeys.id: 'perm_delete',
        'type': 'permission',
        ApiKeys.attributes: {
          AuthKeys.name: 'Delete User',
          AuthKeys.action: 'destroy',
          AuthKeys.resource: 'user',
        },
      };

      final perm = UserIamPermissionModel.fromJson(json);

      expect(perm.id, 'perm_delete');
      expect(perm.name, 'Delete User');
      expect(perm.action, 'destroy');
      expect(perm.resource, 'user');
    });
  });
}
