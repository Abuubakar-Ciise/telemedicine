import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tele/services/StorageService.dart';

class Config {
  static const String _serverUrlKey = 'server_url';
  static String _serverUrl = '';

  /// Loads .env and the saved server address. Safe to call more than once and
  /// from background isolates (FCM handlers), where main() did not run.
  static Future<void> ensureLoaded() async {
    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {}
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      _serverUrl = prefs.getString(_serverUrlKey) ?? '';
    } catch (_) {}
  }

  static String _env(String key, [String fallback = '']) =>
      dotenv.isInitialized ? (dotenv.env[key] ?? fallback) : fallback;

  /// API address from .env (used when no address has been saved in the app).
  static String get defaultBaseUrl => normalizeUrl(_env('BASE_URL', 'http://192.168.100.8:2003'));

  /// Current API address: the one saved in Server settings, otherwise .env.
  static String get baseUrl => _serverUrl.isNotEmpty ? _serverUrl : defaultBaseUrl;
  static bool get isCustomServer => _serverUrl.isNotEmpty;

  /// "192.168.1.5:2003" -> "http://192.168.1.5:2003" (no trailing slash)
  static String normalizeUrl(String value) {
    var url = value.trim();
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) url = 'http://$url';
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Saves a new API address; pass null/empty to go back to the .env default.
  static Future<void> setServerUrl(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    final url = normalizeUrl(value ?? '');
    if (url.isEmpty || url == defaultBaseUrl) {
      _serverUrl = '';
      await prefs.remove(_serverUrlKey);
    } else {
      _serverUrl = url;
      await prefs.setString(_serverUrlKey, url);
    }
  }

  /// Returns null when the backend answers on /health, otherwise an error message.
  static Future<String?> testServer(String value) async {
    final url = normalizeUrl(value);
    try {
      final res = await http.get(Uri.parse('$url/health')).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200 && res.body.contains('ok')) return null;
      return 'Server answered with status ${res.statusCode}';
    } catch (e) {
      return 'Cannot reach $url. Check the address, that the backend is running, and that the phone is on the same Wi-Fi.';
    }
  }

  static int get appId => int.tryParse(_env('APPID', '0')) ?? 0;
  static String get appSign => _env('APPSING');
  static String get firebaseapkey => _env('FIREBASE_API_KEY');
  static String get firebaseappid => _env('FIREBASE_APP_ID');
  static String get firebasemessagingsenderid => _env('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseprojectid => _env('FIREBASE_PROJECT_ID');

  /// On Android, Firebase reads the right app ID for each build (release / .dev)
  /// from android/app/google-services.json, so no options are passed.
  /// Other platforms use the values from .env.
  static FirebaseOptions? get firebaseOptions => Platform.isAndroid
      ? null
      : FirebaseOptions(
          apiKey: firebaseapkey,
          appId: firebaseappid,
          messagingSenderId: firebasemessagingsenderid,
          projectId: firebaseprojectid,
        );

  /// "mock" (default when no WaafiPay keys are set) or "live".
  static bool get paymentMock =>
      _env('PAYMENT_MODE', 'mock').toLowerCase() != 'live' ||
      _env('MERCHANTUID').isEmpty ||
      _env('APIUSERID').isEmpty ||
      _env('APIKEY').isEmpty;

  static Future<String?> getUserId() async {
    Map<String, String?> userData = await StorageService.getUserData();
    return userData["userId"];
  }

  static Future<String?> getUserType() async {
    Map<String, String?> userData = await StorageService.getUserData();
    return userData["userType"];
  }

  static Future<String?> getUserName() async {
    Map<String, String?> userData = await StorageService.getUserData();
    return userData["username"];
  }

  static Future<String?> getUserToken() async {
    Map<String, String?> userData = await StorageService.getUserData();
    return userData["token"];
  }
}
