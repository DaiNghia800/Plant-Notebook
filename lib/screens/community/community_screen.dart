import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/community_controller.dart';
import '../../controller/profile_controller.dart';
import '../../data/models/post.dart';
import 'package:plant_notebook/controller/profile_controller.dart';
import '../../utils/app_colors.dart';
import '../../routes/route_constant.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityController>().loadPosts();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final controller = context.read<CommunityController>();
        if (!controller.isLoading && !controller.isLoadingMore && controller.hasMorePosts) {
          controller.loadMorePosts();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ProfileController>();
    final controller = context.watch<CommunityController>();
    final theme = Theme.of(context);

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
          lang.tr('community'),
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            onPressed: () => controller.loadPosts(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.post_add, color: Colors.white),
        label: const Text('Đăng bài', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showCreateOrEditPostSheet(context: context, controller: controller),
      ),
      body: _buildBody(context, controller, theme),
    );
  }

  Widget _buildBody(BuildContext context, CommunityController controller, ThemeData theme) {
    if (controller.isLoading && controller.posts.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const _SkeletonPostCard(),
      );
    }

    if (controller.errorMessage != null && controller.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: theme.hintColor),
            const SizedBox(height: 12),
            Text(
              'Không thể tải bài viết\nKiểm tra kết nối mạng',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.loadPosts(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
            ),
          ],
        ),
      );
    }

    if (controller.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: theme.hintColor),
            const SizedBox(height: 12),
            Text(
              'Chưa có bài viết nào\nHãy là người đầu tiên chia sẻ!',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: theme.primaryColor,
      onRefresh: () => controller.loadPosts(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: controller.posts.length + (controller.hasMorePosts ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == controller.posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _PostCard(
            post: controller.posts[index],
            onEdit: () => _showCreateOrEditPostSheet(
              context: context,
              controller: controller,
              postToEdit: controller.posts[index],
            ),
          );
        },
      ),
    );
  }

  void _showCreateOrEditPostSheet({
    required BuildContext context,
    required CommunityController controller,
    Post? postToEdit,
  }) {
    final bool isEdit = postToEdit != null;
    final TextEditingController contentCtrl = TextEditingController(text: postToEdit?.content ?? '');
    String? selectedImagePath;
    bool retainOldImage = isEdit && postToEdit.imageUrl != null;
    StateSetter? sheetSetState;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            sheetSetState = setSt;
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Sửa bài viết' : 'Đăng bài viết mới',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 5,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Bạn muốn chia sẻ điều gì về cây cối hôm nay? 🌱',
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedImagePath != null || retainOldImage)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: selectedImagePath != null
                              ? Image.file(
                                  File(selectedImagePath!),
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: postToEdit!.imageUrl!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 6, right: 6,
                          child: GestureDetector(
                            onTap: () {
                              setSt(() {
                                selectedImagePath = null;
                                retainOldImage = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.image_outlined, color: Theme.of(context).primaryColor),
                        label: Text(
                          'Thêm ảnh',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                          if (file != null) {
                            setSt(() {
                              selectedImagePath = file.path;
                              retainOldImage = false;
                            });
                          }
                        },
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: controller.isSubmitting
                            ? null
                            : () async {
                                if (contentCtrl.text.trim().isEmpty) return;
                                bool ok = false;
                                if (isEdit) {
                                  ok = await controller.updatePost(
                                    postId: postToEdit.id,
                                    content: contentCtrl.text,
                                    imagePath: selectedImagePath,
                                    // Chú ý: Backend hiện tại chưa xử lý việc xoá ảnh cũ nếu retainOldImage = false và selectedImagePath = null
                                    // Bạn có thể cần update backend nếu muốn xoá hẳn ảnh.
                                  );
                                } else {
                                  ok = await controller.createPost(
                                    content: contentCtrl.text,
                                    imagePath: selectedImagePath,
                                  );
                                }
                                if (ok && ctx.mounted) Navigator.pop(ctx);
                              },
                        child: controller.isSubmitting
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(isEdit ? 'Lưu' : 'Đăng', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Widget thẻ bài viết ───────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onEdit;
  const _PostCard({required this.post, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<CommunityController>();
    final theme = Theme.of(context);
    final isOwner = post.userId == controller.currentUserId;

    String timeAgo = '';
    try {
      final dt = DateTime.parse(post.createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) {
        timeAgo = '${diff.inDays} ngày trước';
      } else if (diff.inHours > 0) {
        timeAgo = '${diff.inHours} giờ trước';
      } else {
        timeAgo = '${diff.inMinutes} phút trước';
      }
    } catch (_) {
      timeAgo = 'Vừa xong';
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          communityPostDetailRoute,
          arguments: post.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              leading: GestureDetector(
                onTap: () {
                  // Chuyển sang profile user (nếu làm tính năng này)
                },
                child: CircleAvatar(
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
              ),
              title: GestureDetector(
                onTap: () {},
                child: Text(
                  post.author?.fullName ?? 'Người dùng',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text(timeAgo, style: TextStyle(color: theme.hintColor, fontSize: 12)),
              trailing: isOwner
                  ? PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: theme.hintColor),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          _confirmDeletePost(context, controller, post.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Sửa bài viết')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa bài viết', style: TextStyle(color: theme.colorScheme.error)),
                        ),
                      ],
                    )
                  : null,
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, height: 1.5),
              ),
            ),
            // Image
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(fullscreenImageRoute, arguments: post.imageUrl);
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 200,
                        color: theme.primaryColor.withOpacity(0.08),
                        child: Center(child: CircularProgressIndicator(color: theme.primaryColor, strokeWidth: 2)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 200,
                        color: theme.primaryColor.withOpacity(0.08),
                        child: Icon(Icons.image_not_supported_outlined, color: theme.hintColor),
                      ),
                    ),
                  ),
                ),
              ),
            // Footer actions
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Like button
                  GestureDetector(
                    onTap: () => controller.toggleLike(post.id),
                    child: Row(
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: post.isLiked ? Colors.red : theme.hintColor,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.likeCount}',
                          style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Comment count
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: theme.hintColor, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  // Share button
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _sharePost(post),
                    child: Row(
                      children: [
                        Icon(Icons.share_outlined, color: theme.hintColor, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Chia sẻ',
                          style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              await controller.deletePost(postId);
            },
            child: Text('Xóa', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

// ── Widget Skeleton (Shimmer) ────────────────────────────────────────────────
class _SkeletonPostCard extends StatelessWidget {
  const _SkeletonPostCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.white),
              title: Container(height: 14, width: 100, color: Colors.white),
              subtitle: Container(height: 10, width: 60, color: Colors.white, margin: const EdgeInsets.only(top: 6)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 150, color: Colors.white),
                ],
              ),
            ),
            Container(height: 180, width: double.infinity, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(height: 20, width: 40, color: Colors.white),
                  const SizedBox(width: 20),
                  Container(height: 20, width: 40, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
