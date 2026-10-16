import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageHelper {
  static const _secureStorage = FlutterSecureStorage();

  static Future<String?> read({required String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('secure_$key');
    } else {
      try {
        return await _secureStorage.read(key: key);
      } catch (_) {
        return null;
      }
    }
  }

  static Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('secure_$key', value);
    } else {
      try {
        await _secureStorage.write(key: key, value: value);
      } catch (_) {}
    }
  }

  static Future<void> delete({required String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('secure_$key');
    } else {
      try {
        await _secureStorage.delete(key: key);
      } catch (_) {}
    }
  }
}
