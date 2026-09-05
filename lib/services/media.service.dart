import 'dart:io';

import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

/// Shared media upload client. Any controller can `Get.find<MediaService>()`.
class MediaService extends GetxService {
  late final ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  /// Uploads a local file to `POST /v1/media/upload`.
  Future<ApiResponse<AssetUploadResponse>> uploadImage({
    required String filePath,
    String? filename,
    String? type,
    String? assetableType,
    String? assetableId,
    int? durationSecs,
    String? folder,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final name = filename ?? file.uri.pathSegments.last;

    final form = FormData({
      AssetKeys.file: MultipartFile(bytes, filename: name),
      AssetKeys.type: ?type,
      AssetKeys.assetableType: ?assetableType,
      AssetKeys.assetableId: ?assetableId,
      if (durationSecs != null) AssetKeys.durationSecs: durationSecs.toString(),
      AssetKeys.folder: ?folder,
    });

    final response = await _api.postMultipart(
      ServerRoutes.uploadAsset,
      form,
      showLoading: true,
    );

    return _api.parseResponse<AssetUploadResponse>(
      response,
      (data) =>
          ApiHelper.parseRecord(data, AssetUploadResponse.fromJson) ??
          AssetUploadResponse.fromJson(const {}),
    );
  }
}
