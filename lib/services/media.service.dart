import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

/// Shared media client — upload and paginated asset listing.
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

  /// Lists paginated assets from `GET /v1/assets`.
  /// [type] is omitted from the query when null or empty.
  Future<PaginatedResponse<AssetModel>> getAssets({
    String? type,
    int page = 1,
    int limit = 10,
  }) async {
    final query = <String, dynamic>{
      ApiKeys.page: page.toString(),
      ApiKeys.limit: limit.toString(),
    };
    if (type != null && type.isNotEmpty) {
      query[AssetKeys.type] = type;
    }

    final response = await _api.get(
      ServerRoutes.assets,
      query: query,
      showLoading: false,
    );

    debugPrint("audio ==>${response.body.toString()}");

    return _api.parsePaginatedResponse(
      response,
      (item) => AssetModel.fromJson(
        item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map),
      ),
    );
  }
}
