import 'dart:io';

void main() async {
  final process = await Process.run('flutter', ['analyze']);
  final lines = process.stdout.toString().split('\n');
  
  final regex = RegExp(r'Invalid constant value - (lib\\[^:]+):(\d+):');
  final Map<String, List<int>> fileLines = {};
  
  for (var line in lines) {
    final match = regex.firstMatch(line);
    if (match != null) {
      final file = match.group(1)!;
      final lineNum = int.parse(match.group(2)!);
      if (!fileLines.containsKey(file)) {
        fileLines[file] = [];
      }
      fileLines[file]!.add(lineNum);
    }
  }
  
  for (var file in fileLines.keys) {
    final f = File(file);
    if (!f.existsSync()) continue;
    final contentLines = f.readAsLinesSync();
    
    // Sort descending to not mess up line numbers if we were inserting,
    // but here we just replace in place
    for (var lineNum in fileLines[file]!) {
      if (lineNum > 0 && lineNum <= contentLines.length) {
        contentLines[lineNum - 1] = contentLines[lineNum - 1].replaceAll('const ', '');
      }
    }
    
    f.writeAsStringSync(contentLines.join('\n'));
    print('Fixed const in $file');
  }
}
