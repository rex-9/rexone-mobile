// lib/modules/feedback/services/feedback.service.dart
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/api.service.dart';
import '../data/models/feedback.model.dart';

class FeedbackService extends GetxService {
  late final ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  /// Submit feedback (guest or authenticated)
  Future<ApiResponse<FeedbackModel>> submitFeedback(
      Map<String, dynamic> data) async {
    final response = await _api.post(
      ServerRoutes.feedbacks,
      {FeedbackKeys.feedback: data},
      showLoading: false,
    );

    return _api.parseRecord<FeedbackModel>(
      response,
      FeedbackModel.fromJson,
    );
  }

  /// Fetch authenticated user's submitted feedbacks
  Future<PaginatedResponse<FeedbackModel>> getFeedbacks({
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (page != null) query[ApiKeys.page] = page;
    if (limit != null) query[ApiKeys.limit] = limit;

    final response = await _api.get(ServerRoutes.feedbacks, query: query);

    return _api.parsePagyList<FeedbackModel>(
      response,
      FeedbackModel.fromJson,
    );
  }
}
