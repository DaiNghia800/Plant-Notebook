import 'dart:io';

void main() {
  final file = File('lib/screens/community/post_detail_screen.dart');
  var content = file.readAsStringSync();

  // Replace colors
  content = content.replaceAll('AppColors.primary', 'Theme.of(context).primaryColor');
  content = content.replaceAll('AppColors.background', 'Theme.of(context).scaffoldBackgroundColor');
  content = content.replaceAll('AppColors.white', 'Theme.of(context).colorScheme.surface');
  content = content.replaceAll('AppColors.secondary', 'Theme.of(context).colorScheme.secondary');
  content = content.replaceAll('AppColors.textMain', 'Theme.of(context).colorScheme.onSurface');
  content = content.replaceAll('AppColors.textLight', 'Theme.of(context).hintColor');
  content = content.replaceAll('AppColors.danger', 'Theme.of(context).colorScheme.error');

  // Add provider import if not exists
  if (!content.contains('package:provider/provider.dart')) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';\nimport '../../controller/profile_controller.dart';");
  }

  // Update build method to watch controller
  content = content.replaceFirst('''  @override
  Widget build(BuildContext context) {
    return Scaffold(''', '''  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    return Scaffold(''');

  // Replace text
  content = content.replaceAll("'Bài viết'", "controller.textPostDetail");
  content = content.replaceAll("'2 giờ trước'", "controller.textTimeAgo");
  content = content.replaceAll("'Góc sen đá mới thay chậu hôm qua. Nhìn cưng xỉu luôn mọi người ơi! 🌱'", "controller.textPostContent");
  content = content.replaceAll("'Hình ảnh bài viết'", "controller.textPostImage");
  content = content.replaceAll("'Bình luận'", "controller.textComments");
  content = content.replaceAll("'15 phút trước'", "controller.textCommentTime");
  content = content.replaceAll("'Đẹp quá bạn ơi! Chậu mua ở đâu vậy?'", "controller.textCommentContent");
  content = content.replaceAll("'Thêm bình luận...'", "controller.textAddComment");

  // Pass controller to helpers if needed
  content = content.replaceFirst('child: _buildCommentList(),', 'child: _buildCommentList(controller),');
  content = content.replaceFirst('Widget _buildCommentList() {', 'Widget _buildCommentList(ProfileController controller) {');
  
  content = content.replaceFirst('return _buildCommentItem(', 'return _buildCommentItem(context, controller, ');
  content = content.replaceFirst('Widget _buildCommentItem(String name, String time, String content) {', 'Widget _buildCommentItem(BuildContext context, ProfileController controller, String name, String time, String content) {');

  content = content.replaceFirst('_buildCommentInput(),', '_buildCommentInput(context, controller),');
  content = content.replaceFirst('Widget _buildCommentInput() {', 'Widget _buildCommentInput(BuildContext context, ProfileController controller) {');

  content = content.replaceFirst('_buildPostContent()', '_buildPostContent(context, controller)');
  content = content.replaceFirst('Widget _buildPostContent() {', 'Widget _buildPostContent(BuildContext context, ProfileController controller) {');

  // Fix Stateful widget variables:
  // PostDetailScreen has `bool isLiked = false;` in its state.
  // Wait, is PostDetailScreen a StatefulWidget?
  // Let's check using grep or assuming it is and context is available.
  // We added controller to `build`.
  
  // Optionally remove unused import AppColors
  // content = content.replaceAll("import '../../utils/app_colors.dart';\n", "");

  file.writeAsStringSync(content);
}
