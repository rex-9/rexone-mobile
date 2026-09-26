// test/services/media_service_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';
import 'package:rexone_mobile/services/media.service.dart';

class MockMediaApiService extends ApiService {
  Response? multipartResponse;
  String? lastUrl;
  FormData? lastForm;

  @override
  void onInit() {}

  @override
  Future<Response<T>> postMultipart<T>(
    String url,
    FormData form, {
    bool showLoading = false,
    Progress? uploadProgress,
  }) async {
    lastUrl = url;
    lastForm = form;
    return (multipartResponse as Response<T>?) ??
        Response<T>(
          statusCode: 200,
          body: {
            'status': {'code': 200, 'success': true, 'message': 'Upload successful'},
            'data': {
              'id': 'ast_test_1',
              'name': 'test.png',
              'url': 'https://garage.example.com/test.png',
              'type': 'avatar',
              'source': 'upload',
              'format': 'png',
              'size_bytes': 1234,
              'assetable_type': 'User',
              'assetable_id': 'u_test_1',
            },
            'meta': {
              'storage_details': {
                'storage_key': 'avatars/test.png',
                'bytes': 1234,
                'format': 'png',
              },
            },
          } as dynamic,
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMediaApiService mockApi;
  late MediaService mediaService;
  late Directory tempDir;
  late File tempFile;

  setUp(() {
    Get.testMode = true;
    mockApi = MockMediaApiService();
    Get.put<ApiService>(mockApi);

    mediaService = Get.put(MediaService());

    tempDir = Directory.systemTemp.createTempSync('media_test_');
    tempFile = File('${tempDir.path}/test_image.png')..writeAsBytesSync([1, 2, 3, 4]);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
    Get.reset();
  });

  group('MediaService - uploadImage', () {
    test('sends multipart request to ServerRoutes.uploadAsset with correct fields', () async {
      final res = await mediaService.uploadImage(
        filePath: tempFile.path,
        filename: 'custom_avatar.png',
        type: AssetKeys.typeAvatar,
        assetableType: AssetKeys.assetableUser,
        assetableId: 'u_test_1',
        durationSecs: 10,
        folder: 'profile_pictures',
      );

      expect(mockApi.lastUrl, equals(ServerRoutes.uploadAsset));
      expect(mockApi.lastForm, isNotNull);
      expect(res.success, isTrue);
      expect(res.data?.id, equals('ast_test_1'));
      expect(res.data?.url, equals('https://garage.example.com/test.png'));
      expect(res.meta?[AssetKeys.storageDetails]['storage_key'], equals('avatars/test.png'));
      expect(res.meta?[AssetKeys.storageDetails]['bytes'], equals(1234));
    });

    test('handles upload error response correctly', () async {
      mockApi.multipartResponse = const Response(
        statusCode: 422,
        body: {
          'status': {
            'code': 422,
            'success': false,
            'error': 'File type not supported',
          },
        },
      );

      final res = await mediaService.uploadImage(
        filePath: tempFile.path,
        type: AssetKeys.typeAvatar,
      );

      expect(res.success, isFalse);
      expect(res.statusCode, equals(422));
      expect(res.message, equals('File type not supported'));
    });
  });
}
