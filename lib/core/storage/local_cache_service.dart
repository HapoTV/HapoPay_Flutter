import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple cache service that persists stringified JSON payloads
/// to SharedPreferences for offline capability.
class LocalCacheService {
  LocalCacheService(this._prefs);

  final SharedPreferences _prefs;
  static const String _cachePrefix = 'api_cache_';

  /// Saves [data] into the local cache under the given [key].
  Future<void> saveCache(String key, dynamic data) async {
    try {
      final jsonString = jsonEncode(data);
      await _prefs.setString('$_cachePrefix$key', jsonString);
    } catch (_) {
      // Ignore cache serialization errors
    }
  }

  /// Retrieves and decodes data from the cache for the given [key].
  /// Returns null if no cache is found.
  dynamic getCache(String key) {
    try {
      final jsonString = _prefs.getString('$_cachePrefix$key');
      if (jsonString != null) {
        return jsonDecode(jsonString);
      }
    } catch (_) {
      // Ignore cache decoding errors
    }
    return null;
  }
}
