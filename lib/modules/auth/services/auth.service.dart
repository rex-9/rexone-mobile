// lib/modules/auth/services/auth.service.dart
import 'package:get/get.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:rexone_mobile/routes/routes.dart';
import 'package:rexone_mobile/services/services.dart';

import '../data/requests/requests.dart';
import '../data/models/user_peek.model.dart';

class AuthService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  // 1. Check if user exists
  Future<ApiResponse<UserPeekModel>> peekUser(String email) async {
    final response = await _api.get(
      ServerRoutes.peekUser,
      query: {AuthKeys.email: email},
    );
    return _api.parseRecord<UserPeekModel>(
      response,
      UserPeekModel.fromJson,
    );
  }

  // 2. Sign in with email/username and password
  Future<ApiResponse<UserModel>> signIn(SignInRequest request) async {
    final response = await _api.post(ServerRoutes.signIn, request.toJson());
    return _api.parseRecord<UserModel>(
      response,
      UserModel.fromJson,
    );
  }

  // 3. Sign in with token (from email confirmation)
  Future<ApiResponse<UserModel>> signInWithToken(
    SignInTokenRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.signInWithToken,
      request.toJson(),
    );
    return _api.parseRecord<UserModel>(
      response,
      UserModel.fromJson,
    );
  }

  // 4. Sign in with Google
  Future<ApiResponse<UserModel>> signInWithGoogle(
    SignInGoogleRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.signInWithGoogle,
      request.toJson(),
    );
    return _api.parseRecord<UserModel>(
      response,
      UserModel.fromJson,
    );
  }

  // 4b. Complete Google sign in (new Google account sets a passcode)
  Future<ApiResponse<UserModel>> googleSignInComplete(
    GoogleSignInCompleteRequest request,
  ) async {
    final response = await _api.post(
      ServerRoutes.signInGoogleComplete,
      request.toJson(),
    );
    return _api.parseRecord<UserModel>(
      response,
      UserModel.fromJson,
    );
  }

  // 5. Sign up (register new user)
  Future<ApiResponse<UserModel>> signUp(SignUpRequest request) async {
    final response = await _api.post(ServerRoutes.signUp, request.toJson());
    return _api.parseRecord<UserModel>(
      response,
      UserModel.fromJson,
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
    return _api.parseRecord<void>(response);
  }

  // 7. Confirm email with code
  Future<ApiResponse<UserModel>> confirmOTPCode(
    ConfirmOtpRequest request,
  ) async {
    final response = await _api.post(ServerRoutes.confirmCode, request.toJson());
    return _api.parseRecord<UserModel>(
      response,
      UserModel.fromJson,
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
    return _api.parseRecord<void>(response);
  }

  // 9. Get current user
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    final response = await _api.get(ServerRoutes.currentUser);
    return _api.parseRecord<UserModel>(
      response,
      UserModel.fromJson,
    );
  }

  // 10. Sign out
  Future<ApiResponse<void>> signOut() async {
    final response = await _api.delete(ServerRoutes.signOut);
    return _api.parseRecord<void>(response);
  }
}
