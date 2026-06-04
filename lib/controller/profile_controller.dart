import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends ChangeNotifier {
  ProfileController() {
    loadUserProfile();
  }

  bool isNotificationOn = true;
  bool isDarkModeOn = false;

  String userName = 'Nguyễn Văn An';
  Uint8List? avatarBytes;
  String currentLanguage = 'Tiếng Việt';

  Future<void> loadUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString('auth_user_profile');
      if (profileJson != null) {
        final Map<String, dynamic> profile = jsonDecode(profileJson);
        if (profile.containsKey('name') && profile['name'] != null) {
          userName = profile['name'].toString();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile in ProfileController: $e');
    }
  }

  void toggleNotification(bool value) {
    isNotificationOn = value;
    notifyListeners(); // Báo cho UI vẽ lại (Chuẩn của Provider)
  }

  void toggleDarkMode(bool value) {
    isDarkModeOn = value;
    notifyListeners();
  }

  // Translations
  String get textTitle =>
      currentLanguage == 'English' ? 'Plant Notebook' : 'Sổ tay cây trồng';
  String get textMemberSince =>
      currentLanguage == 'English' ? 'MEMBER SINCE 2024' : 'THÀNH VIÊN TỪ 2024';
  String get textPlants =>
      currentLanguage == 'English' ? '12 Plants' : '12 Cây trồng';
  String get textLevel => currentLanguage == 'English' ? 'Level 5' : 'Cấp 5';
  String get textSettings =>
      currentLanguage == 'English' ? 'APP SETTINGS' : 'CÀI ĐẶT ỨNG DỤNG';
  String get textNotification =>
      currentLanguage == 'English' ? 'Notifications' : 'Thông báo';
  String get textDarkMode =>
      currentLanguage == 'English' ? 'Dark Mode' : 'Chế độ tối';
  String get textLanguage =>
      currentLanguage == 'English' ? 'Language' : 'Ngôn ngữ';
  String get textInviteFriends =>
      currentLanguage == 'English' ? 'Invite Friends' : 'Giới thiệu bạn bè';
  String get textFeedback => currentLanguage == 'English'
      ? 'Feedback / Report Issue'
      : 'Phản hồi/Báo lỗi';
  String get textLogout =>
      currentLanguage == 'English' ? 'Logout' : 'Đăng xuất';

  // Community Translations
  String get textCommunity =>
      currentLanguage == 'English' ? 'Community' : 'Cộng đồng';
  String get textPostDetail =>
      currentLanguage == 'English' ? 'Post Detail' : 'Bài viết';
  String get textTimeAgo =>
      currentLanguage == 'English' ? '2 hours ago' : '2 giờ trước';
  String get textPostContent => currentLanguage == 'English'
      ? 'Repotted my succulents yesterday. So cute! 🌱'
      : 'Góc sen đá mới thay chậu hôm qua. Nhìn cưng xỉu luôn mọi người ơi! 🌱';
  String get textPostImage =>
      currentLanguage == 'English' ? 'Post Image' : 'Hình ảnh bài viết';
  String get textComments =>
      currentLanguage == 'English' ? 'Comments' : 'Bình luận';
  String get textCommentTime =>
      currentLanguage == 'English' ? '15 minutes ago' : '15 phút trước';
  String get textCommentContent => currentLanguage == 'English'
      ? 'So beautiful! Where did you buy the pot?'
      : 'Đẹp quá bạn ơi! Chậu mua ở đâu vậy?';
  String get textAddComment =>
      currentLanguage == 'English' ? 'Add a comment...' : 'Thêm bình luận...';

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
    }
  }

  void updateUserName(String newName) async {
    if (newName.trim().isNotEmpty) {
      userName = newName.trim();
      notifyListeners();

      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? profileJson = prefs.getString('auth_user_profile');
        if (profileJson != null) {
          final Map<String, dynamic> profile = jsonDecode(profileJson);
          profile['name'] = userName;
          await prefs.setString('auth_user_profile', jsonEncode(profile));
        }
      } catch (e) {
        debugPrint('Error saving user profile name in ProfileController: $e');
      }
    }
  }

  void changeLanguage(String language) {
    currentLanguage = language;
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
