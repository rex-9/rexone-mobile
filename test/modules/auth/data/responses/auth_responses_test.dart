import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/models/user.model.dart';
import 'package:rexone_mobile/modules/auth/data/responses/signin.response.dart';
import 'package:rexone_mobile/modules/auth/data/responses/auth.response.dart';
import 'package:rexone_mobile/modules/auth/data/responses/user.response.dart';
import 'package:rexone_mobile/modules/auth/data/responses/google.response.dart';

void main() {
  group('Auth Responses', () {
    group('UserModel', () {
      test('fromJson parses name field correctly', () {
        final json = {
          'id': '1',
          'email': 'test@example.com',
          'username': 'testuser',
          'name': 'Test User',
          'provider': 'email',
          'avatar_url': 'https://example.com/pic.jpg',
        };

        final user = UserModel.fromJson(json);

        expect(user.id, equals('1'));
        expect(user.email, equals('test@example.com'));
        expect(user.username, equals('testuser'));
        expect(user.name, equals('Test User')); // Critical check
        expect(user.provider, equals('email'));
        expect(user.photo, equals('https://example.com/pic.jpg'));
      });

      test('fromJson handles missing optional fields gracefully', () {
        final json = {'id': '1', 'email': 'test@example.com'};

        final user = UserModel.fromJson(json);

        expect(user.id, equals('1'));
        expect(user.email, equals('test@example.com'));
        expect(user.username, isNull);
        expect(user.name, isNull);
      });

      test('round-trip serialization preserves all fields including name', () {
        final originalUser = UserModel(
          id: '123',
          email: 'roundtrip@example.com',
          username: 'rtuser',
          name: 'Round Trip',
          provider: 'google',
          photo: 'photo_url',
        );

        final json = originalUser.toJson();
        final recreatedUser = UserModel.fromJson(json);

        expect(recreatedUser.id, equals(originalUser.id));
        expect(recreatedUser.email, equals(originalUser.email));
        expect(recreatedUser.username, equals(originalUser.username));
        expect(recreatedUser.name, equals(originalUser.name));
        expect(recreatedUser.provider, equals(originalUser.provider));
        expect(recreatedUser.photo, equals(originalUser.photo));
      });

      test(
        'parses and preserves the nested IAM snapshot for local storage',
        () {
          final user = UserModel.fromJson({
            'id': 'admin-1',
            'email': 'admin@example.com',
            'iam': {
              'is_admin': true,
              'is_super_admin': false,
              'roles': [
                {
                  'id': 'role-1',
                  'type': 'role',
                  'attributes': {
                    'id': 'role-1',
                    'name': 'feedback_admin',
                    'system': false,
                  },
                },
              ],
              'admin_roles': [],
              'non_admin_roles': [],
              'permissions': [],
              'admin_permissions': [
                {
                  'id': 'permission-1',
                  'type': 'permission',
                  'attributes': {
                    'id': 'permission-1',
                    'name': 'read_feedbacks',
                    'action': 'read',
                    'resource': 'feedbacks',
                  },
                },
              ],
              'non_admin_permissions': [],
            },
          });

          final restored = UserModel.fromJson(user.toJson());

          expect(restored.iam?.isAdmin, isTrue);
          expect(restored.iam?.isSuperAdmin, isFalse);
          expect(restored.iam?.roles.single.name, equals('feedback_admin'));
          expect(restored.iam?.adminPermissions.single.action, equals('read'));
          expect(
            restored.iam?.adminPermissions.single.resource,
            equals('feedbacks'),
          );
        },
      );
    });

    group('SignInResponse', () {
      test('fromJson parses user, token, and other fields', () {
        final json = {
          'user': {'id': '1', 'email': 'test@example.com', 'name': 'Test'},
          'token': 'abc.def.ghi',
          'otp_sent': true,
          'remaining_attempts': 3,
          'cooldown_remaining': 60,
        };

        final response = SignInResponse.fromJson(json);

        expect(response.user, isNotNull);
        expect(response.user?.id, equals('1'));
        expect(response.user?.name, equals('Test'));
        expect(response.token, equals('abc.def.ghi'));
        expect(response.otpSent, isTrue);
        expect(response.remainingAttempts, equals(3));
        expect(response.cooldownRemaining, equals(60));
      });
    });

    group('AuthResponse', () {
      test('fromJson parses user and token', () {
        final json = {
          'user': {'id': '2', 'email': 'auth@example.com', 'name': 'Auth'},
          'token': 'token123',
        };

        final response = AuthResponse.fromJson(json);

        expect(response.user, isNotNull);
        expect(response.user.id, equals('2'));
        expect(response.token, equals('token123'));
      });
    });

    group('PeekUserResponse', () {
      test('fromJson parses userExists and confirmed', () {
        final json = {'user_exists': true, 'confirmed': false};

        final response = PeekUserResponse.fromJson(json);

        expect(response.userExists, isTrue);
        expect(response.confirmed, isFalse);
      });
    });

    group('GoogleResponse', () {
      test('fromJson parses fields correctly', () {
        final json = {
          'password_required': true,
          'challenge_token': 'challenge123',
          'user': {'id': '3', 'email': 'google@example.com'},
          'token': 'google_token',
        };

        final response = GoogleResponse.fromJson(json);

        expect(response.passwordRequired, isTrue);
        expect(response.challengeToken, equals('challenge123'));
        expect(response.user, isNotNull);
        expect(response.user?.email, equals('google@example.com'));
        expect(response.token, equals('google_token'));
      });
    });
  });
}
