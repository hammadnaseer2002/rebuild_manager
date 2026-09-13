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

class PaintCalculatorScreen extends StatefulWidget {
  const PaintCalculatorScreen({super.key});

  @override
  State<PaintCalculatorScreen> createState() => _PaintCalculatorScreenState();
}

class _PaintCalculatorScreenState extends State<PaintCalculatorScreen> {
  // کوئی پہلے سے ویلیو سیٹ نہیں کی گئی
  double _wallHeight = 0;
  String? _paintType; // Null so it forces user to select
  double _coats = 0;
  double _coverage = 0;
  double _paintRatePerLiter = 0;

  // Standalone room size inputs (empty)
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _wallHeightController = TextEditingController();
  final _coverageController = TextEditingController();
  final _rateController = TextEditingController();

  final List<String> _paintTypes = [
    'Emulsion Paint',
    'Enamel Paint',
    'Primer',
    'Texture Paint',
    'Weather Shield',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill paint rate from saved market rates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedRate = context.read<RatesProvider>().rates.paintPricePerLiter;
      setState(() {
        _paintRatePerLiter = savedRate;
        _rateController.text = savedRate.toStringAsFixed(0);
      });
    });
  }

  bool get _isFromFlow =>
      context.read<ProjectProvider>().newProjectStep >= 3;

  double get _roomLength {
    if (_isFromFlow) {
      return context.read<ProjectProvider>().currentProject?.roomLength ?? 0;
    }
    return double.tryParse(_lengthController.text) ?? 0;
  }

  double get _roomWidth {
    if (_isFromFlow) {
      return context.read<ProjectProvider>().currentProject?.roomWidth ?? 0;
    }
    return double.tryParse(_widthController.text) ?? 0;
  }

  double get _totalWallArea =>
      2 * (_roomLength + _roomWidth) * _wallHeight;

  double get _doorsWindowsArea => 60.0;

  double get _netPaintable {
    final area = _totalWallArea - _doorsWindowsArea;
    return area > 0 ? area : 0;
  }

  double get _litersNeeded => _coverage > 0 ? (_netPaintable / _coverage) * _coats : 0;
  double get _estimatedCost => _litersNeeded * _paintRatePerLiter;

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

    if (_wallHeight <= 0 || _paintType == null || _coverage <= 0 || _coats <= 0 || _paintRatePerLiter <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and select paint type')),
      );
      return;
    }

    // 2. Save and proceed
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    provider.updateCurrentProject(_updateProject(current));
    CalculatorFlowScreen.pushNext(context, 'paint');
  }

  ProjectModel _updateProject(ProjectModel p) {
    return ProjectModel(
      id: p.id, name: p.name, city: p.city, propertyType: p.propertyType,
      projectArea: p.projectArea, description: p.description,
      selectedRoom: p.selectedRoom, roomLength: p.roomLength,
      roomWidth: p.roomWidth, roomHeight: p.roomHeight,
      unit: p.unit, createdAt: p.createdAt,
      flooringCost: p.flooringCost, paintCost: _estimatedCost,
      tilesCost: p.tilesCost, ceilingCost: p.ceilingCost,
      doorsWindowsCost: p.doorsWindowsCost, furnitureCost: p.furnitureCost,
      electricalCost: p.electricalCost, plumbingCost: p.plumbingCost,
      selectedFlooringMaterial: p.selectedFlooringMaterial,
      flooringWastage: p.flooringWastage,
      paintWallHeight: _wallHeight, paintType: _paintType ?? 'Emulsion Paint',
      paintCoats: _coats, paintCoverage: _coverage,
      tilesType: p.tilesType, tileSize: p.tileSize,
      tilesWastage: p.tilesWastage, tilePrice: p.tilePrice,
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
    _wallHeightController.dispose();
    _coverageController.dispose();
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
          'Paint Calculator',
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
                        // ── Room size inputs (standalone only) ──
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

                        // ── Wall Height ──
                        _EditableRow(
                          label: 'Wall Height',
                          controller: _wallHeightController,
                          hint: '0',
                          suffix: 'ft',
                          isRequired: true,
                          onChanged: (v) => setState(() => _wallHeight = double.tryParse(v) ?? 0),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Total Wall Area', value: '${_totalWallArea.toStringAsFixed(0)} sq ft'),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Doors & Windows', value: '${_doorsWindowsArea.toStringAsFixed(0)} sq ft'),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Net Paintable Area', value: '${_netPaintable.toStringAsFixed(0)} sq ft'),
                        const SizedBox(height: 32),

                        // ── Paint Type ──
                        Row(
                          children: const [
                            Text(
                                'Paint Type',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)
                            ),
                            Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PureGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: DropdownButtonFormField<String>(
                            value: _paintType,
                            dropdownColor: const Color(0xFF2A2A35), // Dark solid color for dropdown menu
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            hint: const Text('Select Paint Type', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.normal)),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                              border: InputBorder.none,
                            ),
                            items: _paintTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setState(() => _paintType = v!),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Coverage & Coats ──
                        _EditableRow(
                          label: 'Coverage',
                          controller: _coverageController,
                          hint: '0',
                          suffix: 'sq ft / L',
                          isRequired: true,
                          onChanged: (v) => setState(() => _coverage = double.tryParse(v) ?? 0),
                        ),
                        const SizedBox(height: 12),

                        // Glass Coats Row
                        _PureGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Text('No. of Coats', style: TextStyle(fontSize: 14, color: Colors.white70)),
                                  Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3), // Darker tint
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () { if (_coats > 0) setState(() => _coats--); },
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
                                        '${_coats.toInt()}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _coats++),
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
                        ),
                        const SizedBox(height: 12),

                        // ── Paint Rate ──
                        _EditableRow(
                          label: 'Paint Rate',
                          controller: _rateController,
                          hint: '0',
                          prefix: '${Provider.of<RatesProvider>(context).currencySymbol} ',
                          suffix: '/ Liter',
                          isRequired: true,
                          onChanged: (v) => setState(() => _paintRatePerLiter = double.tryParse(v) ?? 0),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Paint Required', value: '${_litersNeeded.toStringAsFixed(2)} Liters'),
                        const SizedBox(height: 40),
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
}

// ── Shared Helpers Re-styled for Pure Glassmorphism ──────────────────────────

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