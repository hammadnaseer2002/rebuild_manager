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

class FurnitureFixturesScreen extends StatefulWidget {
  const FurnitureFixturesScreen({super.key});

  @override
  State<FurnitureFixturesScreen> createState() => _FurnitureFixturesScreenState();
}

class _FurnitureFixturesScreenState extends State<FurnitureFixturesScreen> {
  late Map<String, int> _items;
  final Map<String, TextEditingController> _priceCtrls = {};

  @override
  void initState() {
    super.initState();
    final project = context.read<ProjectProvider>().currentProject;
    final rates = context.read<RatesProvider>().rates;

    // کوئی پہلے سے ویلیو سیٹ نہیں کی گئی (سب 0 ہوں گے)
    _items = Map.from(project?.furnitureItems ?? {
      'Sofa Set': 0,
      'TV Unit': 0,
      'Coffee Table': 0,
      'Curtains': 0,
      'Lights': 0,
    });

    final priceMap = rates.furniturePrices;
    for (final key in _items.keys) {
      // Pre-fill price from saved rates; empty if not found
      final savedPrice = priceMap[key];
      _priceCtrls[key] = TextEditingController(
        text: savedPrice != null ? savedPrice.toStringAsFixed(0) : '',
      );
    }
  }

  @override
  void dispose() {
    for (final ctrl in _priceCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  double _priceFor(String item) {
    final text = _priceCtrls[item]?.text ?? '';
    return double.tryParse(text) ?? 0;
  }

  double get _totalCost {
    double total = 0;
    _items.forEach((item, qty) {
      total += _priceFor(item) * qty;
    });
    return total;
  }

  IconData _iconFor(String item) {
    switch (item) {
      case 'Sofa Set': return Icons.weekend;
      case 'TV Unit': return Icons.tv;
      case 'Coffee Table': return Icons.table_restaurant;
      case 'Curtains': return Icons.curtains;
      case 'Lights': return Icons.lightbulb_outline;
      case 'Dining Table': return Icons.dining;
      case 'Bed': return Icons.bed;
      case 'Wardrobe': return Icons.door_sliding;
      default: return Icons.chair;
    }
  }

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
    CalculatorFlowScreen.pushNext(context, 'furniture');
  }

  ProjectModel _updateProject(ProjectModel p) {
    return ProjectModel(
      id: p.id, name: p.name, city: p.city, propertyType: p.propertyType,
      projectArea: p.projectArea, description: p.description,
      selectedRoom: p.selectedRoom, roomLength: p.roomLength, roomWidth: p.roomWidth,
      roomHeight: p.roomHeight, unit: p.unit, createdAt: p.createdAt,
      flooringCost: p.flooringCost, paintCost: p.paintCost,
      tilesCost: p.tilesCost, ceilingCost: p.ceilingCost,
      doorsWindowsCost: p.doorsWindowsCost, furnitureCost: _totalCost,
      electricalCost: p.electricalCost, plumbingCost: p.plumbingCost,
      selectedFlooringMaterial: p.selectedFlooringMaterial, flooringWastage: p.flooringWastage,
      paintWallHeight: p.paintWallHeight, paintType: p.paintType,
      paintCoats: p.paintCoats, paintCoverage: p.paintCoverage,
      tilesType: p.tilesType, tileSize: p.tileSize, tilesWastage: p.tilesWastage,
      tilePrice: p.tilePrice, ceilingType: p.ceilingType,
      ceilingRatePerSqFt: p.ceilingRatePerSqFt,
      mainDoors: p.mainDoors, roomDoors: p.roomDoors, bathroomDoors: p.bathroomDoors,
      windows: p.windows, ventilators: p.ventilators,
      furnitureItems: Map.from(_items),
      selectedCalculators: p.selectedCalculators,
    );
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
          'Furniture & Fixtures',
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
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: _items.entries.map((entry) {
                      final itemTotal = _priceFor(entry.key) * entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PureGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Icon + Label & Total Cost
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _iconFor(entry.key),
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatCurrency(itemTotal)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
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
                                          color: Colors.black.withValues(alpha: 0.3), // Darker tint
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                        ),
                                        child: Row(
                                          children: [
                                            Text('${Provider.of<RatesProvider>(context).currencySymbol} ', style: TextStyle(fontSize: 14, color: Colors.white54)),
                                            SizedBox(
                                              width: 55,
                                              child: TextFormField(
                                                controller: _priceCtrls[entry.key],
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.right,
                                                onChanged: (_) => setState(() {}),
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
                                          onTap: () {
                                            if (entry.value > 0) {
                                              setState(() => _items[entry.key] = entry.value - 1);
                                            }
                                          },
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
                                            '${entry.value}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(() => _items[entry.key] = entry.value + 1),
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
                    }).toList(),
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${Provider.of<RatesProvider>(context).currencySymbol} ${_formatCurrency(_totalCost)}',
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
                              'View Complete Estimate',
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