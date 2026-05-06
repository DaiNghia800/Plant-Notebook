import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/profile_controller.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bọc Provider ngay tại màn hình này để không phải cấu hình lại main.dart
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: const ProfileView(),
    );
  }
}

// Màn hình chính đã loại bỏ Scaffold, y hệt như HomeScreen
class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gọi controller từ Provider
    final controller = context.watch<ProfileController>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Tự custom, thay thế cho AppBar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Tàng hình để cân bằng chữ ra giữa
                const Text(
                  'Sổ tay cây trồng',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.textMain),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            // 2. Nội dung Profile
            _buildProfileCard(),
            const SizedBox(height: 30),
            const Text('CÀI ĐẶT ỨNG DỤNG',
                style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            _buildSettingsCard(context, controller),
            const SizedBox(height: 30),
            _buildLogoutButton(),
            const SizedBox(height: 50), // Khoảng trống dưới cùng
          ],
        ),
      ),
    );
  }

  // 1. Thẻ Thông tin cá nhân
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                child: const Icon(Icons.person, size: 50, color: AppColors.primary),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: AppColors.white, size: 16),
              )
            ],
          ),
          const SizedBox(height: 15),
          const Text('Nguyễn Văn An',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 5),
          const Text('THÀNH VIÊN TỪ 2024',
              style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(Icons.eco, '12 Cây trồng'),
              const SizedBox(width: 15),
              _buildStatChip(Icons.military_tech, 'Cấp 5'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
        ],
      ),
    );
  }

  // 2. Thẻ Cài đặt & Toggle
  Widget _buildSettingsCard(BuildContext context, ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Thông báo',
            trailing: Switch(
              value: controller.isNotificationOn,
              onChanged: controller.toggleNotification,
              activeColor: AppColors.primary,
            ),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: 'Chế độ tối',
            trailing: Switch(
              value: controller.isDarkModeOn,
              onChanged: controller.toggleDarkMode,
              activeColor: AppColors.primary,
            ),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.translate,
            title: 'Ngôn ngữ',
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tiếng Việt', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                SizedBox(width: 5),
                Icon(Icons.chevron_right, color: AppColors.textLight)
              ],
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.person_add_alt_1,
            title: 'Giới thiệu bạn bè',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
            onTap: () => controller.reportIssue(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required Widget trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textMain)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 70, endIndent: 20, color: AppColors.background);

  // 3. Nút Đăng xuất
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: AppColors.danger),
        label: const Text('Đăng xuất', style: TextStyle(color: AppColors.danger, fontSize: 16, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.danger, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}