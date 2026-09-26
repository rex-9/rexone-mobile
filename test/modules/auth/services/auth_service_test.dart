// test/modules/auth/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

class MockAuthApiService extends ApiService {
  Response? postResponse;
  Response? getResponse;
  String? lastUrl;
  dynamic lastBody;

  @override
  void onInit() {}

  @override
  Future<Response<T>> post<T>(
    String? url,
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
    return (postResponse as Response<T>?) ??
        Response<T>(
          statusCode: 201,
          body: {
            'status': {'code': 201, 'success': true, 'message': 'Signed up'},
            'data': {
              'id': 'u_new_1',
              'type': 'user',
              'attributes': {
                'name': 'New User',
                'username': 'new_user',
                'email': 'new@example.com',
              },
            },
          } as dynamic,
        );
  }

  @override
  Future<Response<T>> get<T>(
    String? url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    bool showLoading = true,
  }) async {
    lastUrl = url;
    return (getResponse as Response<T>?) ??
        Response<T>(
          statusCode: 200,
          body: {
            'status': {'code': 200, 'success': true, 'message': 'Fetched'},
            'data': {
              'id': 'u_current_1',
              'type': 'user',
              'attributes': {
                'name': 'Current User',
                'username': 'current_user',
                'email': 'current@example.com',
              },
            },
          } as dynamic,
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthApiService mockApi;
  late AuthService authService;

  setUp(() {
    Get.testMode = true;
    mockApi = MockAuthApiService();
    Get.put<ApiService>(mockApi);

    authService = Get.put(AuthService());
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthService - signUp', () {
    test('sends POST to ServerRoutes.signUp and parses JSON:API user record', () async {
      final request = SignUpRequest(
        name: 'New User',
        username: 'new_user',
        email: 'new@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
      );

      final result = await authService.signUp(request);

      expect(mockApi.lastUrl, equals(ServerRoutes.signUp));
      expect(result.success, isTrue);
      expect(result.data?.id, equals('u_new_1'));
      expect(result.data?.name, equals('New User'));
      expect(result.data?.email, equals('new@example.com'));
    });
  });

  group('AuthService - getCurrentUser', () {
    test('sends GET to ServerRoutes.currentUser and parses JSON:API user record', () async {
      final result = await authService.getCurrentUser();

      expect(mockApi.lastUrl, equals(ServerRoutes.currentUser));
      expect(result.success, isTrue);
      expect(result.data?.id, equals('u_current_1'));
      expect(result.data?.name, equals('Current User'));
      expect(result.data?.email, equals('current@example.com'));
    });

    test('parses flat user record payload', () async {
      mockApi.getResponse = const Response(
        statusCode: 200,
        body: {
          'status': {'code': 200, 'success': true, 'message': 'Fetched'},
          'data': {
            'id': 'u_flat_1',
            'name': 'Flat User',
            'username': 'flat_user',
            'email': 'flat@example.com',
          },
        },
      );

      final result = await authService.getCurrentUser();

      expect(result.success, isTrue);
      expect(result.data?.id, equals('u_flat_1'));
      expect(result.data?.name, equals('Flat User'));
      expect(result.data?.email, equals('flat@example.com'));
    });
  });
}
