import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/common/l10n/app_translations.dart';

class ProfileController extends ChangeNotifier {
  ProfileController() {
    _loadDarkMode();
    _loadLanguage();
    loadUserData();
  }

  bool isNotificationOn = true;
  bool isDarkModeOn = false;
  
  String userName = 'Người dùng';
  String userEmail = '';
  String memberSince = '2024';
  Uint8List? avatarBytes;
  String currentLanguage = 'vi'; // 'vi' or 'en'

  /// Lấy chuỗi dịch theo key
  String tr(String key) => AppTranslations.tr(key, currentLanguage);

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('auth_user_profile');
    if (userString != null) {
      final user = jsonDecode(userString);
      userName = user['name'] ?? user['fullName'] ?? 'Người dùng';
      userEmail = user['email'] ?? '';
      if (user['createdAt'] != null) {
        try {
          final date = DateTime.parse(user['createdAt']);
          memberSince = date.year.toString();
        } catch (_) {}
      }
      notifyListeners();
    }
    
    // Load Avatar
    final avatarString = prefs.getString('user_avatar_base64');
    if (avatarString != null) {
      avatarBytes = base64Decode(avatarString);
      notifyListeners();
    }
  }

  void toggleNotification(bool value) {
    isNotificationOn = value;
    notifyListeners(); // Báo cho UI vẽ lại (Chuẩn của Provider)
  }

  void toggleDarkMode(bool value) async {
    isDarkModeOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkModeOn', value);
  }

  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeOn = prefs.getBool('isDarkModeOn') ?? false;
    notifyListeners();
  }

  void changeLanguage(String langCode) async {
    currentLanguage = langCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLanguage', langCode);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    currentLanguage = prefs.getString('appLanguage') ?? 'vi';
    notifyListeners();
  }

  void reportIssue(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang mở form gửi phản hồi cho Admin...')),
    );
  }

  Future<void> pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      avatarBytes = await image.readAsBytes();
      notifyListeners();
      
      // Save Avatar to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_base64', base64Encode(avatarBytes!));
    }
  }

  Future<void> updateUserName(String newName) async {
    if (newName.trim().isNotEmpty) {
      userName = newName.trim();
      notifyListeners();
      
      // Save back to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('auth_user_profile');
      if (userString != null) {
        final user = jsonDecode(userString);
        user['name'] = userName;
        user['fullName'] = userName; // for backward compatibility
        await prefs.setString('auth_user_profile', jsonEncode(user));
      }
    }
  }

  void submitFeedback(BuildContext context, String content) {
    if (content.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cảm ơn bạn đã gửi phản hồi!')),
      );
    }
  }


}
