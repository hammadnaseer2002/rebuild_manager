import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../providers/rates_provider.dart';
import '../../models/project_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
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
      ),
    );
  }
}

// ─── Main Screen ────────────────────────────────────────────────────────────

class DoorsWindowsScreen extends StatefulWidget {
  const DoorsWindowsScreen({super.key});

  @override
  State<DoorsWindowsScreen> createState() => _DoorsWindowsScreenState();
}

class _DoorsWindowsScreenState extends State<DoorsWindowsScreen> {
  // کوئی پہلے سے ویلیو سیٹ نہیں کی گئی
  int _mainDoors = 0;
  int _roomDoors = 0;
  int _bathroomDoors = 0;
  int _windows = 0;
  int _ventilators = 0;

  final _mainDoorPriceCtrl = TextEditingController();
  final _roomDoorPriceCtrl = TextEditingController();
  final _bathroomDoorPriceCtrl = TextEditingController();
  final _windowPriceCtrl = TextEditingController();
  final _ventilatorPriceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final r = context.read<RatesProvider>().rates;
      setState(() {
        _mainDoorPriceCtrl.text     = r.mainDoorPrice.toStringAsFixed(0);
        _roomDoorPriceCtrl.text     = r.roomDoorPrice.toStringAsFixed(0);
        _bathroomDoorPriceCtrl.text = r.bathroomDoorPrice.toStringAsFixed(0);
        _windowPriceCtrl.text       = r.windowPrice.toStringAsFixed(0);
        _ventilatorPriceCtrl.text   = r.ventilatorPrice.toStringAsFixed(0);
      });
    });
  }

  double get _mainDoorRate => double.tryParse(_mainDoorPriceCtrl.text) ?? 0;
  double get _roomDoorRate => double.tryParse(_roomDoorPriceCtrl.text) ?? 0;
  double get _bathroomDoorRate => double.tryParse(_bathroomDoorPriceCtrl.text) ?? 0;
  double get _windowRate => double.tryParse(_windowPriceCtrl.text) ?? 0;
  double get _ventilatorRate => double.tryParse(_ventilatorPriceCtrl.text) ?? 0;

  double get _mainDoorCost => _mainDoors * _mainDoorRate;
  double get _roomDoorCost => _roomDoors * _roomDoorRate;
  double get _bathroomDoorCost => _bathroomDoors * _bathroomDoorRate;
  double get _windowCost => _windows * _windowRate;
  double get _ventilatorCost => _ventilators * _ventilatorRate;

  double get _totalCost =>
      _mainDoorCost + _roomDoorCost + _bathroomDoorCost + _windowCost + _ventilatorCost;

  void _saveAndNext(BuildContext context) {
    // 1. Validation Check (Required Fields)
    if (_totalCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item and enter its rate')),
      );
      return;
    }

    // 2. Save and proceed
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    final updated = _updateProject(current);
    provider.updateCurrentProject(updated);
    CalculatorFlowScreen.pushNext(context, 'doors_windows');
  }

  ProjectModel _updateProject(ProjectModel p) {
    return ProjectModel(
      id: p.id, name: p.name, city: p.city, propertyType: p.propertyType,
      projectArea: p.projectArea, description: p.description,
      selectedRoom: p.selectedRoom, roomLength: p.roomLength, roomWidth: p.roomWidth,
      roomHeight: p.roomHeight, unit: p.unit, createdAt: p.createdAt,
      flooringCost: p.flooringCost, paintCost: p.paintCost,
      tilesCost: p.tilesCost, ceilingCost: p.ceilingCost,
      doorsWindowsCost: _totalCost, furnitureCost: p.furnitureCost,
      electricalCost: p.electricalCost, plumbingCost: p.plumbingCost,
      selectedFlooringMaterial: p.selectedFlooringMaterial, flooringWastage: p.flooringWastage,
      paintWallHeight: p.paintWallHeight, paintType: p.paintType,
      paintCoats: p.paintCoats, paintCoverage: p.paintCoverage,
      tilesType: p.tilesType, tileSize: p.tileSize, tilesWastage: p.tilesWastage,
      tilePrice: p.tilePrice, ceilingType: p.ceilingType,
      ceilingRatePerSqFt: p.ceilingRatePerSqFt,
      mainDoors: _mainDoors, roomDoors: _roomDoors, bathroomDoors: _bathroomDoors,
      windows: _windows, ventilators: _ventilators,
      furnitureItems: Map.from(p.furnitureItems),
      selectedCalculators: p.selectedCalculators,
    );
  }

  @override
  void dispose() {
    _mainDoorPriceCtrl.dispose();
    _roomDoorPriceCtrl.dispose();
    _bathroomDoorPriceCtrl.dispose();
    _windowPriceCtrl.dispose();
    _ventilatorPriceCtrl.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final isFromFlow = context.watch<ProjectProvider>().newProjectStep >= 3;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Doors & Windows',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 20, letterSpacing: 0.5),
        ),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doors Section
                        const Text(
                            'Doors',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)
                        ),
                        const SizedBox(height: 16),
                        _ItemRow(
                          label: 'Main Door',
                          priceController: _mainDoorPriceCtrl,
                          qty: _mainDoors,
                          total: '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatCurrency(_mainDoorCost)}',
                          onChanged: (_) => setState(() {}),
                          onDecrement: () { if (_mainDoors > 0) setState(() => _mainDoors--); },
                          onIncrement: () => setState(() => _mainDoors++),
                        ),
                        _ItemRow(
                          label: 'Room Doors',
                          priceController: _roomDoorPriceCtrl,
                          qty: _roomDoors,
                          total: '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatCurrency(_roomDoorCost)}',
                          onChanged: (_) => setState(() {}),
                          onDecrement: () { if (_roomDoors > 0) setState(() => _roomDoors--); },
                          onIncrement: () => setState(() => _roomDoors++),
                        ),
                        _ItemRow(
                          label: 'Bathroom Doors',
                          priceController: _bathroomDoorPriceCtrl,
                          qty: _bathroomDoors,
                          total: '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatCurrency(_bathroomDoorCost)}',
                          onChanged: (_) => setState(() {}),
                          onDecrement: () { if (_bathroomDoors > 0) setState(() => _bathroomDoors--); },
                          onIncrement: () => setState(() => _bathroomDoors++),
                        ),

                        const SizedBox(height: 24),

                        // Windows Section
                        const Text(
                            'Windows & Ventilators',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)
                        ),
                        const SizedBox(height: 16),
                        _ItemRow(
                          label: 'Windows',
                          priceController: _windowPriceCtrl,
                          qty: _windows,
                          total: '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatCurrency(_windowCost)}',
                          onChanged: (_) => setState(() {}),
                          onDecrement: () { if (_windows > 0) setState(() => _windows--); },
                          onIncrement: () => setState(() => _windows++),
                        ),
                        _ItemRow(
                          label: 'Ventilators',
                          priceController: _ventilatorPriceCtrl,
                          qty: _ventilators,
                          total: '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatCurrency(_ventilatorCost)}',
                          onChanged: (_) => setState(() {}),
                          onDecrement: () { if (_ventilators > 0) setState(() => _ventilators--); },
                          onIncrement: () => setState(() => _ventilators++),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Total and Next Button
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
                              'Total Cost',
                              style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatCurrency(_totalCost)}',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      if (isFromFlow) ...[
                        const SizedBox(height: 16),
                        _PureGlassCard(
                          isHighlight: true,
                          onTap: () => _saveAndNext(context),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              'Next',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
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
}

// ─── Glassmorphism Item Row Component ────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final String label;
  final TextEditingController priceController;
  final int qty;
  final String total;
  final ValueChanged<String> onChanged;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _ItemRow({
    required this.label,
    required this.priceController,
    required this.qty,
    required this.total,
    required this.onChanged,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PureGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Label and Total Cost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)
                ),
                Text(
                    total,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom Row: Unit Price Input and Glass Quantity Selector
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
                          Text('${Provider.of<RatesProvider>(context).currencySymbol} ', style: TextStyle(fontSize: 14, color: Colors.white54)),
                          SizedBox(
                            width: 55,
                            child: TextFormField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              onChanged: onChanged,
                              cursorColor: Colors.white,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
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
                        onTap: onDecrement,
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
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)
                        ),
                      ),
                      GestureDetector(
                        onTap: onIncrement,
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
          ],
        ),
      ),
    );
  }
}