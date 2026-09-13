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

class TilesCalculatorScreen extends StatefulWidget {
  const TilesCalculatorScreen({super.key});

  @override
  State<TilesCalculatorScreen> createState() => _TilesCalculatorScreenState();
}

class _TilesCalculatorScreenState extends State<TilesCalculatorScreen> {
  String _tilesType = 'floor';

  // کوئی پہلے سے ویلیو سیٹ نہیں کی گئی
  String? _tileSize;
  double _wastage = 0;
  double _tilePrice = 0;

  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _wastageController = TextEditingController();
  final _tilePriceController = TextEditingController();

  final List<String> _tileSizes = [
    '1 x 1 ft (12 x 12 inch)',
    '2 x 2 ft (24 x 24 inch)',
    '2 x 4 ft (24 x 48 inch)',
    '3 x 3 ft (36 x 36 inch)',
    '4 x 4 ft (48 x 48 inch)',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill default tile price from saved market rates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedRate = context.read<RatesProvider>().rates.defaultTilePrice;
      setState(() {
        _tilePrice = savedRate;
        _tilePriceController.text = savedRate.toStringAsFixed(0);
      });
    });
  }

  bool get _isFromFlow =>
      context.read<ProjectProvider>().newProjectStep >= 3;

  double get _roomArea {
    if (_isFromFlow) {
      return context.read<ProjectProvider>().currentProject?.roomArea ?? 0;
    }
    final l = double.tryParse(_lengthController.text) ?? 0;
    final w = double.tryParse(_widthController.text) ?? 0;
    return l * w;
  }

  double get _areaWithWastage => _roomArea * (1 + _wastage / 100);
  double get _estimatedCost => _areaWithWastage * _tilePrice;

  void _saveAndNext(BuildContext context) {
    // 1. Validation Check (Required Fields)
    if (!_isFromFlow) {
      final l = double.tryParse(_lengthController.text) ?? 0;
      final w = double.tryParse(_widthController.text) ?? 0;
      if (l <= 0 || w <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid room dimensions (Length & Width)')),
        );
        return;
      }
    }

    if (_tileSize == null || _tilePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tile size and enter the tile price')),
      );
      return;
    }

    // 2. Save and proceed
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    provider.updateCurrentProject(_updateProject(current));
    CalculatorFlowScreen.pushNext(context, 'tiles');
  }

  ProjectModel _updateProject(ProjectModel p) {
    return ProjectModel(
      id: p.id, name: p.name, city: p.city, propertyType: p.propertyType,
      projectArea: p.projectArea, description: p.description,
      selectedRoom: p.selectedRoom, roomLength: p.roomLength,
      roomWidth: p.roomWidth, roomHeight: p.roomHeight,
      unit: p.unit, createdAt: p.createdAt,
      flooringCost: p.flooringCost, paintCost: p.paintCost,
      tilesCost: _estimatedCost, ceilingCost: p.ceilingCost,
      doorsWindowsCost: p.doorsWindowsCost, furnitureCost: p.furnitureCost,
      electricalCost: p.electricalCost, plumbingCost: p.plumbingCost,
      selectedFlooringMaterial: p.selectedFlooringMaterial,
      flooringWastage: p.flooringWastage,
      paintWallHeight: p.paintWallHeight, paintType: p.paintType,
      paintCoats: p.paintCoats, paintCoverage: p.paintCoverage,
      tilesType: _tilesType, tileSize: _tileSize ?? 'Custom',
      tilesWastage: _wastage, tilePrice: _tilePrice,
      ceilingType: p.ceilingType, ceilingRatePerSqFt: p.ceilingRatePerSqFt,
      mainDoors: p.mainDoors, roomDoors: p.roomDoors,
      bathroomDoors: p.bathroomDoors, windows: p.windows,
      ventilators: p.ventilators,
      furnitureItems: Map.from(p.furnitureItems),
      selectedCalculators: p.selectedCalculators,
    );
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _wastageController.dispose();
    _tilePriceController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
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
          'Tiles Calculator',
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
                // Floor / Wall Tiles glass toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _PureGlassCard(
                    padding: const EdgeInsets.all(6),
                    borderRadius: BorderRadius.circular(30),
                    child: Row(
                      children: [
                        Expanded(child: _TabBtn(label: 'Floor Tiles', isActive: _tilesType == 'floor', onTap: () => setState(() => _tilesType = 'floor'))),
                        const SizedBox(width: 8),
                        Expanded(child: _TabBtn(label: 'Wall Tiles', isActive: _tilesType == 'wall', onTap: () => setState(() => _tilesType = 'wall'))),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        // Room size inputs (standalone)
                        if (!isFromFlow) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Room Dimensions',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _DimField(label: 'Length', hint: '0', controller: _lengthController, onChanged: (_) => setState(() {}))),
                              const SizedBox(width: 16),
                              Expanded(child: _DimField(label: 'Width', hint: '0', controller: _widthController, onChanged: (_) => setState(() {}))),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        _InfoRow(label: 'Floor Area', value: '${_roomArea.toStringAsFixed(0)} sq ft'),
                        const SizedBox(height: 24),

                        // Tile size Dropdown
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: const [
                              Text(
                                  'Tile Size',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)
                              ),
                              Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PureGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: DropdownButtonFormField<String>(
                            value: _tileSize,
                            dropdownColor: const Color(0xFF2A2A35),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            hint: const Text('Select Tile Size', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.normal)),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                              border: InputBorder.none,
                            ),
                            items: _tileSizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _tileSize = v),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Wastage (editable)
                        _EditableRow(
                          label: 'Wastage',
                          controller: _wastageController,
                          hint: '0',
                          suffix: '%',
                          isRequired: false,
                          onChanged: (v) => setState(() => _wastage = double.tryParse(v) ?? 0),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Total Tile Area', value: '${_areaWithWastage.toStringAsFixed(0)} sq ft'),
                        const SizedBox(height: 12),

                        // Tile price (editable)
                        _EditableRow(
                          label: 'Tile Price',
                          controller: _tilePriceController,
                          hint: '0',
                          prefix: '${Provider.of<RatesProvider>(context).currencySymbol} ',
                          suffix: '/ sq ft',
                          isRequired: true,
                          onChanged: (v) => setState(() => _tilePrice = double.tryParse(v) ?? 0),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom Total Bar & Action Button
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
                              '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatAmount(_estimatedCost)}',
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
                          onTap: () => _saveAndNext(context),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              'Next',
                              style: TextStyle(
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
}

// ── Shared Helpers Re-styled for Pure Glassmorphism ──────────────────────────

class _TabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isActive ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return _PureGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Input Row (Required and visually distinct)
class _EditableRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final String? prefix;
  final String? hint;
  final bool isRequired;
  final void Function(String) onChanged;

  const _EditableRow({
    required this.label,
    required this.controller,
    this.suffix,
    this.prefix,
    this.hint,
    this.isRequired = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _PureGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
                if (isRequired)
                  const Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
              ],
            ),
          ),
          // Distinct Input Background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3), // Darker tint for input field
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                if (prefix != null)
                  Text(
                    prefix!,
                    style: const TextStyle(fontSize: 15, color: Colors.white54),
                  ),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    onChanged: onChanged,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: hint ?? '0',
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (suffix != null)
                  Text(
                    ' $suffix',
                    style: const TextStyle(fontSize: 14, color: Colors.white54),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Dimensions Input (Required and visually distinct)
class _DimField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final void Function(String) onChanged;

  const _DimField({
    required this.label,
    this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],
          ),
        ),
        _PureGlassCard(
          padding: const EdgeInsets.all(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3), // Darker tint for input field
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: onChanged,
              cursorColor: Colors.white,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: hint ?? '0',
                hintStyle: const TextStyle(color: Colors.white38, fontWeight: FontWeight.normal),
                suffixText: 'ft',
                suffixStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}