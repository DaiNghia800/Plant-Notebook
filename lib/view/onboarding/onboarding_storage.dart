import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const String completedKey = 'onboarding_completed';

  /// Kiểm tra người dùng đã hoàn tất onboarding hay chưa.
  static Future<bool> isCompleted() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(completedKey) ?? false;
  }

  /// Cập nhật cờ onboarding để điều khiển luồng mở app.
  static Future<void> setCompleted(bool value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(completedKey, value);
  }
}
