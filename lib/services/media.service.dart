import 'dart:io';

import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

/// Shared media client — upload, paginated asset listing, and playback URLs.
class MediaService extends GetxService {
  late final ApiService _api;
  final Map<String, AssetPlaybackResponse> _playbackCache = {};

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  void clearPlaybackCache({String? assetId}) {
    if (assetId == null) {
      _playbackCache.clear();
      return;
    }
    _playbackCache.remove(assetId);
  }

  /// Uploads a local file to `POST /v1/assets/upload`.
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

    return _api.parsePaginatedResponse(
      response,
      (item) => AssetModel.fromJson(
        item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  /// Resolves a signed playback URL from `GET /v1/assets/:id/playback`.
  /// Results are cached until [AssetPlaybackResponse.isNearExpiry].
  Future<ApiResponse<AssetPlaybackResponse>> getAssetPlayback(
    String assetId,
  ) async {
    if (assetId.isEmpty) {
      return ApiResponse.error(message: 'Invalid asset id', statusCode: 400);
    }

    final cached = _playbackCache[assetId];
    if (cached != null && !cached.isNearExpiry) {
      return ApiResponse.success(
        data: cached,
        message: 'Playback ready',
        statusCode: 200,
      );
    }

    final response = await _api.get(
      ServerRoutes.assetPlayback(assetId),
      showLoading: false,
    );

    final parsed = _api.parseResponse<AssetPlaybackResponse>(
      response,
      (data) =>
          ApiHelper.parseRecord(data, AssetPlaybackResponse.fromJson) ??
          AssetPlaybackResponse.fromJson(const {}),
    );

    if (parsed.success && parsed.data != null) {
      final data = _withTestPlaybackUrl(parsed.data!);
      _playbackCache[assetId] = data;
      return ApiResponse.success(
        data: data,
        message: parsed.message,
        statusCode: parsed.statusCode,
      );
    }

    return parsed;
  }

  /// Dev-only: swap delivery URL for a fixed public sample when configured.
  AssetPlaybackResponse _withTestPlaybackUrl(AssetPlaybackResponse playback) {
    const testUrl = MediaPlaybackConstants.testPlaybackUrl;
    if (testUrl.isEmpty) return playback;

    return AssetPlaybackResponse(
      assetId: playback.assetId,
      delivery: AssetPlaybackDelivery(
        type: playback.delivery.type,
        url: testUrl,
        expiresAt: playback.delivery.expiresAt,
      ),
      media: playback.media,
    );
  }
}
