import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../providers/rates_provider.dart';
import '../../models/project_model.dart';
import '../../utils/app_constants.dart';
import 'select_calculators_screen.dart';

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

class RoomDimensionsScreen extends StatefulWidget {
  const RoomDimensionsScreen({super.key});

  @override
  State<RoomDimensionsScreen> createState() => _RoomDimensionsScreenState();
}

class _RoomDimensionsScreenState extends State<RoomDimensionsScreen> {
  // کوئی پہلے سے ویلیو سیٹ نہیں کی گئی
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  String _unit = 'ft';

  // ڈیفالٹ 0 ریٹرن کریں گے تاکہ ویلیڈیشن صحیح کام کرے
  double get _length => double.tryParse(_lengthController.text) ?? 0;
  double get _width => double.tryParse(_widthController.text) ?? 0;
  double get _height => double.tryParse(_heightController.text) ?? 0;
  double get _totalArea => _length * _width;

  void _onNext() {
    // 1. Validation Check (Required Fields)
    if (_length <= 0 || _width <= 0 || _height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid dimensions for Length, Width, and Height')),
      );
      return;
    }

    // 2. Save and proceed
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    final updated = _copyWith(
      current,
      roomLength: _length,
      roomWidth: _width,
      roomHeight: _height,
      unit: _unit,
    );
    provider.updateCurrentProject(updated);
    provider.recalculateAll(context.read<RatesProvider>().rates);
    provider.setProjectStep(3);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SelectCalculatorsScreen()));
  }

  ProjectModel _copyWith(ProjectModel p,
      {double? roomLength, double? roomWidth, double? roomHeight, String? unit}) {
    return ProjectModel(
      id: p.id,
      name: p.name,
      city: p.city,
      propertyType: p.propertyType,
      projectArea: p.projectArea,
      description: p.description,
      selectedRoom: p.selectedRoom,
      roomLength: roomLength ?? p.roomLength,
      roomWidth: roomWidth ?? p.roomWidth,
      roomHeight: roomHeight ?? p.roomHeight,
      unit: unit ?? p.unit,
      createdAt: p.createdAt,
      flooringCost: p.flooringCost,
      paintCost: p.paintCost,
      tilesCost: p.tilesCost,
      ceilingCost: p.ceilingCost,
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
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Room Dimensions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
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
                // Unit toggle inside a glass container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: _PureGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Unit', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: ['ft', 'in'].map((u) {
                              final isActive = _unit == u;
                              return GestureDetector(
                                onTap: () => setState(() => _unit = u),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    u,
                                    style: TextStyle(
                                      color: isActive ? Colors.white : Colors.white70,
                                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        // Room diagram
                        _buildRoomDiagram(),
                        const SizedBox(height: 12),

                        // Dimension inputs
                        _buildDimensionRow('Length', _lengthController),
                        const SizedBox(height: 12),
                        _buildDimensionRow('Width', _widthController),
                        const SizedBox(height: 12),
                        _buildDimensionRow('Height', _heightController),
                        const SizedBox(height: 32),

                        // Next Button
                        _PureGlassCard(
                          isHighlight: true,
                          onTap: _onNext,
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
                        const SizedBox(height: 16),

                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.help_outline, size: 16, color: Colors.white70),
                          label: const Text('How to measure?', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ),
                        const SizedBox(height: 20),
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
  }

  Widget _buildRoomDiagram() {
    return _PureGlassCard(
      height: 110,
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 130,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Length label (top)
          Positioned(
            top: 20,
            left: 10,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                const Text('Length (L)', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
              ],
            ),
          ),
          // Width label (right)
          Positioned(
            top: 10,
            bottom: 0,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward, size: 12, color: Colors.white),
                const SizedBox(height: 2),
                const RotatedBox(
                  quarterTurns: 1,
                  child: Text('Width (W)', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 2),
                const Icon(Icons.arrow_downward, size: 12, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionRow(String label, TextEditingController controller) {
    return _PureGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500)),
              const Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 15)), // Required Indicator
            ],
          ),
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
                SizedBox(
                  width: 50,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() {}),
                    cursorColor: Colors.white,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
                const SizedBox(width: 6),
                Text(_unit, style: const TextStyle(fontSize: 14, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}