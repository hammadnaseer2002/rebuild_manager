import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rates_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../utils/app_constants.dart';
import 'project_report_screen.dart';
class _PureGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isHighlight;
  const _PureGlassCard({
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.isHighlight = false,
  });
  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);

    Widget content = Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isHighlight
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}
class _ZenBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/b.jpg',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Main Screen ────────────────────────────────────────────────────────────

class CompleteEstimateScreen extends StatelessWidget {
  const CompleteEstimateScreen({super.key});

  // All possible calculator items — keyed by calculator key
  static const Map<String, Map<String, dynamic>> _allItems = {
    'flooring':      {'icon': Icons.grid_on,            'label': 'Flooring',            'color': Color(0xFF8B6914)},
    'paint':         {'icon': Icons.format_paint,        'label': 'Paint',               'color': Color(0xFF1565C0)},
    'tiles':         {'icon': Icons.view_module,         'label': 'Tiles',               'color': Color(0xFF4A148C)},
    'ceiling':       {'icon': Icons.workspaces,          'label': 'Ceiling',             'color': Color(0xFF1B5E3B)},
    'doors_windows': {'icon': Icons.door_front_door,     'label': 'Doors & Windows',     'color': Color(0xFF37474F)},
    'furniture':     {'icon': Icons.weekend,             'label': 'Furniture & Fixtures','color': Color(0xFF6A1B9A)},
    'electrical':    {'icon': Icons.electrical_services, 'label': 'Electrical',          'color': Color(0xFFE65100)},
    'plumbing':      {'icon': Icons.plumbing,            'label': 'Plumbing',            'color': Color(0xFF01579B)},
  };

  double _costForKey(String key, project) {
    switch (key) {
      case 'flooring':      return project.flooringCost;
      case 'paint':         return project.paintCost;
      case 'tiles':         return project.tilesCost;
      case 'ceiling':       return project.ceilingCost;
      case 'doors_windows': return project.doorsWindowsCost;
      case 'furniture':     return project.furnitureCost;
      case 'electrical':    return project.electricalCost;
      case 'plumbing':      return project.plumbingCost;
      default:              return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final project = provider.currentProject;
        if (project == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Text('No project', style: TextStyle(color: Colors.white))),
          );
        }

        // Only show calculators the user selected, in their chosen order
        final selectedKeys = project.selectedCalculators;
        final items = selectedKeys
            .where((k) => _allItems.containsKey(k))
            .map((k) => {
          'key': k,
          'icon': _allItems[k]!['icon'],
          'label': _allItems[k]!['label'],
          'color': _allItems[k]!['color'],
          'amount': _costForKey(k, project),
        })
            .toList();

        // Total = sum of only the selected calculators
        final total = items.fold<double>(
            0, (sum, item) => sum + (item['amount'] as double));

        return Scaffold(
          extendBodyBehindAppBar: true, // Transparent AppBar lets background show through
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Complete Estimate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: Stack(
            children: [
              _ZenBackground(),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        children: [
                          ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PureGlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  // Colored Glass Icon Box
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: (item['color'] as Color).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: (item['color'] as Color).withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      item['icon'] as IconData,
                                      color: Colors.white, // White icons look best on dark glass
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      item['label'] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${Provider.of<RatesProvider>(context).currencySymbol} ${_fmt(item['amount'] as double)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),

                    // Total + Action button Container at the bottom
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: _PureGlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Estimated Cost',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '${Provider.of<RatesProvider>(context).currencySymbol} ${_fmt(total)}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Glass Button for View Report
                            _PureGlassCard(
                              isHighlight: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProjectReportScreen(),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              width: double.infinity,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description_outlined, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'View Project Report',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}