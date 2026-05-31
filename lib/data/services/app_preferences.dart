import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  /// Lấy trạng thái xem Onboarding
  static Future<bool> hasSeenOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Đánh dấu là đã xem Onboarding
  static Future<void> setHasSeenOnboarding(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, value);
  }
}
