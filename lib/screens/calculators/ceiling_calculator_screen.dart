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

class CeilingCalculatorScreen extends StatefulWidget {
  const CeilingCalculatorScreen({super.key});

  @override
  State<CeilingCalculatorScreen> createState() =>
      _CeilingCalculatorScreenState();
}

class _CeilingCalculatorScreenState extends State<CeilingCalculatorScreen> {
  // کوئی پہلے سے ویلیو سیٹ نہیں کی گئی
  String _ceilingType = '';
  double _ratePerSqFt = 0;

  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _rateController = TextEditingController();

  bool get _isFromFlow => context.read<ProjectProvider>().newProjectStep >= 3;

  double get _roomArea {
    if (_isFromFlow) {
      return context.read<ProjectProvider>().currentProject?.roomArea ?? 0;
    }
    final l = double.tryParse(_lengthController.text) ?? 0;
    final w = double.tryParse(_widthController.text) ?? 0;
    return l * w;
  }

  double get _estimatedCost => _roomArea * _ratePerSqFt;

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

    final rate = double.tryParse(_rateController.text) ?? 0;
    if (rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a ceiling type or enter a custom rate')),
      );
      return;
    }

    // 2. Save and proceed
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    provider.updateCurrentProject(_updateProject(current));
    CalculatorFlowScreen.pushNext(context, 'ceiling');
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
      flooringCost: p.flooringCost,
      paintCost: p.paintCost,
      tilesCost: p.tilesCost,
      ceilingCost: _estimatedCost,
      doorsWindowsCost: p.doorsWindowsCost,
      furnitureCost: p.furnitureCost,
      electricalCost: p.electricalCost,
      plumbingCost: p.plumbingCost,
      selectedFlooringMaterial: p.selectedFlooringMaterial,
      flooringWastage: p.flooringWastage,
      paintWallHeight: p.paintWallHeight,
      paintType: p.paintType,
      paintCoats: p.paintCoats,
      paintCoverage: p.paintCoverage,
      tilesType: p.tilesType,
      tileSize: p.tileSize,
      tilesWastage: p.tilesWastage,
      tilePrice: p.tilePrice,
      ceilingType: _ceilingType.isEmpty ? 'Custom' : _ceilingType,
      ceilingRatePerSqFt: _ratePerSqFt,
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
    _lengthController.dispose();
    _widthController.dispose();
    _rateController.dispose();
    super.dispose();
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
          'Ceiling Calculator',
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
                                  controller: _lengthController,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _DimField(
                                  label: 'Width',
                                  controller: _widthController,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Ceiling Type List
                        const Text(
                          'Ceiling Type',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...context
                              .read<RatesProvider>()
                              .rates
                              .ceilingTypes
                              .entries
                              .map((entry) {
                          final isSelected = _ceilingType == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PureGlassCard(
                              onTap: () => setState(() {
                                _ceilingType = entry.key;
                                _ratePerSqFt = entry.value;
                                _rateController.text = entry.value.toStringAsFixed(0);
                              }),
                              isHighlight: isSelected,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  // Glass Radio Button
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? Colors.white : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? Colors.transparent : Colors.white54,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, size: 16, color: Colors.black87)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${Provider.of<RatesProvider>(context).currencySymbol} ${entry.value.toStringAsFixed(0)}/sq ft',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 32),

                        // Editable rate override
                        _EditableRow(
                          label: 'Custom Rate (per sq ft)',
                          controller: _rateController,
                          prefix: '${Provider.of<RatesProvider>(context).currencySymbol} ',
                          onChanged: (v) => setState(() {
                            _ratePerSqFt = double.tryParse(v) ?? 0;
                            _ceilingType = ''; // Reset selection if manually typing
                          }),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          label: 'Total Ceiling Area',
                          value: '${_roomArea.toStringAsFixed(0)} sq ft',
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
                              'Estimated Cost',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${Provider.of<RatesProvider>(context).currencySymbol} ${_estimatedCost.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 28,
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

// ── Shared Helpers ──────────────────────────────────────────────────────────

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
  final void Function(String) onChanged;

  const _EditableRow({
    required this.label,
    required this.controller,
    this.suffix,
    this.prefix,
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
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
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
  final TextEditingController controller;
  final void Function(String) onChanged;

  const _DimField({
    required this.label,
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
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.normal,
                ),
                suffixText: 'ft',
                suffixStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}