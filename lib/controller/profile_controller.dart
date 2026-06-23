import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plant_notebook/common/l10n/app_translations.dart';
import 'package:plant_notebook/data/network/dio_client.dart';
import 'package:plant_notebook/data/services/firebase_messaging_service.dart';

class ProfileController extends ChangeNotifier {
  ProfileController() {
    loadUserData();
  }

  bool isNotificationOn = true;
  bool isDarkModeOn = false;

  String userName = 'Người dùng';
  String userEmail = '';
  String memberSince = '2024';
  Uint8List? avatarBytes;
  String currentLanguage = 'vi';

  /// Lấy chuỗi dịch theo key
  String tr(String key) {
    final String langCode = currentLanguage == 'en' ? 'en' : 'vi';
    return AppTranslations.tr(key, langCode);
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load current language
    currentLanguage = prefs.getString('current_language') ?? 'vi';

    // Load local notification preference
    isNotificationOn = prefs.getBool('is_notification_on') ?? true;

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

    // Fetch fresh user data from API to get actual createdAt
    final String? userId = prefs.getString('userId');
    if (userId != null) {
      try {
        final dio = DioClient.createDio();
        final response = await dio.get('/user/$userId');
        if (response.statusCode == 200 && response.data != null) {
          final freshUser = response.data;
          userName = freshUser['fullName'] ?? freshUser['name'] ?? userName;
          userEmail = freshUser['email'] ?? userEmail;
          if (freshUser['createdAt'] != null) {
            try {
              final date = DateTime.parse(freshUser['createdAt']);
              memberSince = date.year.toString();
            } catch (_) {}
          }
          await prefs.setString('auth_user_profile', jsonEncode(freshUser));
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Lỗi khi tải dữ liệu người dùng mới từ server: $e');
      }
    }
  }

  void toggleNotification(bool value) {
    isNotificationOn = value;
    notifyListeners(); // Báo cho UI vẽ lại (Chuẩn của Provider)

    SharedPreferences.getInstance()
        .then((prefs) async {
          await prefs.setBool('is_notification_on', value);
          final String? userId = prefs.getString('userId');
          if (userId != null) {
            if (value) {
              await FirebaseMessagingService.registerToken(userId);
            } else {
              await FirebaseMessagingService.removeFcmTokenFromServer(userId);
            }
          }
        })
        .catchError((e) {
          debugPrint('Lỗi khi cập nhật cài đặt thông báo: $e');
        });
  }

  void toggleDarkMode(bool value) {
    isDarkModeOn = value;
    notifyListeners();
  }

  // Translations
  String get textTitle =>
      currentLanguage == 'en' ? 'Plant Notebook' : 'Sổ tay cây trồng';
  String get textMemberSince => currentLanguage == 'en'
      ? 'MEMBER SINCE $memberSince'
      : 'THÀNH VIÊN TỪ $memberSince';
  String get textSettings =>
      currentLanguage == 'en' ? 'APP SETTINGS' : 'CÀI ĐẶT ỨNG DỤNG';
  String get textNotification =>
      currentLanguage == 'en' ? 'Notifications' : 'Thông báo';
  String get textDarkMode =>
      currentLanguage == 'en' ? 'Dark Mode' : 'Chế độ tối';
  String get textLanguage =>
      currentLanguage == 'en' ? 'Language' : 'Ngôn ngữ';
  String get textInviteFriends =>
      currentLanguage == 'en' ? 'Invite Friends' : 'Giới thiệu bạn bè';
  String get textFeedback => currentLanguage == 'en'
      ? 'Feedback / Report Issue'
      : 'Phản hồi/Báo lỗi';
  String get textLogout =>
      currentLanguage == 'en' ? 'Logout' : 'Đăng xuất';

  // Community Translations
  String get textCommunity =>
      currentLanguage == 'en' ? 'Community' : 'Cộng đồng';
  String get textPostDetail =>
      currentLanguage == 'en' ? 'Post Detail' : 'Bài viết';
  String get textTimeAgo =>
      currentLanguage == 'en' ? '2 hours ago' : '2 giờ trước';
  String get textPostContent => currentLanguage == 'en'
      ? 'Repotted my succulents yesterday. So cute! 🌱'
      : 'Góc sen đá mới thay chậu hôm qua. Nhìn cưng xỉu luôn mọi người ơi! 🌱';
  String get textPostImage =>
      currentLanguage == 'en' ? 'Post Image' : 'Hình ảnh bài viết';
  String get textComments =>
      currentLanguage == 'en' ? 'Comments' : 'Bình luận';
  String get textCommentTime =>
      currentLanguage == 'en' ? '15 minutes ago' : '15 phút trước';
  String get textCommentContent => currentLanguage == 'en'
      ? 'So beautiful! Where did you buy the pot?'
      : 'Đẹp quá bạn ơi! Chậu mua ở đâu vậy?';
  String get textAddComment =>
      currentLanguage == 'en' ? 'Add a comment...' : 'Thêm bình luận...';

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

  void changeLanguage(String language) {
    currentLanguage = language;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('current_language', language);
    });
    notifyListeners();
  }

  void submitFeedback(BuildContext context, String content) {
    if (content.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cảm ơn bạn đã gửi phản hồi!')),
      );
    }
  }
}
