import 'dart:io';

void main() {
  final files = [
    'lib/screens/community/community_screen.dart',
    'lib/screens/community/post_detail_screen.dart'
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains('Widget build(BuildContext context) {')) {
        if (!lines[i + 1].contains('final controller')) {
          lines.insert(i + 1, '    final controller = context.watch<ProfileController>();');
        }
        break;
      }
    }
    file.writeAsStringSync(lines.join('\n'));
    print('Fixed \$path');
  }
}
