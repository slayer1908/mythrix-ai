import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-platform secure key/value store. Falls back to SharedPreferences on
/// web (flutter_secure_storage's web implementation is encrypted, but we add
/// SharedPreferences for non-sensitive prefs).
class SecureStorageService {
  SecureStorageService._(this._secure, this._prefs);

  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  static SecureStorageService? _instance;

  static Future<SecureStorageService> init() async {
    if (_instance != null) return _instance!;
    const secure = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    final prefs = await SharedPreferences.getInstance();
    _instance = SecureStorageService._(secure, prefs);
    return _instance!;
  }

  static SecureStorageService get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('SecureStorageService not initialized. Call init() first.');
    }
    return i;
  }

  // --- Secure (tokens, secrets) ---
  Future<void> writeSecure(String key, String value) async {
    if (kIsWeb) {
      await _prefs.setString('sec.$key', value);
    } else {
      await _secure.write(key: key, value: value);
    }
  }

  Future<String?> readSecure(String key) async {
    if (kIsWeb) return _prefs.getString('sec.$key');
    return _secure.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    if (kIsWeb) {
      await _prefs.remove('sec.$key');
    } else {
      await _secure.delete(key: key);
    }
  }

  // --- Prefs (themeMode, locale, flags) ---
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  Future<void> remove(String key) => _prefs.remove(key);
}
