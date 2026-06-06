import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/profile_controller.dart';
import '../../utils/app_colors.dart';
import '../../routes/route_constant.dart';

class CommunityScreen extends StatelessWidget {
  CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(controller.tr('community'), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.post_add, color: Theme.of(context).colorScheme.surface),
        onPressed: () {}, // Mở modal đăng bài viết
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5, // Tạm thời hardcode 5 bài viết
        itemBuilder: (context, index) {
          return _buildPostCard(context, controller);
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, ProfileController controller) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(communityPostDetailRoute);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header: User Info
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32')),
            title: Text('Trần Minh Tuấn', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(controller.tr('time_ago')),
            trailing: IconButton(icon: Icon(Icons.more_horiz), onPressed: () {}),
          ),
          // Body: Text & Image
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(controller.tr('post_content')),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            child: Center(child: Text(controller.tr('post_image'), style: TextStyle(color: Theme.of(context).hintColor))),
            // Thực tế em dùng: Image.network('url_anh', fit: BoxFit.cover)
          ),
          // Footer: Actions (Like, Comment)
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                _buildActionIcon(context, Icons.favorite_border, '124'),
                SizedBox(width: 20),
                _buildActionIcon(context, Icons.chat_bubble_outline, '28'),
              ],
            ),
          )
        ],
      ),
    ),
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).hintColor, size: 24),
        SizedBox(width: 6),
        Text(count, style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}