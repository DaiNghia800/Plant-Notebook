import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../controller/community_controller.dart';
import '../../controller/profile_controller.dart';
import '../../data/models/post.dart';
import '../../routes/route_constant.dart';
import '../../utils/app_colors.dart';

class PostDetailScreen extends StatefulWidget {
  final String? postId;
  const PostDetailScreen({Key? key, this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.postId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CommunityController>().loadPostDetail(widget.postId!);
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _timeAgo(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return '${diff.inDays} ngày trước';
      if (diff.inHours > 0) return '${diff.inHours} giờ trước';
      return '${diff.inMinutes} phút trước';
    } catch (_) {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    final controller = context.watch<CommunityController>();
    final theme = Theme.of(context);
    final post = controller.postDetail;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          lang.tr('post_detail'),
          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (post != null && post.userId == controller.currentUserId)
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () => _confirmDeletePost(context, controller, post.id),
            ),
        ],
      ),
      body: controller.isLoading && post == null
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : post == null
              ? Center(
                  child: Text(
                    'Không thể tải bài viết',
                    style: TextStyle(color: theme.hintColor),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Post Content ──
                            Container(
                              color: theme.colorScheme.surface,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Author header
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                                        child: Text(
                                          (post.author?.fullName.isNotEmpty == true)
                                              ? post.author!.fullName[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.author?.fullName ?? 'Người dùng',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            Text(
                                              _timeAgo(post.createdAt),
                                              style: TextStyle(color: theme.hintColor, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Post text
                                  Text(
                                    post.content,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: theme.colorScheme.onSurface,
                                      height: 1.6,
                                    ),
                                  ),
                                  // Post image
                                  if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 14),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                            fullscreenImageRoute,
                                            arguments: post.imageUrl,
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: CachedNetworkImage(
                                            imageUrl: post.imageUrl!,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(
                                              height: 250,
                                              color: theme.primaryColor.withOpacity(0.08),
                                              child: Center(
                                                child: CircularProgressIndicator(color: theme.primaryColor, strokeWidth: 2),
                                              ),
                                            ),
                                            errorWidget: (_, __, ___) => Container(
                                              height: 250,
                                              color: theme.primaryColor.withOpacity(0.08),
                                              child: Icon(Icons.image_not_supported_outlined, color: theme.hintColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  // Like & comment row
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => controller.toggleLike(post.id),
                                        child: Row(
                                          children: [
                                            Icon(
                                              post.isLiked ? Icons.favorite : Icons.favorite_border,
                                              color: post.isLiked ? Colors.red : theme.hintColor,
                                              size: 26,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${post.likeCount}',
                                              style: TextStyle(
                                                color: theme.hintColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Row(
                                        children: [
                                          Icon(Icons.chat_bubble_outline, color: theme.hintColor, size: 22),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${post.comments.length}',
                                            style: TextStyle(
                                              color: theme.hintColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => _sharePost(post),
                                        child: Row(
                                          children: [
                                            Icon(Icons.share_outlined, color: theme.hintColor, size: 22),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Chia sẻ',
                                              style: TextStyle(
                                                color: theme.hintColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ── Comments ──
                            Container(
                              color: theme.colorScheme.surface,
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                              child: Text(
                                lang.tr('comments'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            ...post.comments.map((c) => _buildCommentItem(context, c, controller, post.id, theme)),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    // ── Comment input ──
                    _buildCommentInput(context, controller, post.id, theme),
                  ],
                ),
    );
  }

  Widget _buildCommentItem(
    BuildContext context,
    PostComment comment,
    CommunityController controller,
    String postId,
    ThemeData theme,
  ) {
    final isOwner = comment.userId == controller.currentUserId;
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: theme.primaryColor.withOpacity(0.2),
            child: Text(
              (comment.author?.fullName.isNotEmpty == true)
                  ? comment.author!.fullName[0].toUpperCase()
                  : '?',
              style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.author?.fullName ?? 'Người dùng',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 3),
                      Text(comment.content, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 3),
                  child: Row(
                    children: [
                      Text(_timeAgo(comment.createdAt), style: TextStyle(color: theme.hintColor, fontSize: 11)),
                      if (isOwner) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _showEditCommentDialog(context, controller, postId, comment),
                          child: Text('Sửa', style: TextStyle(color: theme.primaryColor, fontSize: 11)),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => controller.deleteComment(commentId: comment.id, postId: postId),
                          child: Text('Xóa', style: TextStyle(color: theme.colorScheme.error, fontSize: 11)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    CommunityController controller,
    String postId,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), offset: const Offset(0, -2), blurRadius: 8)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: theme.primaryColor.withOpacity(0.15),
              child: Icon(Icons.person, color: theme.primaryColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: controller.isSubmitting
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: theme.primaryColor, strokeWidth: 2),
                    )
                  : Icon(Icons.send_rounded, color: theme.primaryColor),
              onPressed: controller.isSubmitting
                  ? null
                  : () async {
                      if (_commentController.text.trim().isEmpty) return;
                      final ok = await controller.createComment(
                        postId: postId,
                        content: _commentController.text,
                      );
                      if (ok) {
                        FocusScope.of(context).unfocus();
                        _commentController.clear();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePost(BuildContext context, CommunityController controller, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bài viết'),
        content: const Text('Bạn có chắc muốn xóa bài viết này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await controller.deletePost(postId);
              if (ok && context.mounted) Navigator.of(context).pop();
            },
            child: Text('Xóa', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(BuildContext context, CommunityController controller, String postId, PostComment comment) {
    final TextEditingController editCtrl = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa bình luận'),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nhập nội dung mới'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              if (editCtrl.text.trim().isEmpty) return;
              final ok = await controller.updateComment(
                commentId: comment.id,
                postId: postId,
                content: editCtrl.text,
              );
              if (ok && ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _sharePost(Post post) {
    final authorName = post.author?.fullName ?? 'Một người dùng';
    final content = post.content;
    final snippet = content.length > 100 ? '${content.substring(0, 100)}...' : content;
    
    String shareText = '🌱 $authorName vừa chia sẻ trên Plant Notebook:\n\n"$snippet"\n\n';
    
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      shareText += 'Xem ảnh tại: ${post.imageUrl}\n\n';
    }
    
    shareText += 'Tải ứng dụng Plant Notebook ngay để tham gia cộng đồng yêu cây! 🌿';
    
    Share.share(shareText, subject: 'Chia sẻ từ Plant Notebook');
  }
}