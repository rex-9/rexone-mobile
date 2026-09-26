// test/modules/profile/services/profile_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/modules/profile/data/requests/requests.dart';
import 'package:rexone_mobile/modules/profile/services/profile.service.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

class MockProfileApiService extends ApiService {
  Response? putResponse;
  String? lastUrl;
  dynamic lastBody;

  @override
  void onInit() {}

  @override
  Future<Response<T>> put<T>(
    String url,
    dynamic body, {
    String? contentType,
    Decoder<T>? decoder,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Progress? uploadProgress,
    bool showLoading = true,
  }) async {
    lastUrl = url;
    lastBody = body;
    return (putResponse as Response<T>?) ??
        Response<T>(
          statusCode: 200,
          body: {
            'status': {'code': 200, 'success': true, 'message': 'Updated'},
            'data': {
              'id': 'u_profile_1',
              'name': 'New Profile Name',
              'username': 'new_username',
              'email': 'profile@example.com',
              'photo': 'https://garage.example.com/rexone/new_avatar.png',
            },
          } as dynamic,
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProfileApiService mockApi;
  late ProfileService profileService;

  setUp(() {
    Get.testMode = true;
    mockApi = MockProfileApiService();
    Get.put<ApiService>(mockApi);

    profileService = Get.put(ProfileService());
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileService - updateCurrentUser', () {
    test('sends PUT to ServerRoutes.currentUser with serialized request and parses UserModel', () async {
      final request = UpdateUserRequest(
        name: 'New Profile Name',
        username: 'new_username',
      );

      final result = await profileService.updateCurrentUser(request);

      expect(mockApi.lastUrl, equals(ServerRoutes.currentUser));
      expect(mockApi.lastBody, equals(request.toJson()));
      expect(result.success, isTrue);
      expect(result.data?.id, equals('u_profile_1'));
      expect(result.data?.name, equals('New Profile Name'));
      expect(result.data?.username, equals('new_username'));
      expect(result.data?.email, equals('profile@example.com'));
      expect(result.data?.photo, equals('https://garage.example.com/rexone/new_avatar.png'));
    });

    test('parses JSON:API format (id, type, attributes) correctly', () async {
      mockApi.putResponse = const Response(
        statusCode: 200,
        body: {
          'status': {'code': 200, 'success': true, 'message': 'Updated'},
          'data': {
            'id': 'u_profile_2',
            'type': 'user',
            'attributes': {
              'name': 'JSONAPI Name',
              'username': 'jsonapi_user',
              'email': 'jsonapi@example.com',
            },
          },
        },
      );

      final result = await profileService.updateCurrentUser(
        UpdateUserRequest(name: 'JSONAPI Name', username: 'jsonapi_user'),
      );

      expect(result.success, isTrue);
      expect(result.data?.id, equals('u_profile_2'));
      expect(result.data?.name, equals('JSONAPI Name'));
      expect(result.data?.username, equals('jsonapi_user'));
      expect(result.data?.email, equals('jsonapi@example.com'));
    });

    test('handles error response when update fails', () async {
      mockApi.putResponse = const Response(
        statusCode: 422,
        body: {
          'status': {
            'code': 422,
            'success': false,
            'error': 'Username has already been taken',
          },
        },
      );

      final result = await profileService.updateCurrentUser(
        UpdateUserRequest(name: 'Valid Name', username: 'taken_user'),
      );

      expect(result.success, isFalse);
      expect(result.statusCode, equals(422));
      expect(result.message, equals('Username has already been taken'));
    });
  });
}
