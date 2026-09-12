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
          // Serene photographic background
          Image.asset(
            'assets/images/b.jpg',
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

class ElectricalCalculatorScreen extends StatefulWidget {
  const ElectricalCalculatorScreen({super.key});

  @override
  State<ElectricalCalculatorScreen> createState() =>
      _ElectricalCalculatorScreenState();
}

class _ElectricalCalculatorScreenState
    extends State<ElectricalCalculatorScreen> {
  // Quantities (پہلے سے 0 سیٹ ہیں)
  int _points = 0;
  int _fans = 0;
  int _acPoints = 0;
  int _sockets = 0;
  int _lights = 0;

  // User-editable unit rates (PKR)
  double _pointRate = 0;
  double _fanRate = 0;
  double _acPointRate = 0;
  double _socketRate = 0;
  double _lightRate = 0;

  final _pointRateCtrl = TextEditingController();
  final _fanRateCtrl = TextEditingController();
  final _acPointRateCtrl = TextEditingController();
  final _socketRateCtrl = TextEditingController();
  final _lightRateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final r = context.read<RatesProvider>().rates;
      setState(() {
        _pointRate    = r.electricalPointRate;
        _fanRate      = r.fanRate;
        _acPointRate  = r.acPointRate;
        _socketRate   = r.socketRate;
        _lightRate    = r.electricalLightRate;
        _pointRateCtrl.text   = r.electricalPointRate.toStringAsFixed(0);
        _fanRateCtrl.text     = r.fanRate.toStringAsFixed(0);
        _acPointRateCtrl.text = r.acPointRate.toStringAsFixed(0);
        _socketRateCtrl.text  = r.socketRate.toStringAsFixed(0);
        _lightRateCtrl.text   = r.electricalLightRate.toStringAsFixed(0);
      });
    });
  }

  double get _total =>
      (_points * _pointRate) +
          (_fans * _fanRate) +
          (_acPoints * _acPointRate) +
          (_sockets * _socketRate) +
          (_lights * _lightRate);

  void _saveAndNext() {
    // 1. Validation Check (Required Fields)
    if (_total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item and enter its rate')),
      );
      return;
    }

    // 2. Save and Proceed
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    final updated = _copyWith(current, electricalCost: _total);
    provider.updateCurrentProject(updated);
    CalculatorFlowScreen.pushNext(context, 'electrical');
  }

  ProjectModel _copyWith(ProjectModel p, {required double electricalCost}) {
    return ProjectModel(
      id: p.id, name: p.name, city: p.city, propertyType: p.propertyType,
      projectArea: p.projectArea, description: p.description,
      selectedRoom: p.selectedRoom, roomLength: p.roomLength,
      roomWidth: p.roomWidth, roomHeight: p.roomHeight,
      unit: p.unit, createdAt: p.createdAt,
      flooringCost: p.flooringCost, paintCost: p.paintCost,
      tilesCost: p.tilesCost, ceilingCost: p.ceilingCost,
      doorsWindowsCost: p.doorsWindowsCost, furnitureCost: p.furnitureCost,
      electricalCost: electricalCost, plumbingCost: p.plumbingCost,
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
    _pointRateCtrl.dispose();
    _fanRateCtrl.dispose();
    _acPointRateCtrl.dispose();
    _socketRateCtrl.dispose();
    _lightRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final isFromFlow = provider.newProjectStep >= 3 &&
        provider.isCalculatorSelected('electrical');
    final idx = provider.calcIndex('electrical');
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
              'Electrical',
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
          // SINGLE BLUR LAYER
          Positioned.fill(
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
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
                      _buildSection('⚡ Wiring Points'),
                      _ItemRow(
                        label: 'Electrical Points',
                        subtitle: 'Light / switch boards',
                        qty: _points,
                        rateCtrl: _pointRateCtrl,
                        total: _points * _pointRate,
                        onDec: () { if (_points > 0) setState(() => _points--); },
                        onInc: () => setState(() => _points++),
                        onRateChanged: (v) =>
                            setState(() => _pointRate = double.tryParse(v) ?? 0),
                      ),
                      _ItemRow(
                        label: 'Fans',
                        subtitle: 'Ceiling / exhaust fans',
                        qty: _fans,
                        rateCtrl: _fanRateCtrl,
                        total: _fans * _fanRate,
                        onDec: () { if (_fans > 0) setState(() => _fans--); },
                        onInc: () => setState(() => _fans++),
                        onRateChanged: (v) =>
                            setState(() => _fanRate = double.tryParse(v) ?? 0),
                      ),
                      _ItemRow(
                        label: 'AC Points',
                        subtitle: 'Dedicated AC sockets',
                        qty: _acPoints,
                        rateCtrl: _acPointRateCtrl,
                        total: _acPoints * _acPointRate,
                        onDec: () { if (_acPoints > 0) setState(() => _acPoints--); },
                        onInc: () => setState(() => _acPoints++),
                        onRateChanged: (v) =>
                            setState(() => _acPointRate = double.tryParse(v) ?? 0),
                      ),

                      const SizedBox(height: 24),

                      _buildSection('🔌 Outlets & Lighting'),
                      _ItemRow(
                        label: 'Power Sockets',
                        subtitle: '3-pin wall sockets',
                        qty: _sockets,
                        rateCtrl: _socketRateCtrl,
                        total: _sockets * _socketRate,
                        onDec: () { if (_sockets > 0) setState(() => _sockets--); },
                        onInc: () => setState(() => _sockets++),
                        onRateChanged: (v) =>
                            setState(() => _socketRate = double.tryParse(v) ?? 0),
                      ),
                      _ItemRow(
                        label: 'Light Fixtures',
                        subtitle: 'LED / CFL installation',
                        qty: _lights,
                        rateCtrl: _lightRateCtrl,
                        total: _lights * _lightRate,
                        onDec: () { if (_lights > 0) setState(() => _lights--); },
                        onInc: () => setState(() => _lights++),
                        onRateChanged: (v) =>
                            setState(() => _lightRate = double.tryParse(v) ?? 0),
                      ),
                      const SizedBox(height: 40), // Extra spacing at bottom
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
                              provider.isLastCalculator('electrical')
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
    final idx = provider.calcIndex('electrical');
    final total = provider.totalSelectedCalcs;
    return LinearProgressIndicator(
      value: idx / total,
      backgroundColor: Colors.white.withValues(alpha: 0.2), // Adjusted for dark background
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

                // Glass-styled Quantity Selector (Replaces external widget)
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