import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Cộng đồng', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textMain), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.post_add, color: AppColors.white),
        onPressed: () {}, // Mở modal đăng bài viết
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Tạm thời hardcode 5 bài viết
        itemBuilder: (context, index) {
          return _buildPostCard();
        },
      ),
    );
  }

  Widget _buildPostCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: User Info
          ListTile(
            leading: const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32')),
            title: const Text('Trần Minh Tuấn', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('2 giờ trước'),
            trailing: IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
          ),
          // Body: Text & Image
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Góc sen đá mới thay chậu hôm qua. Nhìn cưng xỉu luôn mọi người ơi! 🌱'),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: AppColors.secondary.withOpacity(0.3),
            child: const Center(child: Text('Hình ảnh bài viết', style: TextStyle(color: AppColors.textLight))),
            // Thực tế em dùng: Image.network('url_anh', fit: BoxFit.cover)
          ),
          // Footer: Actions (Like, Comment)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildActionIcon(Icons.favorite_border, '124'),
                const SizedBox(width: 20),
                _buildActionIcon(Icons.chat_bubble_outline, '28'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textLight, size: 24),
        const SizedBox(width: 6),
        Text(count, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold)),
      ],
    );
  }
}