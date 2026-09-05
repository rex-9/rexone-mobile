import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';

import '../data/requests/requests.dart';

class ProfileService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<ApiResponse<UserModel>> updateCurrentUser(
    UpdateUserRequest request,
  ) async {
    final response = await _api.put(
      ServerRoutes.currentUser,
      request.toJson(),
    );
    return _api.parseResponse<UserModel>(
      response,
      (data) => UserModel.fromJson(data[AuthKeys.user]),
    );
  }
}
