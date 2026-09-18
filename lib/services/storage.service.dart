// lib/services/storage.service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/config.dart';
import '../constants/constants.dart';
import '../models/user.model.dart';

class StorageService extends GetxService {
  late final GetStorage _box;
  static const String _tokenPrefix = 'enc:v1:';
  static const String _saltSeed = 'rexone_mobile_auth_secure_seed_2026';

  // ===== LIFECYCLE =====
  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }

  // ============================================================
  // TOKEN CRYPTO HELPERS
  // ============================================================
  String _encryptToken(String value) {
    if (value.isEmpty) return value;
    final bytes = utf8.encode(value);
    final keyBytes = utf8.encode('${AppConfig.androidAppId}:$_saltSeed');
    final result = Uint8List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      result[i] = bytes[i] ^ keyBytes[i % keyBytes.length];
    }
    return '$_tokenPrefix${base64.encode(result)}';
  }

  String _decryptToken(String stored) {
    if (!stored.startsWith(_tokenPrefix)) {
      return stored; // Fallback for legacy unencrypted tokens
    }
    try {
      final raw = base64.decode(stored.substring(_tokenPrefix.length));
      final keyBytes = utf8.encode('${AppConfig.androidAppId}:$_saltSeed');
      final result = Uint8List(raw.length);
      for (int i = 0; i < raw.length; i++) {
        result[i] = raw[i] ^ keyBytes[i % keyBytes.length];
      }
      return utf8.decode(result);
    } catch (_) {
      return stored;
    }
  }

  // ============================================================
  // AUTH SESSION
  // ============================================================
  void setToken(String token) =>
      _box.write(StorageKeys.token, _encryptToken(token));

  String? getToken() {
    final raw = _box.read(StorageKeys.token);
    if (raw == null || raw is! String) return null;
    return _decryptToken(raw);
  }

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
  // OFFLINE MEDIA DOWNLOADS
  // ============================================================
  Map<String, dynamic>? getMediaDownloadsIndex() {
    final data = _box.read(StorageKeys.mediaDownloads);
    if (data is! Map) return null;
    return Map<String, dynamic>.from(
      data.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  void saveMediaDownloadsIndex(Map<String, dynamic> index) {
    _box.write(StorageKeys.mediaDownloads, index);
  }

  void clearMediaDownloadsIndex() => _box.remove(StorageKeys.mediaDownloads);

  // ============================================================
  // UTILITY
  // ============================================================
  void clearAll() => _box.erase();
}
