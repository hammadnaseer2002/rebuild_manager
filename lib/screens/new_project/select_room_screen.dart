import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../models/project_model.dart';
import '../../utils/app_constants.dart';
import 'room_dimensions_screen.dart';

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

class SelectRoomScreen extends StatefulWidget {
  const SelectRoomScreen({super.key});

  @override
  State<SelectRoomScreen> createState() => _SelectRoomScreenState();
}

class _SelectRoomScreenState extends State<SelectRoomScreen> {
  String _selectedRoom = 'Living Room';

  @override
  void initState() {
    super.initState();
    final project = context.read<ProjectProvider>().currentProject;
    if (project != null) {
      _selectedRoom = project.selectedRoom;
    }
  }

  void _onNext() {
    final provider = context.read<ProjectProvider>();
    final current = provider.currentProject!;
    final updated = _copyWith(current, selectedRoom: _selectedRoom);
    provider.updateCurrentProject(updated);
    provider.setProjectStep(2);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomDimensionsScreen()));
  }

  ProjectModel _copyWith(ProjectModel p, {String? selectedRoom}) {
    return ProjectModel(
      id: p.id,
      name: p.name,
      city: p.city,
      propertyType: p.propertyType,
      projectArea: p.projectArea,
      description: p.description,
      selectedRoom: selectedRoom ?? p.selectedRoom,
      roomLength: p.roomLength,
      roomWidth: p.roomWidth,
      roomHeight: p.roomHeight,
      unit: p.unit,
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Select Room',
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
                            Text('Rooms', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('Step 2 of 4', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.50,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.3,
                            children: kRooms.map((room) {
                              final isSelected = _selectedRoom == room['name'];
                              return _PureGlassCard(
                                onTap: () => setState(() => _selectedRoom = room['name'] as String),
                                isHighlight: isSelected,
                                borderRadius: BorderRadius.circular(22),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Icon(
                                        room['icon'] as IconData,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      room['name'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

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
}