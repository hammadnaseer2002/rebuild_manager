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
        // Serene photographic background
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
    );
  }
}

// ─── Main Screen ────────────────────────────────────────────────────────────

class FlooringCalculatorScreen extends StatefulWidget {
  const FlooringCalculatorScreen({super.key});

  @override
  State<FlooringCalculatorScreen> createState() =>
      _FlooringCalculatorScreenState();
}

class _FlooringCalculatorScreenState extends State<FlooringCalculatorScreen> {
  String _selectedMaterial = '';

  // کوئی پہلے سے ویلیو سیٹ نہیں کی گئی
  final _wastageController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _rateController = TextEditingController();

  double get _roomArea {
    final p = context.read<ProjectProvider>().currentProject;
    final isFromFlow = context.read<ProjectProvider>().newProjectStep >= 3;
    if (isFromFlow && p != null && p.roomLength > 0 && p.roomWidth > 0) {
      return p.roomArea;
    }
    final l = double.tryParse(_lengthController.text) ?? 0;
    final w = double.tryParse(_widthController.text) ?? 0;
    return l * w;
  }

  double get _wastage => double.tryParse(_wastageController.text) ?? 0;
  double get _areaWithWastage => _roomArea * (1 + _wastage / 100);
  double get _rate => double.tryParse(_rateController.text) ?? 0;
  double get _estimatedCost => _areaWithWastage * _rate;

  void _saveAndNext(BuildContext context) {
    final isFromFlow = context.read<ProjectProvider>().newProjectStep >= 3;

    // 1. Validation Check (Required Fields)
    if (!isFromFlow) {
      final l = double.tryParse(_lengthController.text) ?? 0;
      final w = double.tryParse(_widthController.text) ?? 0;
      if (l <= 0 || w <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid room dimensions (Length & Width)')),
        );
        return;
      }
    }

    if (_selectedMaterial.isEmpty && _rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a material or enter a material rate')),
      );
      return;
    }

    // 2. Save and proceed
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    final updated = _updateProject(current);
    provider.updateCurrentProject(updated);
    provider.recalculateAll(context.read<RatesProvider>().rates);
    CalculatorFlowScreen.pushNext(context, 'flooring');
  }

  ProjectModel _updateProject(ProjectModel p) {
    return ProjectModel(
      id: p.id,
      name: p.name,
      city: p.city,
      propertyType: p.propertyType,
      projectArea: p.projectArea,
      description: p.description,
      selectedRoom: p.selectedRoom,
      roomLength: p.roomLength,
      roomWidth: p.roomWidth,
      roomHeight: p.roomHeight,
      unit: p.unit,
      createdAt: p.createdAt,
      flooringCost: _estimatedCost,
      paintCost: p.paintCost,
      tilesCost: p.tilesCost,
      ceilingCost: p.ceilingCost,
      doorsWindowsCost: p.doorsWindowsCost,
      furnitureCost: p.furnitureCost,
      electricalCost: p.electricalCost,
      plumbingCost: p.plumbingCost,
      selectedFlooringMaterial: _selectedMaterial.isEmpty ? 'Custom' : _selectedMaterial,
      flooringWastage: _wastage,
      paintWallHeight: p.paintWallHeight,
      paintType: p.paintType,
      paintCoats: p.paintCoats,
      paintCoverage: p.paintCoverage,
      tilesType: p.tilesType,
      tileSize: p.tileSize,
      tilesWastage: p.tilesWastage,
      tilePrice: p.tilePrice,
      ceilingType: p.ceilingType,
      ceilingRatePerSqFt: p.ceilingRatePerSqFt,
      mainDoors: p.mainDoors,
      roomDoors: p.roomDoors,
      bathroomDoors: p.bathroomDoors,
      windows: p.windows,
      ventilators: p.ventilators,
      furnitureItems: Map.from(p.furnitureItems),
      selectedCalculators: p.selectedCalculators,
    );
  }

  @override
  void dispose() {
    _wastageController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _rateController.dispose();
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
          'Flooring Calculator',
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Area Input (standalone) or display (from flow) ──
                        if (!isFromFlow) ...[
                          const Text(
                            'Room Dimensions',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _DimField(
                                  label: 'Length',
                                  hint: '0',
                                  controller: _lengthController,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _DimField(
                                  label: 'Width',
                                  hint: '0',
                                  controller: _widthController,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Floor area display
                        _InfoRow(
                          label: 'Floor Area',
                          value: '${_roomArea.toStringAsFixed(0)} sq ft',
                        ),
                        const SizedBox(height: 32),

                        // ── Material Selector ──
                        Row(
                          children: const [
                            Text(
                              'Select Flooring Material',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                          children: context
                              .read<RatesProvider>()
                              .rates
                              .flooringMaterials
                              .entries
                              .map((entry) {
                            final isSelected = _selectedMaterial == entry.key;
                            return _PureGlassCard(
                              onTap: () => setState(() {
                                _selectedMaterial = entry.key;
                                _rateController.text = entry.value.toStringAsFixed(0);
                              }),
                              isHighlight: isSelected,
                              padding: const EdgeInsets.all(8),
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _materialIcon(entry.key, isSelected),
                                  const SizedBox(height: 10),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${Provider.of<RatesProvider>(context).currencySymbol} ${entry.value.toStringAsFixed(0)} / sq ft',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),

                        // ── Wastage Input ──
                        _EditableRow(
                          label: 'Wastage',
                          controller: _wastageController,
                          hint: '0',
                          suffix: '%',
                          isRequired: false,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Total Area (with wastage)',
                          value: '${_areaWithWastage.toStringAsFixed(0)} sq ft',
                        ),
                        const SizedBox(height: 12),
                        _EditableRow(
                          label: 'Material Rate',
                          controller: _rateController,
                          hint: '0',
                          prefix: '${Provider.of<RatesProvider>(context).currencySymbol} ',
                          suffix: '/ sq ft',
                          isRequired: true,
                          onChanged: (_) => setState(() {
                            _selectedMaterial = ''; // Reset selection if manually typing
                          }),
                        ),
                        const SizedBox(height: 40), // Extra spacing for scroll
                      ],
                    ),
                  ),
                ),

                // ── Bottom Total Bar & Action Button ──
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

  Widget _materialIcon(String material, bool isSelected) {
    final icons = {
      'Tiles': Icons.grid_on,
      'Marble': Icons.grain,
      'Vinyl': Icons.texture,
      'Wooden': Icons.forest,
      'Granite': Icons.landscape,
    };
    return Icon(
      icons[material] ?? Icons.grid_on,
      color: isSelected ? Colors.white : Colors.white70,
      size: 32,
    );
  }
}

// ── Shared Helper Widgets Re-styled for Pure Glassmorphism ───────────────────

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