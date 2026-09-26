import 'package:get/get.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';

import '../data/requests/requests.dart';

class ProfileService extends GetxService {
  late final ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  Future<ApiResponse<UserModel>> updateCurrentUser(
    UpdateUserRequest request,
  ) async {
    final response = await _api.put(
      ServerRoutes.currentUser,
      request.toJson(),
    );
    return _api.parseRecord<UserModel>(
      response,
      UserModel.fromJson,
    );
  }
}
