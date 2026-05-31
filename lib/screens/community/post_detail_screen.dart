import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/profile_controller.dart';
import '../../utils/app_colors.dart';

class PostDetailScreen extends StatefulWidget {
  PostDetailScreen({Key? key}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool isLiked = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(controller.textPostDetail, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32')),
                          title: Text('Trần Minh Tuấn', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: Text(controller.textTimeAgo, style: TextStyle(color: Theme.of(context).hintColor)),
                          trailing: IconButton(icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.onSurface), onPressed: () {}),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Góc sen đá mới thay chậu hôm qua. Nhìn cưng xỉu luôn mọi người ơi! 🌱\nMẹo nhỏ: Đất trồng sen đá cần thoát nước cực tốt nha, mình hay trộn thêm đá perlite.',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(child: Text(controller.textPostImage, style: TextStyle(color: Theme.of(context).hintColor))),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isLiked = !isLiked;
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Theme.of(context).colorScheme.error : Theme.of(context).hintColor,
                                    size: 28,
                                  ),
                                  SizedBox(width: 8),
                                  Text(isLiked ? '125' : '124', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                            SizedBox(width: 24),
                            Row(
                              children: [
                                Icon(Icons.chat_bubble_outline, color: Theme.of(context).hintColor, size: 26),
                                SizedBox(width: 8),
                                Text('28', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(controller.textComments, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
                  ),
                  _buildCommentItem('Nguyễn Hoa', 'Đẹp quá bạn ơi!', '1 giờ trước', 'https://i.pravatar.cc/150?img=5'),
                  _buildCommentItem('Lê Hải', 'Cho mình hỏi tỷ lệ trộn đất của bạn với ạ?', '45 phút trước', 'https://i.pravatar.cc/150?img=11'),
                  _buildCommentItem('Minh Anh', 'Sen đá đá này tên gì vậy ạ?', '10 phút trước', 'https://i.pravatar.cc/150?img=9'),
                ],
              ),
            ),
          ),
          _buildCommentInput(context, controller),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String name, String content, String time, String avatarUrl) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 18),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      SizedBox(height: 4),
                      Text(content, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12, top: 4),
                  child: Text(time, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context, ProfileController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), offset: Offset(0, -2), blurRadius: 6),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.surface, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  // TODO: Thêm logic gửi bình luận
                  FocusScope.of(context).unfocus();
                  _commentController.clear();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}