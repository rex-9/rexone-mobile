import 'dart:io';

import 'package:flutter/foundation.dart';
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
  final Map<String, String> _subtitleBodyCache = {};
  final GetConnect _subtitleClient = GetConnect();

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  void clearPlaybackCache({String? assetId}) {
    if (assetId == null) {
      _playbackCache.clear();
      _subtitleBodyCache.clear();
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
      (data) => ApiHelper.parseRecord(data, AssetPlaybackResponse.fromJson),
    );

    final playback = parsed.data;
    if (parsed.success &&
        playback != null &&
        playback.delivery.url.isNotEmpty) {
      _playbackCache[assetId] = playback;
    } else if (cached != null && cached.isNearExpiry) {
      // Refetch failed or returned unusable data — drop the stale entry.
      _playbackCache.remove(assetId);
    }

    return parsed;
  }

  /// Loads SRT/VTT body from a local path or signed network URL.
  /// Network responses are cached by normalized URL for the session.
  Future<String?> fetchSubtitleBody(String url) async {
    if (url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri != null && uri.scheme == 'file') {
      return _readLocalSubtitle(uri.toFilePath());
    }

    if (!url.contains('://')) {
      return _readLocalSubtitle(url);
    }

    final normalizedUrl = UrlHelper.normalize(url);
    final cached = _subtitleBodyCache[normalizedUrl];
    if (cached != null) return cached;

    final headers = UrlHelper.headersFor(normalizedUrl);
    final response = await _subtitleClient.get(
      normalizedUrl,
      headers: headers.isEmpty ? null : headers,
    );
    if (!response.isOk) {
      debugPrint(
        '❌ [MediaService] Subtitle fetch ${response.statusCode}: '
        '$normalizedUrl',
      );
      return null;
    }

    final body = response.bodyString;
    if (body == null || body.trim().isEmpty) return null;
    _subtitleBodyCache[normalizedUrl] = body;
    return body;
  }

  Future<String?> _readLocalSubtitle(String path) async {
    final cached = _subtitleBodyCache[path];
    if (cached != null) return cached;

    final file = File(path);
    if (!await file.exists()) return null;
    final body = await file.readAsString();
    if (body.trim().isEmpty) return null;
    _subtitleBodyCache[path] = body;
    return body;
  }
}
