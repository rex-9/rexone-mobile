// lib/locales/app_locales.dart

/// Centralized, namespaced translation keys matching rexone-web AppLocales.
/// Use with `'key'.tr` or `'key'.trParams({'email': ...})`.
class AppLocales {
  const AppLocales._();

  static const auth = _AuthLocales();
  static const common = _CommonLocales();
  static const setting = _SettingLocales();
  static const feedback = _FeedbackLocales();
  static const ai = _AiLocales();
  static const payment = _PaymentLocales();
  static const user = _UserLocales();
  static const notification = _NotificationLocales();
}

class _AuthLocales {
  const _AuthLocales();

  final shared = const _AuthSharedLocales();
  final initial = const _AuthInitialLocales();
  final signInPasscode = const _AuthSignInPasscodeLocales();
  final signUpPasscodeCreate = const _AuthSignUpPasscodeCreateLocales();
  final signUpPasscodeConfirm = const _AuthSignUpPasscodeConfirmLocales();
  final signUpInfo = const _AuthSignUpInfoLocales();
  final confirmEmail = const _AuthConfirmEmailLocales();
  final forgotPasscode = const _AuthForgotPasscodeLocales();
}

class _AuthSharedLocales {
  const _AuthSharedLocales();

  final emailLabel = 'auth.shared.email_label';
  final emailHint = 'auth.shared.email_placeholder';
  final continueButton = 'auth.shared.continue';
  final useDifferentEmail = 'auth.shared.use_different_email';
  final passcodeLength = 'auth.shared.validation.passcode_length';
  final sessionExpired = 'auth.shared.session_expired';
  final sessionReplaced = 'auth.shared.session_replaced';
}

class _AuthInitialLocales {
  const _AuthInitialLocales();

  final title = 'auth.initial.title';
  final subtitle = 'auth.initial.description';
  final continueWithGoogle = 'auth.initial.continue_with_google';
  final or = 'auth.initial.or';
  final emailHelper = 'auth.initial.email_helper';
  final invalidEmail = 'auth.initial.validation.invalid_email';
  final checking = 'auth.initial.actions.checking';
  final googleFailure = 'auth.initial.errors.google_signin_failed';
  final googleTooManyAttempts = 'auth.initial.errors.google_too_many_attempts';
  final connectionFailed = 'auth.initial.errors.connection_failed';
  final goBack = 'auth.initial.actions.go_back';
}

class _AuthSignInPasscodeLocales {
  const _AuthSignInPasscodeLocales();

  final title = 'auth.signin_passcode.title';
  final heading = 'auth.signin_passcode.prompt';
  final subtitle = 'auth.signin_passcode.description';
  final passcodeLabel = 'auth.signin_passcode.field.label';
  final signingIn = 'auth.signin_passcode.actions.signing_in';
  final forgotPasscodeLink = 'auth.signin_passcode.links.forgot_passcode';
  final passcode6Digits = 'auth.signin_passcode.validation.passcode_6_digits';
  final attemptsRemaining = 'auth.signin_passcode.helper.attempts_remaining';
  final cooldownMessage = 'auth.signin_passcode.errors.too_many_attempts';
  final tryAgainIn = 'auth.signin_passcode.actions.try_again_in';
  final signInFailed = 'auth.signin_passcode.errors.signin_failed';
}

class _AuthSignUpPasscodeCreateLocales {
  const _AuthSignUpPasscodeCreateLocales();

  final title = 'auth.signup_passcode_create.title.signup';
  final heading = 'auth.signup_passcode_create.prompt.signup';
  final subtitle = 'auth.signup_passcode_create.description.signup';
  final googleHeading = 'auth.signup_passcode_create.google.heading';
  final googleSubtitle = 'auth.signup_passcode_create.google.subtitle';
  final instruction = 'auth.signup_passcode_create.instruction';
}

class _AuthSignUpPasscodeConfirmLocales {
  const _AuthSignUpPasscodeConfirmLocales();

  final title = 'auth.signup_passcode_confirm.title.signup';
  final heading = 'auth.signup_passcode_confirm.prompt.signup';
  final subtitle = 'auth.signup_passcode_confirm.description.signup';
  final confirm = 'auth.signup_passcode_confirm.actions.confirm';
  final changePasscode = 'auth.signup_passcode_confirm.actions.change_passcode';
  final passcodesMismatch =
      'auth.signup_passcode_confirm.validation.passcodes_mismatch';
  final sendingCode = 'auth.signup_passcode_confirm.actions.sending_code';
}

class _AuthSignUpInfoLocales {
  const _AuthSignUpInfoLocales();

  final title = 'auth.signup_info.title';
  final heading = 'auth.signup_info.prompt';
  final fullNameLabel = 'auth.signup_info.full_name.label';
  final fullNameHint = 'auth.signup_info.full_name.placeholder';
  final usernameLabel = 'auth.signup_info.username.label';
  final usernameHint = 'auth.signup_info.username.placeholder';
  final createAccountButton = 'auth.signup_info.actions.create_account';
  final creatingAccount = 'auth.signup_info.actions.creating_account';
  final enterFullName = 'auth.signup_info.validation.full_name_required';
  final usernameMinLength = 'auth.signup_info.validation.username_length';
  final usernameCharset = 'auth.signup_info.validation.username_format';
  final registrationFailed = 'auth.signup_info.errors.registration_failed';
}

class _AuthConfirmEmailLocales {
  const _AuthConfirmEmailLocales();

  final title = 'auth.confirm_email.title';
  final heading = 'auth.confirm_email.prompt';
  final subtitle = 'auth.confirm_email.sent_to';
  final confirmCodeButton = 'auth.confirm_email.actions.verify_email';
  final verifying = 'auth.confirm_email.actions.verifying';
  final resendCode = 'auth.confirm_email.actions.resend';
  final resendCodeIn = 'auth.confirm_email.actions.resend_in';
  final enter6DigitCode = 'auth.confirm_email.validation.enter_6_digit_code';
  final verificationFailed = 'auth.confirm_email.errors.verification_failed';
  final sendCodeFailed = 'auth.confirm_email.errors.send_code_failed';
}

class _AuthForgotPasscodeLocales {
  const _AuthForgotPasscodeLocales();

  final title = 'auth.forgot_passcode.title';
  final subtitle = 'auth.forgot_passcode.description';
  final sendResetLink = 'auth.forgot_passcode.actions.send_reset_link';
  final sending = 'auth.forgot_passcode.actions.sending';
  final backToSignIn = 'auth.forgot_passcode.links.back_to_signin';
  final resetFailed = 'auth.forgot_passcode.errors.reset_failed';
}

class _CommonLocales {
  const _CommonLocales();

  final home = 'common.home';
  final welcomeHome = 'common.welcome_home';
  final loading = 'common.loading';
  final signOut = 'common.sign_out';
  final goBack = 'common.go_back';
  final submit = 'common.submit';
  final save = 'common.save';
  final cancel = 'common.cancel';
  final delete = 'common.delete';
  final confirm = 'common.confirm';
  final error = 'common.error';
  final success = 'common.success';
  final warning = 'common.warning';
  final info = 'common.info';
  final exit = 'common.exit';
  final exitTitle = 'common.exit_title';
  final exitConfirm = 'common.exit_confirm';
  final connectionLost = 'common.connection_lost';
  final connectionRestored = 'common.connection_restored';
  final noInternet = 'common.no_internet';
}

class _SettingLocales {
  const _SettingLocales();

  final settings = 'settings.title';
  final theme = 'settings.theme';
  final language = 'settings.language';
  final account = 'settings.account';
  final logoutConfirmation = 'settings.logout_confirmation';
  final appInfo = 'settings.app_info';
  final confirmDelete = 'settings.confirm_delete';
  final confirmClear = 'settings.confirm_clear';
  final clearHistoryTitle = 'settings.clear_history_title';
  final clearHistoryConfirmMsg = 'settings.clear_history_confirm_msg';
  final deleteRoomTitle = 'settings.delete_room_title';
  final deleteRoomConfirmMsg = 'settings.delete_room_confirm_msg';
  final cancelSubTitle = 'settings.cancel_sub_title';
  final cancelSubConfirmMsg = 'settings.cancel_sub_confirm_msg';
}

class _FeedbackLocales {
  const _FeedbackLocales();

  final title = 'feedback.title';
  final description = 'feedback.description';
  final rateExperience = 'feedback.rate_experience';
  final tellUsMore = 'feedback.tell_us_more';
  final placeholder = 'feedback.placeholder';
  final submit = 'feedback.submit';
  final submitting = 'feedback.submitting';
  final successMessage = 'feedback.success_message';
}

class _AiLocales {
  const _AiLocales();

  final title = 'ai.title';
  final rooms = 'ai.rooms';
  final newChat = 'ai.new_chat';
  final defaultGreeting = 'ai.default_greeting';
  final messagesCount = 'ai.messages_count';
  final listen = 'ai.listen';
  final thinking = 'ai.thinking';
  final cancelListening = 'ai.cancel_listening';
  final typeMessage = 'ai.type_message';
  final send = 'ai.send';
  final processing = 'ai.processing';
  final clearHistory = 'ai.clear_history';

  // Voice / microphone
  final micPermissionTitle = 'ai.mic_permission_title';
  final micPermissionMessage = 'ai.mic_permission_message';
  final openSettings = 'ai.open_settings';

  // AI chat
  String get aiSendMessageFailed => 'ai_send_message_failed';
  final aiResponseFailed = 'ai.ai_response_failed';
  final aiHistoryCleared = 'ai.ai_history_cleared';
  final aiClearHistoryFailed = 'ai.ai_clear_history_failed';
  final aiStartRecordingFailed = 'ai.ai_start_recording_failed';
  final aiTranscriptionFailed = 'ai.ai_transcription_failed';
  final aiTtsFailed = 'ai.ai_tts_failed';
  final aiTtsEmpty = 'ai.ai_tts_empty';
}

class _PaymentLocales {
  const _PaymentLocales();

  final title = 'payment.title';
  final subscriptions = 'payment.subscriptions';
  final transactions = 'payment.transactions';
  final upgradePlan = 'payment.upgrade_plan';
  final active = 'payment.active';
  final canceled = 'payment.canceled';
  final cancelSubscription = 'payment.cancel_subscription';
  final resumeSubscription = 'payment.resume_subscription';
  final subscribeNow = 'payment.subscribe_now';
  final successTitle = 'payment.success_title';
  final successDesc = 'payment.success_desc';
  final cancelTitle = 'payment.cancel_title';
  final cancelDesc = 'payment.cancel_desc';
}

class _UserLocales {
  const _UserLocales();

  final profile = 'user.profile';
  final changeAvatar = 'user.change_avatar';
  final avatarHint = 'user.avatar_hint';
  final selectImage = 'user.select_image';
  final uploadAvatar = 'user.upload_avatar';
  final takePhoto = 'user.take_photo';
  final chooseFromGallery = 'user.choose_from_gallery';
  final cameraPermissionTitle = 'user.camera_permission_title';
  final cameraPermissionMessage = 'user.camera_permission_message';
  final photosPermissionTitle = 'user.photos_permission_title';
  final photosPermissionMessage = 'user.photos_permission_message';
  final uploadAvatarFailed = 'user.upload_avatar_failed';
  final updateSuccess = 'user.update_success';
  final updateFailed = 'user.update_failed';
  final accountInfo = 'user.account_info';
  final roles = 'user.roles';
  final permissions = 'user.permissions';
}

class _NotificationLocales {
  const _NotificationLocales();

  final title = 'notification.title';
  final all = 'notification.all';
  final unread = 'notification.unread';
  final read = 'notification.read';
  final markAllAsRead = 'notification.mark_all_as_read';
  final markAsRead = 'notification.mark_as_read';
  final empty = 'notification.empty';
  final loadMore = 'notification.load_more';
  final deleted = 'notification.deleted';
  final failedToLoad = 'notification.failed_to_load';
}
