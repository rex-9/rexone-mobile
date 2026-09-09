// lib/services/storage.service.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/constants.dart';
import '../models/user.model.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  // ===== LIFECYCLE =====
  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }

  // ============================================================
  // AUTH SESSION
  // ============================================================
  void setToken(String token) => _box.write(StorageKeys.token, token);
  String? getToken() => _box.read(StorageKeys.token);

  void setUserEmail(String email) => _box.write(StorageKeys.userEmail, email);
  String? getUserEmail() => _box.read(StorageKeys.userEmail);

  void setUserData(UserModel user) =>
      _box.write(StorageKeys.user, user.toJson());

  UserModel? getUserData() {
    final data = _box.read(StorageKeys.user);
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Clears session data only (keeps theme/locale settings).
  void clearSession() {
    _box.remove(StorageKeys.token);
    _box.remove(StorageKeys.userEmail);
    _box.remove(StorageKeys.user);
  }

  // ============================================================
  // ROUTE STACK
  // ============================================================
  void saveRouteStack(List<String> routes) {
    _box.write(StorageKeys.routes, routes);
  }

  List<String> getRouteStack() {
    final stack = _box.read(StorageKeys.routes);
    return stack is List ? List<String>.from(stack) : [];
  }

  void clearRouteStack() {
    _box.remove(StorageKeys.routes);
  }

  // ============================================================
  // SETTINGS (Theme & Locale)
  // ============================================================
  void setThemeName(String name) => _box.write(StorageKeys.theme, name);
  String? getThemeName() => _box.read(StorageKeys.theme);

  void setLocaleCode(String code) => _box.write(StorageKeys.locale, code);
  String? getLocaleCode() => _box.read(StorageKeys.locale);

  // ============================================================
  // APP VERSION FLAGS
  // ============================================================
  void setSkipPremium(bool skip) =>
      _box.write(StorageKeys.skipPremium, skip);

  bool getSkipPremium() => _box.read(StorageKeys.skipPremium) == true;

  // ============================================================
  // AUDIO PLAYBACK SESSION
  // ============================================================
  void saveAudioSession(Map<String, dynamic> session) {
    _box.write(StorageKeys.audioSession, session);
  }

  Map<String, dynamic>? getAudioSession() {
    final data = _box.read(StorageKeys.audioSession);
    if (data is! Map) return null;
    return Map<String, dynamic>.from(data);
  }

  void clearAudioSession() => _box.remove(StorageKeys.audioSession);

  // ============================================================
  // UTILITY
  // ============================================================
  void clearAll() => _box.erase();
}
