// lib/modules/auth/controllers/auth.controller.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rexone_mobile/config/config.dart';
import 'package:rexone_mobile/constants/constants.dart';
import 'package:rexone_mobile/design/components/components.dart';
import 'package:rexone_mobile/helpers/helpers.dart';
import 'package:rexone_mobile/models/models.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../routes/app.routes.dart';
import '../../../services/services.dart';
import '../auth.dart';

class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();
  final AnalyticsService _analytics = Get.find<AnalyticsService>();
  final PushNotiService _pushNotiService = Get.find<PushNotiService>();

  static const int maxAttempts = 3;
  // Attempts UI default — server is the source of truth, this is a display fallback.

  // Observables
  var isLoggedIn = false.obs;
  var authToken = ''.obs;
  var currentUser = Rxn<UserModel>();

  // Form data
  var email = ''.obs;
  var emailError = RxnString();
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var fullName = ''.obs;
  var username = ''.obs;

  // Password attempt limiting
  var attemptsLeft = maxAttempts.obs;
  var hasFailureHistory = false.obs;
  var cooldownSecondsLeft = 0.obs;

  Timer? _cooldownTimer;

  // Resend countdowns
  var resendSecondsLeft = 0.obs;
  Timer? _resendTimer;

  // Google sign up challenge
  var googleChallengeToken = ''.obs;
  bool get isGooglePasswordSetup => googleChallengeToken.value.isNotEmpty;

  // Pin controllers
  final signinPin = PinInputController();
  final signupPin = PinInputController();
  final signupConfirmPin = PinInputController();
  final confirmPin = PinInputController();

  bool _googleInitialized = false;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    _resendTimer?.cancel();
    super.onClose();
  }

  // ---------------------------------------------------------------------
  // Auth Status
  // ---------------------------------------------------------------------

  Future<void> checkAuthStatus() async {
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      authToken.value = token;
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().connect(token);
      }
      final storedUser = _storage.getUserData();
      if (storedUser != null) {
        currentUser.value = storedUser;
        isLoggedIn.value = true;
      }
      // Validate session with backend
      await getCurrentUser();
    } else {
      isLoggedIn.value = false;
    }
  }

  // ---------------------------------------------------------------------
  // Passcode Retry State
  // ---------------------------------------------------------------------

  void loadRetryState() {
    attemptsLeft.value = maxAttempts;
    hasFailureHistory.value = false;
    cooldownSecondsLeft.value = 0;
    _cooldownTimer?.cancel();
  }

  void _resetRetryState() {
    attemptsLeft.value = maxAttempts;
    hasFailureHistory.value = false;
    cooldownSecondsLeft.value = 0;
    _cooldownTimer?.cancel();
  }

  void _applySignInFailure({
    required int remainingAttempts,
    required int cooldownRemaining,
  }) {
    hasFailureHistory.value = true;

    // Use server values directly
    attemptsLeft.value = remainingAttempts;

    if (cooldownRemaining > 0) {
      attemptsLeft.value = 0;
      final until =
          DateTime.now().millisecondsSinceEpoch + cooldownRemaining * 1000;
      _startCooldownUntil(until);
    }
  }

  void _startCooldownUntil(int untilMs) {
    _cooldownTimer?.cancel();
    void tick() {
      final left = ((untilMs - DateTime.now().millisecondsSinceEpoch) / 1000)
          .ceil();
      if (left <= 0) {
        cooldownSecondsLeft.value = 0;
        _cooldownTimer?.cancel();
        attemptsLeft.value = maxAttempts;
        password.value = '';
        signinPin.clear();
      } else {
        cooldownSecondsLeft.value = left;
      }
    }

    tick();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _startResendCountdown(int seconds) {
    _resendTimer?.cancel();
    resendSecondsLeft.value = seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (resendSecondsLeft.value <= 1) {
        resendSecondsLeft.value = 0;
        _resendTimer?.cancel();
      } else {
        resendSecondsLeft.value -= 1;
      }
    });
  }

  // ---------------------------------------------------------------------
  // Auth Flow
  // ---------------------------------------------------------------------

  bool validateEmail() {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email.value.trim())) {
      emailError.value = AppLocales.auth.initial.invalidEmail.tr;
      return false;
    }
    emailError.value = null;
    return true;
  }

  // Handle continue from auth page
  Future<void> handleContinue() async {
    if (!validateEmail()) return;

    final status = await peekUser(email.value);

    switch (status) {
      case EPeekedUserStatus.error:
        AppSnackbar.error(AppLocales.auth.initial.connectionFailed.tr);
        break;

      case EPeekedUserStatus.exists:
        password.value = '';
        signinPin.clear();
        loadRetryState();
        AppRoutes.toSignInPassword();
        break;

      case EPeekedUserStatus.existsUnconfirmed:
        password.value = '';
        signupPin.clear();
        signupConfirmPin.clear();
        confirmPin.clear();
        await sendConfirmationOTPCode();
        AppRoutes.toConfirmEmail(email: email.value);
        break;

      case EPeekedUserStatus.notExists:
        password.value = '';
        confirmPassword.value = '';
        signupPin.clear();
        signupConfirmPin.clear();
        AppRoutes.toSignUpPasswordCreate();
        break;
    }
  }

  // Handle confirm password
  Future<void> handleConfirmPassword() async {
    if (confirmPassword.value.length != 6) {
      signupConfirmPin.triggerError();
      AppSnackbar.error(AppLocales.auth.signInPasscode.passcode6Digits.tr);
      return;
    }

    if (password.value != confirmPassword.value) {
      signupConfirmPin.triggerError();
      AppSnackbar.error(AppLocales.auth.signUpPasscodeConfirm.passcodesMismatch.tr);
      return;
    }

    if (isGooglePasswordSetup) {
      await completeGoogleSignIn();
      return;
    }

    AppRoutes.toSignUpInfo(
      email: email.value,
      password: password.value,
      confirmPassword: confirmPassword.value,
    );
  }

  // Step 1: Check if user exists
  Future<EPeekedUserStatus> peekUser(String emailAddress) async {
    try {
      final response = await _auth.peekUser(emailAddress);
      if (!response.success || response.data == null) {
        return EPeekedUserStatus.error;
      }
      final data = response.data!;
      if (!data.userExists) return EPeekedUserStatus.notExists;
      return data.confirmed
          ? EPeekedUserStatus.exists
          : EPeekedUserStatus.existsUnconfirmed;
    } catch (_) {
      return EPeekedUserStatus.error;
    }
  }

  void _storeSession(AuthResponse response) {
    authToken.value = response.token;
    _storage.setToken(response.token);
    _storage.setUserEmail(response.user.email);
    currentUser.value = response.user;
    _storage.setUserData(response.user);
    isLoggedIn.value = true;

    if (Get.isRegistered<SocketService>()) {
      Get.find<SocketService>().connect(response.token);
    }
    if (Get.isRegistered<PushNotiService>()) {
      // Sync user data with OneSignal
      _pushNotiService.syncUser(response.user);
    }
    if (Get.isRegistered<AnalyticsService>()) {
      // Set user ID and properties
      _analytics.setUserId(response.user.id);
      _analytics.setUserProperty('email', response.user.email);
      _analytics.setUserProperty(
        'provider',
        response.user.provider ?? EAuthProvider.email.name,
      );
      _analytics.logSignIn(method: response.user.provider);
    }
  }

  // Step 2a: Sign in with email and password (existing user)
  Future<void> signIn() async {
    if (cooldownSecondsLeft.value > 0) return;
    if (password.value.length != 6) {
      signinPin.triggerError();
      AppSnackbar.error(AppLocales.auth.signInPasscode.passcode6Digits.tr);
      return;
    }

    try {
      final response = await _auth.signIn(
        SignInRequest(signinKey: email.value, password: password.value),
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        // Check if user is confirmed (has user + token)
        if (data.user != null && data.token != null) {
          _resetRetryState();
          _analytics.logSignIn(method: EAuthProvider.email.name);
          // Sync noti user & Request permission after Email signin
          await _handleSuccessfulAuth(
            AuthResponse(user: data.user!, token: data.token!),
          );
        } else if (data.otpSent) {
          // Unconfirmed user - OTP sent
          AppSnackbar.success(response.message);
          _startResendCountdown(30);
          AppRoutes.toConfirmEmail(email: email.value);
        } else {
          AppSnackbar.error(response.message);
        }
      } else {
        signinPin.triggerError();

        final data = response.data;
        final remainingAttempts = data?.remainingAttempts ?? 0;
        final cooldownRemaining = data?.cooldownRemaining ?? 0;

        _applySignInFailure(
          remainingAttempts: remainingAttempts,
          cooldownRemaining: cooldownRemaining,
        );

        AppSnackbar.error(response.error ?? response.message);
      }
    } catch (e, stk) {
      AppSnackbar.error(AppLocales.auth.signInPasscode.signInFailed.tr, e: e, stk: stk);
    }
  }

  // Step 2b: Send confirmation code (for new user registration)
  Future<void> sendConfirmationOTPCode() async {
    try {
      final response = await _auth.sendConfirmationOTPCode(
        SendConfirmationOtpRequest(signinKey: email.value),
      );
      if (response.success) {
        _startResendCountdown(30);
        if (Get.currentRoute != AppRoutes.confirmEmail) {
          AppRoutes.toConfirmEmail(email: email.value);
        }
      } else {
        AppSnackbar.error(response.error ?? response.message);
      }
    } catch (e, stk) {
      AppSnackbar.error(AppLocales.auth.confirmEmail.sendCodeFailed.tr, e: e, stk: stk);
    }
  }

  // Step 3: Confirm code (for new user)
  Future<void> confirmOTPCode(String code) async {
    try {
      final response = await _auth.confirmOTPCode(
        ConfirmOtpRequest(signinKey: email.value, confirmationCode: code),
      );
      if (response.success && response.data != null) {
        _analytics.logEmailVerified();
        _analytics.logOnboardingCompleted();
        // Sync noti user & Request permission after Email signup
        await _handleSuccessfulAuth(response.data!);
      } else {
        confirmPin.triggerError();
        AppSnackbar.error(response.error ?? response.message);
      }
    } catch (e, stk) {
      AppSnackbar.error(AppLocales.auth.confirmEmail.verificationFailed.tr, e: e, stk: stk);
    }
  }

  // Register new user with full details
  Future<void> signUp() async {
    final nameError = FullnameValidator.error(fullName.value);
    if (nameError != null) {
      AppSnackbar.error(nameError);
      return;
    }
    final usernameError = UsernameValidator.error(username.value);
    if (usernameError != null) {
      AppSnackbar.error(usernameError);
      return;
    }

    try {
      final response = await _auth.signUp(
        SignUpRequest(
          username: username.value,
          name: fullName.value,
          email: email.value,
          password: password.value,
          passwordConfirmation: confirmPassword.value,
        ),
      );

      if (response.success) {
        _startResendCountdown(30);
        _analytics.logSignUp(method: EAuthProvider.email.name);
        _analytics.logOnboardingStarted();
        AppRoutes.toConfirmEmail(email: email.value);
      } else {
        AppSnackbar.error(response.error ?? response.message);
      }
    } catch (e, stk) {
      AppSnackbar.error(AppLocales.auth.signUpInfo.registrationFailed.tr, e: e, stk: stk);
    }
  }

  // Google Sign In (existing account signs straight in; a new account
  // gets a challenge token and must set a password to finish sign up).
  Future<void> signInWithGoogle() async {
    try {
      final signIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await signIn.initialize(serverClientId: AppConfig.googleServerClientId);
        _googleInitialized = true;
      }

      final user = await signIn.authenticate();
      const scopes = <String>['email'];
      final auth = await user.authorizationClient.authorizeScopes(scopes);
      final accessToken = auth.accessToken;

      final response = await _auth.signInWithGoogle(
        SignInGoogleRequest(idToken: accessToken),
      );

      if (response.success && response.data != null) {
        // New Google account: set a password to complete account creation.
        final data = response.data!;
        if (data.passwordRequired && data.challengeToken != null) {
          googleChallengeToken.value = data.challengeToken!;
          email.value = user.email;
          password.value = '';
          confirmPassword.value = '';
          signupPin.clear();
          signupConfirmPin.clear();
          AppRoutes.toSignUpPasswordCreate();
        } else if (data.user != null && data.token != null) {
          email.value = user.email;
          _analytics.logSignIn(method: EAuthProvider.google.name);
          _analytics.logOnboardingStarted();
          // Sync noti user & Request permission after Google signin
          await _handleSuccessfulAuth(
            AuthResponse(user: data.user!, token: data.token!),
          );
        }
      } else {
        AppSnackbar.error(response.error ?? response.message);
      }
    } catch (e, stk) {
      AppSnackbar.error(
        AppLocales.auth.initial.googleFailure.tr,
        e: e,
        stk: stk,
      );
    }
  }

  // Complete Google sign up with the newly created password.
  Future<void> completeGoogleSignIn() async {
    if (password.value.length != 6) {
      signupPin.triggerError();
      AppSnackbar.error(AppLocales.auth.signInPasscode.passcode6Digits.tr);
      return;
    }
    if (password.value != confirmPassword.value) {
      signupConfirmPin.triggerError();
      AppSnackbar.error(AppLocales.auth.signUpPasscodeConfirm.passcodesMismatch.tr);
      return;
    }

    try {
      final response = await _auth.googleSignInComplete(
        GoogleSignInCompleteRequest(
          password: password.value,
          challengeToken: googleChallengeToken.value,
        ),
      );

      if (response.success && response.data != null) {
        googleChallengeToken.value = '';
        _analytics.logSignUp(method: EAuthProvider.google.name);
        _analytics.logOnboardingCompleted();
        await _handleSuccessfulAuth(response.data!);
      } else if (response.statusCode == 429) {
        AppSnackbar.error(AppLocales.auth.initial.googleTooManyAttempts.tr);
      } else {
        AppSnackbar.error(response.error ?? response.message);
        if (response.statusCode == 401) {
          googleChallengeToken.value = '';
          AppRoutes.toAuth();
        }
      }
    } catch (e, stk) {
      AppSnackbar.error(
        AppLocales.auth.initial.googleFailure.tr,
        e: e,
        stk: stk,
      );
    }
  }

  // Get current user
  Future<void> getCurrentUser() async {
    try {
      final response = await _auth.getCurrentUser();
      if (response.success && response.data != null) {
        _cacheUser(response.data!);
      }
    } catch (_) {}
  }

  void _cacheUser(UserModel user) {
    currentUser.value = user;
    _storage.setUserData(user);
  }

  // Forgot password: email a reset link (60s resend countdown).
  Future<void> forgotPassword() async {
    if (!validateEmail()) return;
    try {
      final response = await _auth.forgotPassword(
        ForgotPasswordRequest(email: email.value),
      );
      if (response.success) {
        _startResendCountdown(60);
        AppSnackbar.success(response.message);
      } else {
        AppSnackbar.error(response.error ?? response.message);
      }
    } catch (e, stk) {
      AppSnackbar.error(AppLocales.auth.forgotPasscode.resetFailed.tr, e: e, stk: stk);
    }
  }

  /// TODO: Called by the API layer when the active session was replaced by a
  /// newer sign in on this platform (or session validation fails).
  void handleSessionExpired({bool replaced = false}) {
    if (!isLoggedIn.value) return;
    _clearLocalSession();
    AppRoutes.toAuth();
    if (replaced) {
      AppSnackbar.error(AppLocales.auth.shared.sessionReplaced.tr);
    }
  }

  void _clearLocalSession() {
    if (Get.isRegistered<SocketService>()) {
      Get.find<SocketService>().disconnect();
    }
    _storage.clearSession();
    authToken.value = '';
    isLoggedIn.value = false;
    currentUser.value = null;
    email.value = '';
    emailError.value = null;
    password.value = '';
    confirmPassword.value = '';
    fullName.value = '';
    username.value = '';
    googleChallengeToken.value = '';
    signinPin.clear();
    signupPin.clear();
    signupConfirmPin.clear();
    confirmPin.clear();
    _cooldownTimer?.cancel();
    _resendTimer?.cancel();
    cooldownSecondsLeft.value = 0;
    resendSecondsLeft.value = 0;
    attemptsLeft.value = maxAttempts;
    hasFailureHistory.value = false;
    // Clear OneSignal user data
    if (Get.isRegistered<PushNotiService>()) {
      _pushNotiService.clearUser();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}

    if (currentUser.value?.provider == EAuthProvider.google.name) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }

    _clearLocalSession();
    _storage.clearRouteStack();
    if (Get.isRegistered<AnalyticsService>()) {
      _analytics.clearUserId();
      _analytics.logSignOut();
    }
    AppRoutes.toAuth();
  }

  // handle push noti and redirect after successful auth
  Future<void> _handleSuccessfulAuth(AuthResponse response) async {
    // 1. Store session + sync user
    _storeSession(response);

    // 2. Request push permission (non-blocking)
    unawaited(_pushNotiService.requestPermission());

    // 3. Navigate to home
    AppRoutes.toHome();
  }
}
