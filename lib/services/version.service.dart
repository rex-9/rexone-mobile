
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';

class VersionService extends GetxService {
  late final ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  Future<ApiResponse<VersionModel>> getCurrent({
    required String version,
    int? buildNumber,
  }) async {
    final query = <String, dynamic>{
      VersionKeys.version: version,
      if (buildNumber != null) VersionKeys.buildNumber: buildNumber.toString(),
    };
    final response = await _api.get(
      ServerRoutes.currentVersion,
      query: query,
      showLoading: false,
    );
    return _api.parseRecord<VersionModel>(
      response,
      VersionModel.fromJson,
    );
  }

  Future<ApiResponse<UserVersionModel>> reportUserVersion({
    required String version,
    required int buildNumber,
  }) async {
    final response = await _api.post(
      ServerRoutes.userVersion,
      {
        VersionKeys.userVersion: {
          VersionKeys.version: version,
          VersionKeys.buildNumber: buildNumber,
        },
      },
      showLoading: false,
    );
    return _api.parseRecord<UserVersionModel>(
      response,
      UserVersionModel.fromJson,
    );
  }
}
