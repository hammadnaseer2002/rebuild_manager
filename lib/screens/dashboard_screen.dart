import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';
import '../utils/app_constants.dart';
import '../models/project_model.dart';
import 'new_project/new_project_screen.dart';
import 'calculators/flooring_calculator_screen.dart';
import 'calculators/paint_calculator_screen.dart';
import 'calculators/tiles_calculator_screen.dart';
import 'calculators/ceiling_calculator_screen.dart';
import 'calculators/doors_windows_screen.dart';
import 'calculators/project_report_screen.dart';
import 'calculators/electrical_calculator_screen.dart';
import 'calculators/plumbing_calculator_screen.dart';
import 'calculators/furniture_fixtures_screen.dart';
import 'rates/rates_tab.dart';
import '../providers/rates_provider.dart';

// --- Background Session Variable ---
final int _sessionBackgroundIndex = Random().nextInt(7) + 1;

// --- Pure Glassmorphism Helper Widgets ---

/// Extremely blurred, highly translucent card mimicking the reference image
class _PureGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isHighlight;

  final bool useOwnBlur;

  const _PureGlassCard({
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.isHighlight = false,
    this.useOwnBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(28);

    Widget glassBody = Container(
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
    );

    if (useOwnBlur) {
      glassBody = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
        child: glassBody,
      );
    }

    Widget content = RepaintBoundary(
      child: Container(
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
        child: ClipRRect(borderRadius: radius, child: glassBody),
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

/// The serene photographic background
class _ZenBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/b$_sessionBackgroundIndex.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main Screen ────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _ZenBackground(),
          // FIX: ONE blur layer for the whole screen instead of one per
          // card. The background underneath is static (doesn't scroll),
          // so this filter never needs to react to scroll frames — it
          // just sits here painted once. All the cards on top are now
          // plain translucent boxes reading through this single blur.
          Positioned.fill(
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          _buildBody(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _DashboardTab(
          onIndexChange: (i) => setState(() => _currentIndex = i),
        );
      case 1:
        return _ProjectsTab();
      case 2:
        return const RatesTab();
      default:
        return _DashboardTab(
          onIndexChange: (i) => setState(() => _currentIndex = i),
        );
    }
  }

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.home, 'activeIcon': Icons.home_mini_sharp},
      {'icon': Icons.folder_open, 'activeIcon': Icons.folder},
      {'icon': Icons.price_change_outlined, 'activeIcon': Icons.price_change},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60, bottom: 4),
        child: _PureGlassCard(
          useOwnBlur: true,
          borderRadius: BorderRadius.circular(49),
          padding: const EdgeInsets.all(3),
          child: SizedBox(
            height: 35,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final segmentWidth = constraints.maxWidth / items.length;
                final indicatorWidth = segmentWidth * 0.85;
                final indicatorLeft =
                    _currentIndex * segmentWidth +
                    (segmentWidth - indicatorWidth) / 2;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      left: indicatorLeft,
                      top: 0,
                      width: indicatorWidth,
                      height: constraints.maxHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(items.length, (i) {
                        final isActive = _currentIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _currentIndex = i),
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: Icon(
                                isActive
                                    ? items[i]['activeIcon'] as IconData
                                    : items[i]['icon'] as IconData,
                                color: isActive ? Colors.white : Colors.white70,
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dashboard Tab ──────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final void Function(int) onIndexChange;
  const _DashboardTab({required this.onIndexChange});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildSummaryCard(context, provider),
                const SizedBox(height: 40),
                _buildQuickActions(context, provider),
                const SizedBox(height: 40),
                _buildRecentProjects(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage your projects',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, ProjectProvider provider) {
    return Column(
      children: [
        _PureGlassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Projects',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0${provider.projects.length}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              _PureGlassCard(
                isHighlight: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                borderRadius: BorderRadius.circular(20),
                onTap: () => onIndexChange(1),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _PureGlassCard(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Estimated Cost',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<RatesProvider>(
                builder: (context, ratesProvider, _) => Text(
                  '${ratesProvider.currencySymbol} ${_formatAmount(provider.totalEstimatedCost)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // FIX: push the new screen first, then run the provider update on a
  // microtask so the page-transition animation isn't competing with a
  // full dashboard rebuild on the same frame (that collision was the
  // "jhatka" on tap).
  void _openCalculator(
    BuildContext context,
    ProjectProvider provider,
    Widget screen,
  ) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    Future.microtask(() => provider.startNewProject());
  }

  Widget _buildQuickActions(BuildContext context, ProjectProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calculators',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: [
            _QuickActionCard(
              imagePath: 'assets/images/cr.png',
              label: 'New Project',
              subtitle: 'Start blank',
              onTap: () =>
                  _openCalculator(context, provider, const NewProjectScreen()),
            ),
            _QuickActionCard(
              imagePath: 'assets/images/fl.png',
              label: 'Flooring',
              subtitle: 'Tiles & Wood',
              onTap: () => _openCalculator(
                context,
                provider,
                const FlooringCalculatorScreen(),
              ),
            ),
            _QuickActionCard(
              imagePath: 'assets/images/p.png',
              label: 'Paint',
              subtitle: 'Walls & Roof',
              onTap: () => _openCalculator(
                context,
                provider,
                const PaintCalculatorScreen(),
              ),
            ),
            _QuickActionCard(
              imagePath: 'assets/images/t.png',
              label: 'Tiling',
              subtitle: 'Bath & Kitchen',
              onTap: () => _openCalculator(
                context,
                provider,
                const TilesCalculatorScreen(),
              ),
            ),
            _QuickActionCard(
              imagePath: 'assets/images/ce.png',
              label: 'Ceiling',
              subtitle: 'Plaster & Grid',
              onTap: () => _openCalculator(
                context,
                provider,
                const CeilingCalculatorScreen(),
              ),
            ),
            _QuickActionCard(
              imagePath: 'assets/images/d.png',
              label: 'Doors & Windows',
              subtitle: 'Wood & Glass',
              onTap: () => _openCalculator(
                context,
                provider,
                const DoorsWindowsScreen(),
              ),
            ),
            _QuickActionCard(
              imagePath: 'assets/images/e.png',
              label: 'Electrical',
              subtitle: 'Wiring & Lights',
              onTap: () => _openCalculator(
                context,
                provider,
                const ElectricalCalculatorScreen(),
              ),
            ),
            _QuickActionCard(
              imagePath: 'assets/images/w.png',
              label: 'Plumbing',
              subtitle: 'Pipes & Fittings',
              onTap: () => _openCalculator(
                context,
                provider,
                const PlumbingCalculatorScreen(),
              ),
            ),
            _QuickActionCard(
              imagePath: 'assets/images/f.png',
              label: 'Furniture',
              subtitle: 'Beds & Sofas',
              onTap: () => _openCalculator(
                context,
                provider,
                const FurnitureFixturesScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentProjects(BuildContext context, ProjectProvider provider) {
    if (provider.projects.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Projects',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        ...provider.projects.take(2).map((p) => _ProjectListItem(project: p)),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 1000).toStringAsFixed(0)},000';
    }
    return amount.toStringAsFixed(0);
  }
}

// ─── Re-designed Quick Action Card (Image + Bottom Text) ─────────────────────

class _QuickActionCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.imagePath,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PureGlassCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Project List Item ───────────────────────────────────────────────────────

class _ProjectListItem extends StatelessWidget {
  final ProjectModel project;
  const _ProjectListItem({required this.project});

  // FIX: same push-first, update-later pattern as the calculator cards.
  void _openReport(BuildContext context, ProjectProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProjectReportScreen()),
    );
    Future.microtask(() => provider.selectProject(project));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _PureGlassCard(
        borderRadius: BorderRadius.circular(24),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          onTap: () => _openReport(context, provider),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            project.name.isEmpty ? 'Unnamed Project' : project.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<RatesProvider>(
                  builder: (context, ratesProvider, _) => Text(
                    '${ratesProvider.currencySymbol} ${project.totalEstimatedCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            color: const Color(0xFF2A2A35),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) async {
              if (value == 'view') {
                _openReport(context, provider);
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF2A2A35),
                    title: const Text(
                      'Delete Project',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      'Are you sure you want to delete "${project.name.isEmpty ? 'this project' : project.name}"?',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deleteProject(project.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Project deleted')),
                    );
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'view',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text('View Report', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Projects Tab ────────────────────────────────────────────────────────────

class _ProjectsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (provider.projects.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No projects yet. Create one!',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.projects.length,
                      itemBuilder: (_, i) =>
                          _ProjectListItem(project: provider.projects[i]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
