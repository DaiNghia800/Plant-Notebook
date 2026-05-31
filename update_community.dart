import 'dart:io';

void main() {
  final file = File('lib/screens/community/community_screen.dart');
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
  content = content.replaceAll("'Cộng đồng'", "controller.textCommunity");
  content = content.replaceAll("'2 giờ trước'", "controller.textTimeAgo");
  content = content.replaceAll("'Góc sen đá mới thay chậu hôm qua. Nhìn cưng xỉu luôn mọi người ơi! 🌱'", "controller.textPostContent");
  content = content.replaceAll("'Hình ảnh bài viết'", "controller.textPostImage");

  // Pass controller to _buildPostCard if it doesn't already
  content = content.replaceFirst('return _buildPostCard(context);', 'return _buildPostCard(context, controller);');
  content = content.replaceFirst('Widget _buildPostCard(BuildContext context) {', 'Widget _buildPostCard(BuildContext context, ProfileController controller) {');
  
  // Pass context to _buildActionIcon so it can use Theme.of(context)
  content = content.replaceFirst("_buildActionIcon(Icons.favorite_border, '124')", "_buildActionIcon(context, Icons.favorite_border, '124')");
  content = content.replaceFirst("_buildActionIcon(Icons.chat_bubble_outline, '28')", "_buildActionIcon(context, Icons.chat_bubble_outline, '28')");
  content = content.replaceFirst('Widget _buildActionIcon(IconData icon, String count) {', 'Widget _buildActionIcon(BuildContext context, IconData icon, String count) {');

  // Optionally remove unused import AppColors
  // content = content.replaceAll("import '../../utils/app_colors.dart';\n", "");

  file.writeAsStringSync(content);
}
