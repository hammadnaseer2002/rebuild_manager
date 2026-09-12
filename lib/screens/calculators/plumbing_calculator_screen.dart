import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../providers/rates_provider.dart';
import '../../models/project_model.dart';
import '../../utils/app_constants.dart';
import '../new_project/calculator_flow_screen.dart';

// --- Pure Glassmorphism Helper Widgets ---

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
        child: ClipRRect(
          borderRadius: radius,
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
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/b.jpg', // Ensure you still have a background image named b.jpg
            fit: BoxFit.cover,
          ),
          // Subtle dark gradient overlay for text readability
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
      ),
    );
  }
}

// ─── Main Screen ────────────────────────────────────────────────────────────

class PlumbingCalculatorScreen extends StatefulWidget {
  const PlumbingCalculatorScreen({super.key});

  @override
  State<PlumbingCalculatorScreen> createState() =>
      _PlumbingCalculatorScreenState();
}

class _PlumbingCalculatorScreenState extends State<PlumbingCalculatorScreen> {
  // کوئی پہلے سے ویلیو سیٹ نہیں کی گئی (سب 0 ہوں گے)
  int _washrooms = 0;
  int _kitchens = 0;
  int _waterTanks = 0;
  int _motorPumps = 0;
  int _extraFixtures = 0;

  double _washroomRate = 0;
  double _kitchenRate = 0;
  double _tankRate = 0;
  double _motorRate = 0;
  double _fixtureRate = 0;

  // فیلڈز بھی خالی شروع ہوں گے
  final _washroomRateCtrl = TextEditingController();
  final _kitchenRateCtrl = TextEditingController();
  final _tankRateCtrl = TextEditingController();
  final _motorRateCtrl = TextEditingController();
  final _fixtureRateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final r = context.read<RatesProvider>().rates;
      setState(() {
        _washroomRate = r.washroomRate;
        _kitchenRate  = r.kitchenPlumbingRate;
        _tankRate     = r.waterTankRate;
        _motorRate    = r.motorPumpRate;
        _fixtureRate  = r.extraFixtureRate;
        _washroomRateCtrl.text = r.washroomRate.toStringAsFixed(0);
        _kitchenRateCtrl.text  = r.kitchenPlumbingRate.toStringAsFixed(0);
        _tankRateCtrl.text     = r.waterTankRate.toStringAsFixed(0);
        _motorRateCtrl.text    = r.motorPumpRate.toStringAsFixed(0);
        _fixtureRateCtrl.text  = r.extraFixtureRate.toStringAsFixed(0);
      });
    });
  }

  double get _total =>
      (_washrooms * _washroomRate) +
          (_kitchens * _kitchenRate) +
          (_waterTanks * _tankRate) +
          (_motorPumps * _motorRate) +
          (_extraFixtures * _fixtureRate);

  void _saveAndNext() {
    // 1. Validation Check (Required Fields)
    if (_total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item and enter its rate')),
      );
      return;
    }

    // 2. Save and proceed
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    final updated = _copyWith(current, plumbingCost: _total);
    provider.updateCurrentProject(updated);
    CalculatorFlowScreen.pushNext(context, 'plumbing');
  }

  ProjectModel _copyWith(ProjectModel p, {required double plumbingCost}) {
    return ProjectModel(
      id: p.id, name: p.name, city: p.city, propertyType: p.propertyType,
      projectArea: p.projectArea, description: p.description,
      selectedRoom: p.selectedRoom, roomLength: p.roomLength,
      roomWidth: p.roomWidth, roomHeight: p.roomHeight,
      unit: p.unit, createdAt: p.createdAt,
      flooringCost: p.flooringCost, paintCost: p.paintCost,
      tilesCost: p.tilesCost, ceilingCost: p.ceilingCost,
      doorsWindowsCost: p.doorsWindowsCost, furnitureCost: p.furnitureCost,
      electricalCost: p.electricalCost, plumbingCost: plumbingCost,
      selectedFlooringMaterial: p.selectedFlooringMaterial,
      flooringWastage: p.flooringWastage, paintWallHeight: p.paintWallHeight,
      paintType: p.paintType, paintCoats: p.paintCoats,
      paintCoverage: p.paintCoverage, tilesType: p.tilesType,
      tileSize: p.tileSize, tilesWastage: p.tilesWastage,
      tilePrice: p.tilePrice, ceilingType: p.ceilingType,
      ceilingRatePerSqFt: p.ceilingRatePerSqFt, mainDoors: p.mainDoors,
      roomDoors: p.roomDoors, bathroomDoors: p.bathroomDoors,
      windows: p.windows, ventilators: p.ventilators,
      furnitureItems: Map.from(p.furnitureItems),
      selectedCalculators: p.selectedCalculators,
    );
  }

  @override
  void dispose() {
    _washroomRateCtrl.dispose();
    _kitchenRateCtrl.dispose();
    _tankRateCtrl.dispose();
    _motorRateCtrl.dispose();
    _fixtureRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final isFromFlow = provider.newProjectStep >= 3 &&
        provider.isCalculatorSelected('plumbing');
    final idx = provider.calcIndex('plumbing');
    final total = provider.totalSelectedCalcs;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          children: [
            const Text(
              'Plumbing',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            if (isFromFlow)
              Text(
                'Step $idx of $total',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _ZenBackground(),

          // SINGLE BLUR LAYER FOR THE WHOLE SCREEN
          Positioned.fill(
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                if (isFromFlow) _buildProgressBar(provider),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
                      _buildSection('🚿 Wet Areas'),
                      _ItemRow(
                        label: 'Washrooms',
                        subtitle: 'Full plumbing per washroom',
                        qty: _washrooms,
                        rateCtrl: _washroomRateCtrl,
                        total: _washrooms * _washroomRate,
                        onDec: () { if (_washrooms > 0) setState(() => _washrooms--); },
                        onInc: () => setState(() => _washrooms++),
                        onRateChanged: (v) =>
                            setState(() => _washroomRate = double.tryParse(v) ?? 0),
                      ),
                      _ItemRow(
                        label: 'Kitchens',
                        subtitle: 'Sink + pipe connections',
                        qty: _kitchens,
                        rateCtrl: _kitchenRateCtrl,
                        total: _kitchens * _kitchenRate,
                        onDec: () { if (_kitchens > 0) setState(() => _kitchens--); },
                        onInc: () => setState(() => _kitchens++),
                        onRateChanged: (v) =>
                            setState(() => _kitchenRate = double.tryParse(v) ?? 0),
                      ),

                      const SizedBox(height: 24),

                      _buildSection('💧 Water Supply'),
                      _ItemRow(
                        label: 'Water Tanks',
                        subtitle: 'Overhead / underground',
                        qty: _waterTanks,
                        rateCtrl: _tankRateCtrl,
                        total: _waterTanks * _tankRate,
                        onDec: () { if (_waterTanks > 0) setState(() => _waterTanks--); },
                        onInc: () => setState(() => _waterTanks++),
                        onRateChanged: (v) =>
                            setState(() => _tankRate = double.tryParse(v) ?? 0),
                      ),
                      _ItemRow(
                        label: 'Motor / Pumps',
                        subtitle: 'Water pump installation',
                        qty: _motorPumps,
                        rateCtrl: _motorRateCtrl,
                        total: _motorPumps * _motorRate,
                        onDec: () { if (_motorPumps > 0) setState(() => _motorPumps--); },
                        onInc: () => setState(() => _motorPumps++),
                        onRateChanged: (v) =>
                            setState(() => _motorRate = double.tryParse(v) ?? 0),
                      ),
                      _ItemRow(
                        label: 'Extra Fixtures',
                        subtitle: 'Taps, fittings, etc.',
                        qty: _extraFixtures,
                        rateCtrl: _fixtureRateCtrl,
                        total: _extraFixtures * _fixtureRate,
                        onDec: () { if (_extraFixtures > 0) setState(() => _extraFixtures--); },
                        onInc: () => setState(() => _extraFixtures++),
                        onRateChanged: (v) =>
                            setState(() => _fixtureRate = double.tryParse(v) ?? 0),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Bottom Total and Action Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PureGlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimated Cost',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Rs ${_fmt(_total)}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isFromFlow) ...[
                        const SizedBox(height: 16),
                        _PureGlassCard(
                          isHighlight: true,
                          onTap: _saveAndNext,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              provider.isLastCalculator('plumbing')
                                  ? 'View Estimate'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16, left: 4),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
  );

  Widget _buildProgressBar(ProjectProvider provider) {
    final idx = provider.calcIndex('plumbing');
    final total = provider.totalSelectedCalcs;
    return LinearProgressIndicator(
      value: idx / total,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      color: Colors.white,
      minHeight: 3,
    );
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ─── Glassmorphism Item Row Component ────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final int qty;
  final TextEditingController rateCtrl;
  final double total;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final void Function(String) onRateChanged;

  const _ItemRow({
    required this.label,
    required this.subtitle,
    required this.qty,
    required this.rateCtrl,
    required this.total,
    required this.onDec,
    required this.onInc,
    required this.onRateChanged,
  });

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PureGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Label/Subtitle and Glass Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Glass-styled Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onDec,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Icon(Icons.remove, color: Colors.white, size: 16),
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 24),
                        alignment: Alignment.center,
                        child: Text(
                          '$qty',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onInc,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom Row: Unit Price Input and Total Cost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price Input Section
                Row(
                  children: [
                    const Text('Rate ', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    const Text('*', style: TextStyle(color: Colors.redAccent, fontSize: 14)), // Required Indicator
                    const SizedBox(width: 8),
                    // Distinct Input Background
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3), // Darker tint for input field
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Text('Rs ', style: TextStyle(fontSize: 14, color: Colors.white54)),
                          SizedBox(
                            width: 55,
                            child: TextFormField(
                              controller: rateCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              onChanged: onRateChanged,
                              cursorColor: Colors.white,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontWeight: FontWeight.normal,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Total for this item
                Text(
                  'Rs ${_fmt(total)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}