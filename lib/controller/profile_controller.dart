import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  bool isNotificationOn = true;
  bool isDarkModeOn = false;

  void toggleNotification(bool value) {
    isNotificationOn = value;
    notifyListeners(); // Báo cho UI vẽ lại (Chuẩn của Provider)
  }

  void toggleDarkMode(bool value) {
    isDarkModeOn = value;
    notifyListeners();
  }

  void reportIssue(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang mở form gửi phản hồi cho Admin...')),
    );
  }
}