import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../models/project_model.dart';
import '../../utils/app_constants.dart';
import 'select_room_screen.dart';

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

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCity = 'Lahore, Pakistan';
  String _selectedPropertyType = 'gv';

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project name')),
      );
      return;
    }
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    final updated = ProjectModel(
      id: current.id,
      name: _nameController.text.trim(),
      city: _selectedCity,
      propertyType: _selectedPropertyType,
      projectArea: double.tryParse(_areaController.text),
      description: _descController.text.trim(),
      selectedRoom: current.selectedRoom,
      roomLength: current.roomLength,
      roomWidth: current.roomWidth,
      roomHeight: current.roomHeight,
      unit: current.unit,
      createdAt: current.createdAt,
      flooringCost: current.flooringCost,
      paintCost: current.paintCost,
      tilesCost: current.tilesCost,
      ceilingCost: current.ceilingCost,
      doorsWindowsCost: current.doorsWindowsCost,
      furnitureCost: current.furnitureCost,
      electricalCost: current.electricalCost,
      plumbingCost: current.plumbingCost,
      selectedFlooringMaterial: current.selectedFlooringMaterial,
      flooringWastage: current.flooringWastage,
      paintWallHeight: current.paintWallHeight,
      paintType: current.paintType,
      paintCoats: current.paintCoats,
      paintCoverage: current.paintCoverage,
      tilesType: current.tilesType,
      tileSize: current.tileSize,
      tilesWastage: current.tilesWastage,
      tilePrice: current.tilePrice,
      ceilingType: current.ceilingType,
      ceilingRatePerSqFt: current.ceilingRatePerSqFt,
      mainDoors: current.mainDoors,
      roomDoors: current.roomDoors,
      bathroomDoors: current.bathroomDoors,
      windows: current.windows,
      ventilators: current.ventilators,
      furnitureItems: Map.from(current.furnitureItems),
      selectedCalculators: current.selectedCalculators,
    );
    provider.updateCurrentProject(updated);
    provider.setProjectStep(2);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectRoomScreen()));
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
          'New Project',
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
                // Step progress in a glass container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: _PureGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Basic Info', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('Step 1 of 4', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.25,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            color: Colors.white,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Name Field
                        const Text('Project Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 8),
                        _PureGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: TextFormField(
                            controller: _nameController,
                            cursorColor: Colors.white,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Living Room Renovation',
                              hintStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.normal),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // City dropdown
                        const Text('Select City', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 8),
                        _PureGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: DropdownButtonFormField<String>(
                            value: _selectedCity,
                            dropdownColor: const Color(0xFF2A2A35),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                              border: InputBorder.none,
                            ),
                            items: kPakistaniCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _selectedCity = v!),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Property type
                        const Text('Property Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 12),
                        Row(
                          children: kPropertyTypes.map((type) {
                            final isSelected = type == _selectedPropertyType;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedPropertyType = type),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Project Area
                        const Text('Project Area (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 8),
                        _PureGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: TextFormField(
                            controller: _areaController,
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.white,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: '180',
                              hintStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.normal),
                              suffixText: 'sq ft',
                              suffixStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Project Description
                        const Text('Project Description (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 8),
                        _PureGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            cursorColor: Colors.white,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Add notes about your project...',
                              hintStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.normal),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Next Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: _PureGlassCard(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}