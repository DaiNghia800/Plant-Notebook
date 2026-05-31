import 'dart:io';

void main() {
  final file = File('lib/screens/profile/profile_screen.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll('AppColors.primary', 'Theme.of(context).primaryColor');
  content = content.replaceAll('AppColors.background', 'Theme.of(context).scaffoldBackgroundColor');
  content = content.replaceAll('AppColors.white', 'Theme.of(context).colorScheme.surface');
  content = content.replaceAll('AppColors.danger', 'Theme.of(context).colorScheme.error');
  content = content.replaceAll('AppColors.secondary', 'Theme.of(context).colorScheme.secondary');
  content = content.replaceAll('AppColors.textMain', 'Theme.of(context).colorScheme.onSurface');
  content = content.replaceAll('AppColors.textLight', 'Theme.of(context).hintColor');

  // Remove the ChangeNotifierProvider wrapper from ProfileScreen
  content = content.replaceAll('''
class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bọc Provider ngay tại màn hình này để không phải cấu hình lại main.dart
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: ProfileView(),
    );
  }

}''', '''
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProfileView();
  }
}''');

  // Also remove 'import '../../utils/app_colors.dart';' since it's no longer needed
  // Or just leave it if there are other usages. Let's leave it to be safe or delete it if unused.

  file.writeAsStringSync(content);
  print('Replaced AppColors with Theme.of(context)');
}
