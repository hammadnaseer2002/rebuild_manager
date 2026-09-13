import 'dart:io';

void main() {
  final filesToUpdate = [
    'lib/screens/calculators/tiles_calculator_screen.dart',
    'lib/screens/calculators/project_report_screen.dart',
    'lib/screens/calculators/plumbing_calculator_screen.dart',
    'lib/screens/calculators/paint_calculator_screen.dart',
    'lib/screens/calculators/furniture_fixtures_screen.dart',
    'lib/screens/calculators/flooring_calculator_screen.dart',
    'lib/screens/calculators/electrical_calculator_screen.dart',
    'lib/screens/calculators/doors_windows_screen.dart',
    'lib/screens/calculators/complete_estimate_screen.dart',
    'lib/screens/calculators/ceiling_calculator_screen.dart',
    'lib/screens/rates/initial_rates_setup_screen.dart',
    'lib/utils/pdf_report_service.dart',
  ];

  for (var path in filesToUpdate) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    bool changed = false;

    // Check if RatesProvider is imported, if not add it.
    if (!content.contains("import '../../providers/rates_provider.dart';") &&
        !content.contains("import '../providers/rates_provider.dart';") &&
        !content.contains("import 'package:rebulid_manager/providers/rates_provider.dart';") &&
        !path.contains('pdf_report_service.dart')) { // Skip pdf_report_service for provider import
        
        // Add import
        final importStatement = path.contains('screens/calculators/') || path.contains('screens/rates/') 
            ? "import '../../providers/rates_provider.dart';" 
            : "import '../providers/rates_provider.dart';";
            
        // find a good place to insert (after other imports)
        content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';\n$importStatement");
        changed = true;
    }

    // specific replacement for screens/calculators components that use _formatAmount or _formatCurrency
    // They usually do `prefix: 'Rs ',` or `Text('Rs ')` or `'Rs ${_formatAmount(...)}'`
    // We will use Provider.of<RatesProvider>(context).currencySymbol instead.

    // 1. prefix: 'Rs ', -> prefix: '${Provider.of<RatesProvider>(context).currencySymbol} ',
    if (content.contains("prefix: 'Rs ',")) {
      content = content.replaceAll("prefix: 'Rs ',", "prefix: '\${Provider.of<RatesProvider>(context).currencySymbol} ',");
      changed = true;
    }
    if (content.contains("prefix: 'Rs',")) {
      content = content.replaceAll("prefix: 'Rs',", "prefix: '\${Provider.of<RatesProvider>(context).currencySymbol}',");
      changed = true;
    }

    // 2. Text('Rs ') -> Text('${Provider.of<RatesProvider>(context).currencySymbol} ')
    if (content.contains("Text('Rs '")) {
      content = content.replaceAll("Text('Rs '", "Text('\${Provider.of<RatesProvider>(context).currencySymbol} '");
      changed = true;
    }

    // 3. 'Rs ${_fmt(...)}' -> '${Provider.of<RatesProvider>(context).currencySymbol} ${_fmt(...)}'
    if (content.contains("'Rs \${")) {
      content = content.replaceAll("'Rs \${", "'\${Provider.of<RatesProvider>(context).currencySymbol} \${");
      changed = true;
    }
    
    // 4. 'Rs ' + variable -> '${Provider.of<RatesProvider>(context).currencySymbol} ' + variable
    if (content.contains("'Rs '")) {
       // Only replace if it's still there after the above replacements
       content = content.replaceAll("'Rs '", "'\${Provider.of<RatesProvider>(context).currencySymbol} '");
       changed = true;
    }
    
    if (content.contains("'Rs'")) {
       // Only replace if it's still there after the above replacements
       content = content.replaceAll("'Rs'", "'\${Provider.of<RatesProvider>(context).currencySymbol}'");
       changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print("Updated \$path");
    }
  }
}
