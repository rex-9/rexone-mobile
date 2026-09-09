// test/mocks/test_services.dart
// ignore_for_file: must_call_super
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/modules/ai/ai.dart';
import 'package:rexone_mobile/modules/auth/auth.dart';
import 'package:rexone_mobile/modules/feedback/data/models/feedback.model.dart';
import 'package:rexone_mobile/modules/feedback/services/feedback.service.dart';
import 'package:rexone_mobile/modules/notification/notification.dart';
import 'package:rexone_mobile/modules/payment/payment.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rexone_mobile/modules/profile/profile.dart';
import 'package:rexone_mobile/services/analytics.service.dart';
import 'package:rexone_mobile/services/media.service.dart';
import 'package:rexone_mobile/services/network.service.dart';
import 'package:rexone_mobile/services/permission.service.dart';
import 'package:rexone_mobile/services/push_noti.service.dart';
import 'package:rexone_mobile/services/socket.service.dart';
import 'package:rexone_mobile/services/speech.service.dart';
import 'package:rexone_mobile/services/version.service.dart';
import 'package:rexone_mobile/services/storage.service.dart';

/// In-memory storage service that replaces GetStorage box for unit tests.
class FakeStorageService extends StorageService {
  final Map<String, dynamic> memory = {};

  @override
  void onInit() {}

  @override
  void setToken(String token) => memory[StorageKeys.token] = token;

  @override
  String? getToken() => memory[StorageKeys.token] as String?;

  @override
  void setUserEmail(String email) => memory[StorageKeys.userEmail] = email;

  @override
  String? getUserEmail() => memory[StorageKeys.userEmail] as String?;

  @override
  void setUserData(UserModel user) => memory[StorageKeys.user] = user.toJson();

  @override
  UserModel? getUserData() {
    final data = memory[StorageKeys.user];
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  void clearSession() {
    memory.remove(StorageKeys.token);
    memory.remove(StorageKeys.userEmail);
    memory.remove(StorageKeys.user);
  }

  @override
  void saveRouteStack(List<String> routes) {
    memory[StorageKeys.routes] = List<String>.from(routes);
  }

  @override
  List<String> getRouteStack() {
    final stack = memory[StorageKeys.routes];
    return stack is List ? List<String>.from(stack) : [];
  }

  @override
  void clearRouteStack() {
    memory.remove(StorageKeys.routes);
  }

  @override
  void setThemeName(String name) => memory[StorageKeys.theme] = name;

  @override
  String? getThemeName() => memory[StorageKeys.theme] as String?;

  @override
  void setLocaleCode(String code) => memory[StorageKeys.locale] = code;

  @override
  String? getLocaleCode() => memory[StorageKeys.locale] as String?;

  @override
  void setSkipPremium(bool skip) => memory[StorageKeys.skipPremium] = skip;

  @override
  bool getSkipPremium() => memory[StorageKeys.skipPremium] == true;

  @override
  void saveAudioSession(Map<String, dynamic> session) {
    memory[StorageKeys.audioSession] = Map<String, dynamic>.from(session);
  }

  @override
  Map<String, dynamic>? getAudioSession() {
    final data = memory[StorageKeys.audioSession];
    if (data is! Map) return null;
    return Map<String, dynamic>.from(data);
  }

  @override
  void clearAudioSession() => memory.remove(StorageKeys.audioSession);

  @override
  void clearAll() => memory.clear();
}

/// Fake Socket Service allowing manual stream emission.
class FakeSocketService extends SocketService {
  final StreamController<SocketMessage> testStreamController =
      StreamController<SocketMessage>.broadcast();

  String? lastConnectedToken;
  bool wasDisconnected = false;

  @override
  Stream<SocketMessage> get stream => testStreamController.stream;

  @override
  void onInit() {}

  @override
  void onClose() {
    testStreamController.close();
  }

  @override
  void connect(String? token) {
    lastConnectedToken = token;
    isConnected.value = true;
  }

  @override
  void disconnect() {
    wasDisconnected = true;
    isConnected.value = false;
  }

  void emit(SocketMessage message) {
    testStreamController.add(message);
  }
}

/// Fake Analytics Service that records logged events in memory.
class FakeAnalyticsService extends AnalyticsService {
  final List<String> loggedEvents = [];
  final Map<String, String> userProperties = {};
  String? currentUserId;

  @override
  void onInit() {}

  @override
  void logEvent(String name, {Map<String, Object>? parameters}) {
    loggedEvents.add(name);
  }

  @override
  void setUserId(String userId) {
    currentUserId = userId;
  }

  @override
  void setUserProperty(String name, String value) {
    userProperties[name] = value;
  }

  @override
  void clearUserId() {
    currentUserId = null;
  }
}

/// Fake Push Notification Service without OneSignal dependencies.
class FakePushNotiService extends GetxService implements PushNotiService {
  bool permissionRequested = false;
  UserModel? syncedUser;
  bool userCleared = false;

  @override
  void onInit() {}

  @override
  Future<void> requestPermission() async {
    permissionRequested = true;
  }

  @override
  Future<void> syncUser(UserModel user) async {
    syncedUser = user;
  }

  @override
  Future<void> clearUser() async {
    userCleared = true;
  }
}

/// Fake AuthService with configurable mock responses.
class FakeAuthService extends GetxService implements AuthService {
  ApiResponse<PeekUserResponse>? peekUserResponse;
  ApiResponse<SignInResponse>? signInResponse;
  ApiResponse<UserModel>? signUpResponse;
  ApiResponse<void>? sendOtpResponse;
  ApiResponse<AuthResponse>? confirmOtpResponse;
  ApiResponse<GoogleResponse>? googleSignInResponse;
  ApiResponse<AuthResponse>? googleSignInCompleteResponse;
  ApiResponse<UserModel>? currentUserResponse;
  ApiResponse<void>? forgotPasswordResponse;
  ApiResponse<void>? signOutResponse;

  @override
  Future<ApiResponse<PeekUserResponse>> peekUser(String email) async {
    return peekUserResponse ??
        ApiResponse.success(
          message: 'OK',
          statusCode: 200,
          data: PeekUserResponse(userExists: true, confirmed: true),
        );
  }

  @override
  Future<ApiResponse<SignInResponse>> signIn(SignInRequest request) async {
    return signInResponse ??
        ApiResponse.success(
          message: 'OK',
          statusCode: 200,
          data: SignInResponse(
            user: UserModel(id: 'u1', email: 'test@example.com'),
            token: 'jwt_test_token',
          ),
        );
  }

  @override
  Future<ApiResponse<AuthResponse>> signInWithToken(
      SignInTokenRequest request) async {
    return ApiResponse.success(
      message: 'OK',
      statusCode: 200,
      data: AuthResponse(
        user: UserModel(id: 'u1', email: 'test@example.com'),
        token: 'token',
      ),
    );
  }

  @override
  Future<ApiResponse<GoogleResponse>> signInWithGoogle(
      SignInGoogleRequest request) async {
    return googleSignInResponse ??
        ApiResponse.success(
          message: 'OK',
          statusCode: 200,
          data: GoogleResponse(
            user: UserModel(id: 'u1', email: 'test@example.com'),
            token: 'token',
            passwordRequired: false,
          ),
        );
  }

  @override
  Future<ApiResponse<AuthResponse>> googleSignInComplete(
      GoogleSignInCompleteRequest request) async {
    return googleSignInCompleteResponse ??
        ApiResponse.success(
          message: 'OK',
          statusCode: 200,
          data: AuthResponse(
            user: UserModel(id: 'u1', email: 'test@example.com'),
            token: 'token',
          ),
        );
  }

  @override
  Future<ApiResponse<UserModel>> signUp(SignUpRequest request) async {
    return signUpResponse ??
        ApiResponse.success(
          message: 'Created',
          statusCode: 201,
          data: UserModel(id: 'u2', email: 'test@example.com'),
        );
  }

  @override
  Future<ApiResponse<void>> sendConfirmationOTPCode(
      SendConfirmationOtpRequest request) async {
    return sendOtpResponse ??
        ApiResponse.success(message: 'Code sent', statusCode: 200);
  }

  @override
  Future<ApiResponse<AuthResponse>> confirmOTPCode(
      ConfirmOtpRequest request) async {
    return confirmOtpResponse ??
        ApiResponse.success(
          message: 'Verified',
          statusCode: 200,
          data: AuthResponse(
            user: UserModel(id: 'u1', email: 'test@example.com'),
            token: 'valid_token',
          ),
        );
  }

  @override
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    return currentUserResponse ??
        ApiResponse.success(
          message: 'OK',
          statusCode: 200,
          data: UserModel(id: 'u1', email: 'test@example.com'),
        );
  }

  @override
  Future<ApiResponse<void>> forgotPassword(
      ForgotPasswordRequest request) async {
    return forgotPasswordResponse ??
        ApiResponse.success(message: 'Reset sent', statusCode: 200);
  }

  @override
  Future<ApiResponse<void>> signOut() async {
    return signOutResponse ??
        ApiResponse.success(message: 'Signed out', statusCode: 200);
  }
}

/// Fake Notification Service with in-memory notification management.
class FakeNotificationService extends NotificationService {
  PaginatedResponse<NotificationModel>? notificationsResponse;
  int unreadCount = 0;
  final List<String> markedReadIds = [];
  final List<String> deletedIds = [];
  bool markedAllRead = false;

  @override
  void onInit() {}

  @override
  Future<PaginatedResponse<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String filter = NotificationConstants.filterAll,
  }) async {
    return notificationsResponse ??
        const PaginatedResponse<NotificationModel>(
          records: [],
          message: 'OK',
          statusCode: 200,
          success: true,
        );
  }

  @override
  Future<int> getUnreadCount() async => unreadCount;

  @override
  Future<ApiResponse<NotificationModel>> markAsRead(String id) async {
    markedReadIds.add(id);
    return ApiResponse.success(
      message: 'Marked read',
      statusCode: 200,
      data: NotificationModel(
        id: id,
        title: 'Title',
        message: 'Message',
        read: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() async {
    markedAllRead = true;
    return ApiResponse.success(message: 'All read', statusCode: 200, data: {});
  }

  @override
  Future<ApiResponse<dynamic>> deleteNotification(String id) async {
    deletedIds.add(id);
    return ApiResponse.success(message: 'Deleted', statusCode: 200);
  }
}

/// Fake Feedback Service.
class FakeFeedbackService extends FeedbackService {
  ApiResponse<FeedbackModel>? submitResponse;
  Map<String, dynamic>? lastSubmittedData;

  @override
  void onInit() {}

  @override
  Future<ApiResponse<FeedbackModel>> submitFeedback(
      Map<String, dynamic> data) async {
    lastSubmittedData = data;
    return submitResponse ??
        ApiResponse.success(
          message: 'Feedback received',
          statusCode: 201,
          data: FeedbackModel(
            id: 'f1',
            content: data[FeedbackKeys.content]?.toString() ?? '',
            rating: data[FeedbackKeys.rating] as int? ?? 10,
            category: 'general',
            priority: 'medium',
            status: 'received',
            platform: 'android',
            createdAt: DateTime.now(),
          ),
        );
  }
}

/// Fake Payment Service.
class FakePaymentService extends PaymentService {
  PaginatedResponse<ProductModel>? productsResponse;
  PaginatedResponse<SubscriptionModel>? subscriptionsResponse;
  PaginatedResponse<TransactionModel>? transactionsResponse;
  PaginatedResponse<AccessModel>? accessesResponse;
  ApiResponse<Map<String, dynamic>>? checkoutResponse;
  ApiResponse<dynamic>? cancelResponse;
  ApiResponse<dynamic>? resumeResponse;

  @override
  void onInit() {}

  @override
  Future<PaginatedResponse<ProductModel>> getProducts({
    int? page,
    int? limit,
  }) async {
    return productsResponse ??
        const PaginatedResponse<ProductModel>(
          records: [],
          message: 'OK',
          statusCode: 200,
          success: true,
        );
  }

  @override
  Future<PaginatedResponse<SubscriptionModel>> getSubscriptions({
    int? page,
    int? limit,
  }) async {
    return subscriptionsResponse ??
        const PaginatedResponse<SubscriptionModel>(
          records: [],
          message: 'OK',
          statusCode: 200,
          success: true,
        );
  }

  @override
  Future<PaginatedResponse<TransactionModel>> getTransactions({
    int? page,
    int? limit,
  }) async {
    return transactionsResponse ??
        const PaginatedResponse<TransactionModel>(
          records: [],
          message: 'OK',
          statusCode: 200,
          success: true,
        );
  }

  @override
  Future<PaginatedResponse<AccessModel>> getActiveAccesses({
    int? page,
    int? limit,
  }) async {
    return accessesResponse ??
        const PaginatedResponse<AccessModel>(
          records: [],
          message: 'OK',
          statusCode: 200,
          success: true,
        );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createCheckout(
    CreateCheckoutRequest request,
  ) async {
    return checkoutResponse ??
        ApiResponse.success(
          message: 'Checkout created',
          statusCode: 200,
          data: {
            PaymentKeys.checkoutUrl: 'https://checkout.stripe.com/test_session',
          },
        );
  }

  @override
  Future<ApiResponse<dynamic>> cancelSubscription(String id) async {
    return cancelResponse ??
        ApiResponse.success(message: 'Subscription canceled', statusCode: 200);
  }

  @override
  Future<ApiResponse<dynamic>> resumeSubscription(String id) async {
    return resumeResponse ??
        ApiResponse.success(message: 'Subscription resumed', statusCode: 200);
  }
}

/// Fake AI Service.
class FakeAiService extends AiService {
  PaginatedResponse<AiRoomModel>? roomsResponse;
  PaginatedResponse<AiMessageModel>? historyResponse;
  ApiResponse<Map<String, dynamic>>? chatResponse;
  ApiResponse<AiRoomModel>? createRoomResponse;
  ApiResponse<dynamic>? deleteRoomResponse;
  ApiResponse<dynamic>? clearHistoryResponse;

  @override
  void onInit() {}

  @override
  Future<PaginatedResponse<AiRoomModel>> getRooms(
      {int? page, int? limit}) async {
    return roomsResponse ??
        const PaginatedResponse<AiRoomModel>(
          records: [],
          message: 'OK',
          statusCode: 200,
          success: true,
        );
  }

  @override
  Future<PaginatedResponse<AiMessageModel>> getHistory({String? roomId}) async {
    return historyResponse ??
        const PaginatedResponse<AiMessageModel>(
          records: [],
          message: 'OK',
          statusCode: 200,
          success: true,
        );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> chat(AiChatRequest request) async {
    return chatResponse ??
        ApiResponse.success(
          message: 'Chat response queued',
          statusCode: 200,
          data: {AiKeys.roomId: request.roomId ?? 'default_room'},
        );
  }

  @override
  Future<ApiResponse<AiRoomModel>> createRoom(CreateRoomRequest request) async {
    return createRoomResponse ??
        ApiResponse.success(
          message: 'Created',
          statusCode: 201,
          data: AiRoomModel(
            id: 'new_room_1',
            title: request.title,
            messageCount: 0,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
            processing: false,
          ),
        );
  }

  @override
  Future<ApiResponse<dynamic>> deleteRoom(String roomId) async {
    return deleteRoomResponse ??
        ApiResponse.success(message: 'Room deleted', statusCode: 200);
  }

  @override
  Future<ApiResponse<dynamic>> clearHistory({String? roomId}) async {
    return clearHistoryResponse ??
        ApiResponse.success(message: 'History cleared', statusCode: 200);
  }
}

/// Fake Speech Service avoiding native audio recorder / player channels.
class FakeSpeechService extends GetxService
    with WidgetsBindingObserver
    implements SpeechService {
  @override
  final RxBool isListening = false.obs;
  @override
  final RxDouble voiceLevel = 0.0.obs;
  @override
  final RxBool isPlaying = false.obs;
  @override
  final RxString liveText = ''.obs;

  @override
  bool get isListenSessionActive => isListening.value;

  @override
  bool get isBusy => isListenSessionActive || isPlaying.value;

  @override
  Future<void> Function()? beforeTtsPlayback;

  SocketMessage? lastSpeechEvent;
  ESpeechEventType? lastSpeechEventType;

  @override
  void onSpeechEvent(SocketMessage event, ESpeechEventType eventType) {
    lastSpeechEvent = event;
    lastSpeechEventType = eventType;
  }

  @override
  Future<ESpeechListenResult> startListening({String seed = ''}) async {
    isListening.value = true;
    return ESpeechListenResult.started;
  }

  @override
  Future<void> stopListening() async {
    isListening.value = false;
  }

  @override
  Future<void> stopPlayback() async {
    isPlaying.value = false;
  }

  @override
  Future<void> playUrl(String url) async {
    isPlaying.value = true;
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> textToSpeech(
    String messageId, {
    bool showLoading = false,
  }) async {
    return ApiResponse.success(
      message: 'TTS generation started',
      statusCode: 200,
      data: {SpeechKeys.messageId: messageId},
    );
  }

  @override
  Future<ApiResponse<String>> speechToTextFromFile(
    dynamic audioBytes, {
    String filename = 'audio.wav',
    bool showLoading = true,
  }) async {
    return ApiResponse.success(
      message: 'STT complete',
      statusCode: 200,
      data: 'mock transcription',
    );
  }

  @override
  Future<ApiResponse<String>> speechToTextFromUrl(
    String audioUrl, {
    bool showLoading = true,
  }) async {
    return ApiResponse.success(
      message: 'STT complete',
      statusCode: 200,
      data: 'mock transcription',
    );
  }
}

/// In-memory fake NetworkService for unit and widget tests.
class FakeNetworkService extends GetxService implements NetworkService {
  @override
  final bool autoInit = false;

  @override
  final RxBool isOnline = true.obs;

  @override
  final RxBool isBannerVisible = false.obs;

  @override
  final RxBool isRestored = false.obs;

  @override
  void onInit() {}

  @override
  void onClose() {}

  @override
  void initConnectivity([dynamic customConnectivity]) {}

  @override
  void handleInitialConnectivity(dynamic results) {}

  @override
  void handleConnectivityChange(dynamic results) {}

  @override
  void simulateOffline() {
    isOnline.value = false;
    isRestored.value = false;
    isBannerVisible.value = true;
  }

  @override
  void simulateOnline() {
    isOnline.value = true;
    isRestored.value = true;
    isBannerVisible.value = true;
  }

  @override
  void reset() {
    isOnline.value = true;
    isBannerVisible.value = false;
    isRestored.value = false;
  }
}

/// Fake Permission Service.
class FakePermissionService extends PermissionService {
  bool allowedResult = true;
  bool ensureCameraResult = true;
  bool requestMicResult = true;
  bool promptSettingsCalled = false;
  bool promptPhotosCalled = false;

  @override
  void onInit() {}

  @override
  Future<bool> isAllowed(Permission permission) async => allowedResult;

  @override
  Future<bool> request(Permission permission) async => allowedResult;

  @override
  Future<bool> ensure(
    Permission permission, {
    required String title,
    required String message,
  }) async => allowedResult;

  @override
  Future<void> promptSettings({
    required String title,
    required String message,
  }) async {
    promptSettingsCalled = true;
  }

  @override
  Future<bool> requestMicrophone() async => requestMicResult;

  @override
  Future<void> promptMicrophoneSettings() async {
    promptSettingsCalled = true;
  }

  @override
  Future<bool> ensureCamera() async => ensureCameraResult;

  @override
  Future<void> promptPhotosSettings() async {
    promptPhotosCalled = true;
  }

  @override
  Future<void> promptPhotosIfDenied() async {
    if (!allowedResult) {
      promptPhotosCalled = true;
    }
  }
}

/// Fake Version Service.
class FakeVersionService extends VersionService {
  ApiResponse<VersionModel>? currentResponse;
  String? lastRequestedVersion;
  bool throwOnGet = false;

  @override
  void onInit() {}

  @override
  Future<ApiResponse<VersionModel>> getCurrent(String version) async {
    lastRequestedVersion = version;
    if (throwOnGet) throw Exception('offline');
    return currentResponse ??
        ApiResponse.success(
          message: 'OK',
          statusCode: 200,
          data: VersionModel(
            id: 'av1',
            number: '1.0.0',
          ),
        );
  }

  ApiResponse<UserVersionModel>? userVersionResponse;
  String? lastReportedVersion;
  int? lastReportedVersionCode;
  bool throwOnReport = false;

  @override
  Future<ApiResponse<UserVersionModel>> reportUserVersion({
    required String version,
    required int versionCode,
  }) async {
    lastReportedVersion = version;
    lastReportedVersionCode = versionCode;
    if (throwOnReport) throw Exception('offline');
    return userVersionResponse ??
        ApiResponse.success(
          message: 'OK',
          statusCode: 200,
          data: UserVersionModel(
            id: 'install_1',
            number: version,
            buildNumber: versionCode,
            platform: 'android',
          ),
        );
  }
}

/// Fake Media Service.
class FakeMediaService extends MediaService {
  ApiResponse<AssetUploadResponse>? uploadResponse;
  String? lastUploadedFilePath;
  String? lastUploadedType;
  String? lastUploadedAssetableType;
  String? lastUploadedAssetableId;

  @override
  void onInit() {}

  @override
  Future<ApiResponse<AssetUploadResponse>> uploadImage({
    required String filePath,
    String? filename,
    String? type,
    String? assetableType,
    String? assetableId,
    int? durationSecs,
    String? folder,
  }) async {
    lastUploadedFilePath = filePath;
    lastUploadedType = type;
    lastUploadedAssetableType = assetableType;
    lastUploadedAssetableId = assetableId;

    return uploadResponse ??
        ApiResponse.success(
          message: 'Uploaded',
          statusCode: 200,
          data: AssetUploadResponse(
            asset: AssetModel(
              id: 'a1',
              name: 'avatar.png',
              url: 'https://example.com/avatar.png',
              type: type ?? 'avatar',
              source: AssetKeys.sourceUpload,
              sizeBytes: 1024,
              format: 'png',
              assetableType: assetableType ?? 'User',
              assetableId: assetableId ?? 'u1',
            ),
            storageDetails: StorageDetails(
              storageKey: 'avatars/a1.png',
              bytes: 1024,
              format: 'png',
            ),
          ),
        );
  }
}

/// Fake Profile Service.
class FakeProfileService extends ProfileService {
  ApiResponse<UserModel>? updateResponse;
  UpdateUserRequest? lastUpdateRequest;

  @override
  void onInit() {}

  @override
  Future<ApiResponse<UserModel>> updateCurrentUser(
    UpdateUserRequest request,
  ) async {
    lastUpdateRequest = request;
    return updateResponse ??
        ApiResponse.success(
          message: 'Profile updated',
          statusCode: 200,
          data: UserModel(
            id: 'u1',
            name: request.name,
            username: request.username,
            email: 'test@example.com',
            photo: 'https://example.com/new_avatar.png',
          ),
        );
  }
}

