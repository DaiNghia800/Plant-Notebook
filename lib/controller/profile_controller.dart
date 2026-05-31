import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends ChangeNotifier {
  bool isNotificationOn = true;
  bool isDarkModeOn = false;
  
  String userName = 'Nguyễn Văn An';
  Uint8List? avatarBytes;
  String currentLanguage = 'Tiếng Việt';

  void toggleNotification(bool value) {
    isNotificationOn = value;
    notifyListeners(); // Báo cho UI vẽ lại (Chuẩn của Provider)
  }

  void toggleDarkMode(bool value) {
    isDarkModeOn = value;
    notifyListeners();
  }

  // Translations
  String get textTitle => currentLanguage == 'English' ? 'Plant Notebook' : 'Sổ tay cây trồng';
  String get textMemberSince => currentLanguage == 'English' ? 'MEMBER SINCE 2024' : 'THÀNH VIÊN TỪ 2024';
  String get textPlants => currentLanguage == 'English' ? '12 Plants' : '12 Cây trồng';
  String get textLevel => currentLanguage == 'English' ? 'Level 5' : 'Cấp 5';
  String get textSettings => currentLanguage == 'English' ? 'APP SETTINGS' : 'CÀI ĐẶT ỨNG DỤNG';
  String get textNotification => currentLanguage == 'English' ? 'Notifications' : 'Thông báo';
  String get textDarkMode => currentLanguage == 'English' ? 'Dark Mode' : 'Chế độ tối';
  String get textLanguage => currentLanguage == 'English' ? 'Language' : 'Ngôn ngữ';
  String get textInviteFriends => currentLanguage == 'English' ? 'Invite Friends' : 'Giới thiệu bạn bè';
  String get textFeedback => currentLanguage == 'English' ? 'Feedback / Report Issue' : 'Phản hồi/Báo lỗi';
  String get textLogout => currentLanguage == 'English' ? 'Logout' : 'Đăng xuất';

  // Community Translations
  String get textCommunity => currentLanguage == 'English' ? 'Community' : 'Cộng đồng';
  String get textPostDetail => currentLanguage == 'English' ? 'Post Detail' : 'Bài viết';
  String get textTimeAgo => currentLanguage == 'English' ? '2 hours ago' : '2 giờ trước';
  String get textPostContent => currentLanguage == 'English' ? 'Repotted my succulents yesterday. So cute! 🌱' : 'Góc sen đá mới thay chậu hôm qua. Nhìn cưng xỉu luôn mọi người ơi! 🌱';
  String get textPostImage => currentLanguage == 'English' ? 'Post Image' : 'Hình ảnh bài viết';
  String get textComments => currentLanguage == 'English' ? 'Comments' : 'Bình luận';
  String get textCommentTime => currentLanguage == 'English' ? '15 minutes ago' : '15 phút trước';
  String get textCommentContent => currentLanguage == 'English' ? 'So beautiful! Where did you buy the pot?' : 'Đẹp quá bạn ơi! Chậu mua ở đâu vậy?';
  String get textAddComment => currentLanguage == 'English' ? 'Add a comment...' : 'Thêm bình luận...';

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

  void updateUserName(String newName) {
    if (newName.trim().isNotEmpty) {
      userName = newName.trim();
      notifyListeners();
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