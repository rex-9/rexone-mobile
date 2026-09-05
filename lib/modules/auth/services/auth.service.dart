// lib/modules/auth/services/auth.service.dart
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';

import '../data/requests/requests.dart';
import '../data/responses/responses.dart';

class AuthService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  // 1. Check if user exists
  Future<ApiResponse<PeekUserResponse>> peekUser(String email) async {
    final response = await _api.get(
      ServerRoutes.peekUser,
      query: {AuthKeys.email: email},
    );
    return _api.parseResponse<PeekUserResponse>(
      response,
      (data) => PeekUserResponse.fromJson(data),
    );
  }

  // 2. Sign in with email/username and password
  Future<ApiResponse<SignInResponse>> signIn(SignInRequest request) async {
    final response = await _api.post(ServerRoutes.signIn, request.toJson());
    return _api.parseResponse<SignInResponse>(
      response,
      (data) => SignInResponse.fromJson(data),
    );
  }

  // 3. Sign in with token (from email confirmation)
  Future<ApiResponse<AuthResponse>> signInWithToken(
    SignInTokenRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.signInWithToken,
      request.toJson(),
    );
    return _api.parseResponse<AuthResponse>(
      response,
      (data) => AuthResponse.fromJson(data),
    );
  }

  // 4. Sign in with Google
  Future<ApiResponse<GoogleResponse>> signInWithGoogle(
    SignInGoogleRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.signInWithGoogle,
      request.toJson(),
    );
    return _api.parseResponse<GoogleResponse>(
      response,
      (data) => GoogleResponse.fromJson(data),
    );
  }

  // 4b. Complete Google sign in (new Google account sets a passcode)
  Future<ApiResponse<AuthResponse>> googleSignInComplete(
    GoogleSignInCompleteRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.signInGoogleComplete,
      request.toJson(),
    );
    return _api.parseResponse<AuthResponse>(
      response,
      (data) => AuthResponse.fromJson(data),
    );
  }

  // 5. Sign up (register new user)
  Future<ApiResponse<UserModel>> signUp(SignUpRequest request) async {
    final response = await _api.post(ServerRoutes.signUp, request.toJson());
    return _api.parseResponse<UserModel>(
      response,
      (data) => UserModel.fromJson(data),
    );
  }

  // 6. Send confirmation code (for email verification)
  Future<ApiResponse<void>> sendConfirmationOTPCode(
    SendConfirmationOtpRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.sendConfirmationCode,
      request.toJson(),
    );
    return _api.parseResponse<void>(response, (data) {});
  }

  // 7. Confirm email with code
  Future<ApiResponse<AuthResponse>> confirmOTPCode(
    ConfirmOtpRequest request,
  ) async {
    final response = await _api.post(ServerRoutes.confirmCode, request.toJson());
    return _api.parseResponse<AuthResponse>(
      response,
      (data) => AuthResponse.fromJson(data),
    );
  }

  // 8. Forgot password - send reset instructions
  Future<ApiResponse<void>> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.forgotPassword,
      request.toJson(),
    );
    return _api.parseResponse<void>(response, (data) {});
  }

  // 9. Get current user
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    final response = await _api.get(ServerRoutes.currentUser);
    return _api.parseResponse<UserModel>(
      response,
      (data) => UserModel.fromJson(data[AuthKeys.user]),
    );
  }

  // 10. Sign out
  Future<ApiResponse<void>> signOut() async {
    final response = await _api.delete(ServerRoutes.signOut);
    return _api.parseResponse<void>(response, (data) {});
  }
}
