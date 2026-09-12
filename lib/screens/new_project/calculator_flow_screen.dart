import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../calculators/flooring_calculator_screen.dart';
import '../calculators/paint_calculator_screen.dart';
import '../calculators/tiles_calculator_screen.dart';
import '../calculators/ceiling_calculator_screen.dart';
import '../calculators/doors_windows_screen.dart';
import '../calculators/furniture_fixtures_screen.dart';
import '../calculators/electrical_calculator_screen.dart';
import '../calculators/plumbing_calculator_screen.dart';
import '../calculators/complete_estimate_screen.dart';

/// Smart router: shows the first selected calculator.
/// Each calculator calls [CalculatorFlowScreen.pushNext] to advance.
class CalculatorFlowScreen extends StatelessWidget {
  const CalculatorFlowScreen({super.key});

  static Widget screenFor(String key) {
    switch (key) {
      case 'flooring':
        return const FlooringCalculatorScreen();
      case 'paint':
        return const PaintCalculatorScreen();
      case 'tiles':
        return const TilesCalculatorScreen();
      case 'ceiling':
        return const CeilingCalculatorScreen();
      case 'doors_windows':
        return const DoorsWindowsScreen();
      case 'furniture':
        return const FurnitureFixturesScreen();
      case 'electrical':
        return const ElectricalCalculatorScreen();
      case 'plumbing':
        return const PlumbingCalculatorScreen();
      default:
        return const CompleteEstimateScreen();
    }
  }

  /// Called by each calculator's "Next" button.
  /// Pushes the next selected calculator, or CompleteEstimateScreen if done.
  static void pushNext(BuildContext context, String currentKey) {
    final provider = context.read<ProjectProvider>();
    final next = provider.nextCalculatorKey(currentKey);
    if (next == null) {
      // Last calculator → save and go to estimate
      provider.saveProject().then((_) => provider.loadProjectsFromDb());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CompleteEstimateScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screenFor(next)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectProvider>();
    final calcs = provider.selectedCalculators;
    if (calcs.isEmpty) {
      return const CompleteEstimateScreen();
    }
    return screenFor(calcs.first);
  }
}