import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (var file in files) {
    var content = file.readAsStringSync();
    if (content.contains("const Text('\${Provider.of<RatesProvider>(context).currencySymbol} '")) {
      content = content.replaceAll(
        "const Text('\${Provider.of<RatesProvider>(context).currencySymbol} '", 
        "Text('\${Provider.of<RatesProvider>(context).currencySymbol} '"
      );
      file.writeAsStringSync(content);
      print("Fixed const Text in \${file.path}");
    }
    
    if (content.contains("const Text('\${Provider.of<RatesProvider>(context).currencySymbol}'")) {
      content = content.replaceAll(
        "const Text('\${Provider.of<RatesProvider>(context).currencySymbol}'", 
        "Text('\${Provider.of<RatesProvider>(context).currencySymbol}'"
      );
      file.writeAsStringSync(content);
      print("Fixed const Text in \${file.path}");
    }
  }
}
