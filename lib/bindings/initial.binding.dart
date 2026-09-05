// lib/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../modules/ai/ai.dart';
import '../modules/auth/auth.dart';
import '../modules/payment/payment.dart';
import '../modules/profile/profile.dart';
import '../modules/setting/setting.dart';
import '../modules/notification/notification.dart';
import '../services/services.dart';
import '../controllers/controllers.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ===== Services =====

    // Storage (no dependencies)
    Get.put(StorageService(), permanent: true);

    // Network Connectivity Service
    Get.put(NetworkService(), permanent: true);

    // Analytics Service (Firebase Analytics)
    Get.put(AnalyticsService(), permanent: true);

    // Push Notification Service (OneSignal)
    Get.put(PushNotiService(), permanent: true);

    // API Service (interface + implementation)
    Get.put<ApiService>(ApiService(), permanent: true);

    // Telemetry & Error Logging (depends on ApiService)
    Get.put(LogService(), permanent: true);

    // Media upload (depends on ApiService)
    Get.put(MediaService(), permanent: true);

    // WebSocket / Action Cable Socket Service
    Get.put(SocketService(), permanent: true);

    // Device permissions (mic, camera, photos) + Settings prompt
    Get.put(PermissionService(), permanent: true);

    // Shared live STT + TTS (depends on ApiService + SocketService)
    Get.put(SpeechService(), permanent: true);

    // Payment Service (depends on ApiService)
    Get.put(PaymentService(), permanent: true);

    // AI Service (depends on ApiService)
    Get.put(AiService(), permanent: true);

    // Auth Service (depends on ApiService)
    Get.put(AuthService(), permanent: true);

    // Profile Service (depends on ApiService)
    Get.put(ProfileService(), permanent: true);
    // Notification Service (depends on ApiService)
    Get.put(NotificationService(), permanent: true);

    // ===== Controllers =====

    // Settings: theme + locale (depends on StorageService)
    Get.put(SettingController(), permanent: true);

    // Auth Controller (depends on AuthService and StorageService)
    Get.put(AuthController(), permanent: true);

    // Notification Controller (depends on NotificationService)
    Get.put(NotificationController(), permanent: true);

    // Global socket event router (snackbars + controller dispatch)
    Get.put(SocketController(), permanent: true);
  }
}
