import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_notebook/data/services/firebase_messaging_service.dart';
import 'package:plant_notebook/routes/route_constant.dart';
import '../../controller/profile_controller.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _fcmToken;
  String? _userId;
  String? _userEmail;
  bool _isLoadingToken = true;
  bool _isSendingTest = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userEmail = prefs.getString('userEmail');
    final token = await FirebaseMessagingService.getToken();
    if (userId != null && token != null) {
      await FirebaseMessagingService.registerToken(userId);
    }

    setState(() {
      _userId = userId;
      _userEmail = userEmail;
      _fcmToken = token;
      _isLoadingToken = false;
    });
  }

  Future<void> _sendTestNotification() async {
    if (_userId == null) return;

    setState(() => _isSendingTest = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/user/send-test-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _userId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Thông báo thử nghiệm đã gửi!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ Gửi thất bại')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Lỗi: $e')));
    } finally {
      setState(() => _isSendingTest = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    // Remove FCM token from server
    if (userId != null) {
      await FirebaseMessagingService.removeFcmTokenFromServer(userId);
    }

    // Clear local data
    await prefs.remove('userId');
    await prefs.remove('userEmail');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, loginViewRoute);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileView(onLogout: _logout);
  }
}

// Màn hình chính đã loại bỏ Scaffold, y hệt như HomeScreen
class ProfileView extends StatelessWidget {
  const ProfileView({super.key, this.onLogout});

  final VoidCallback? onLogout;

  void _showEditProfileBottomSheet(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image, color: Theme.of(context).primaryColor),
                title: Text('Đổi ảnh đại diện', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickAvatar();
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                title: Text('Đổi tên hiển thị', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditNameDialog(context, controller);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, ProfileController controller) {
    final TextEditingController nameController = TextEditingController(text: controller.userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Đổi tên hiển thị', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Nhập tên mới',
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: TextStyle(color: Theme.of(context).hintColor))),
            ElevatedButton(
              onPressed: () {
                controller.updateUserName(nameController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text('Lưu', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn ngôn ngữ', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Tiếng Việt', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  controller.changeLanguage('Tiếng Việt');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('English', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  controller.changeLanguage('English');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context, ProfileController controller) {
    final TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Phản hồi / Báo lỗi', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung...',
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: TextStyle(color: Theme.of(context).hintColor))),
            ElevatedButton(
              onPressed: () {
                controller.submitFeedback(context, feedbackController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text('Gửi', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gọi controller từ Provider
    final controller = context.watch<ProfileController>();

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Nội dung Profile
            _buildProfileCard(context, controller),
            SizedBox(height: 30),
            Text(controller.textSettings,
                style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            SizedBox(height: 15),
            _buildSettingsCard(context, controller),
            SizedBox(height: 30),
            _buildLogoutButton(context, controller),
            SizedBox(height: 50), // Khoảng trống dưới cùng
          ],
        ),
      ),
    );
  }

  // 1. Thẻ Thông tin cá nhân
  Widget _buildProfileCard(BuildContext context, ProfileController controller) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showEditProfileBottomSheet(context, controller),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  backgroundImage: controller.avatarBytes != null ? MemoryImage(controller.avatarBytes!) : null,
                  child: controller.avatarBytes == null ? Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor) : null,
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                  ),
                  child: Icon(Icons.edit, color: Theme.of(context).colorScheme.surface, size: 16),
                )
              ],
            ),
          ),
          SizedBox(height: 15),
          Text(controller.userName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: 5),
          Text(controller.textMemberSince,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(context, Icons.eco, controller.textPlants),
              SizedBox(width: 15),
              _buildStatChip(context, Icons.military_tech, controller.textLevel),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 18),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  // 2. Thẻ Cài đặt & Toggle
  Widget _buildSettingsCard(BuildContext context, ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.notifications,
            title: controller.textNotification,
            trailing: Switch(
              value: controller.isNotificationOn,
              onChanged: controller.toggleNotification,
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.dark_mode,
            title: controller.textDarkMode,
            trailing: Switch(
              value: controller.isDarkModeOn,
              onChanged: controller.toggleDarkMode,
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.translate,
            title: controller.textLanguage,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.currentLanguage, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
                SizedBox(width: 5),
                Icon(Icons.chevron_right, color: Theme.of(context).hintColor)
              ],
            ),
            onTap: () => _showLanguageDialog(context, controller),
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.person_add_alt_1,
            title: controller.textInviteFriends,
            trailing: Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
            onTap: () => controller.reportIssue(context),
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.feedback_outlined,
            title: controller.textFeedback,
            trailing: Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
            onTap: () => _showFeedbackDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {required IconData icon, required String title, required Widget trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) => Divider(height: 1, indent: 70, endIndent: 20, color: Theme.of(context).scaffoldBackgroundColor);

  // 3. Nút Đăng xuất
  Widget _buildLogoutButton(BuildContext context, ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
        label: Text(controller.textLogout, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
