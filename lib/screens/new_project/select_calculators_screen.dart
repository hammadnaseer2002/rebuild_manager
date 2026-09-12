import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../utils/app_constants.dart';
import 'calculator_flow_screen.dart';

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
  final bool useOwnBlur;

  const _PureGlassCard({
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.isHighlight = false,
    this.useOwnBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);

    Widget glassBody = Container(
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
    );

    if (useOwnBlur) {
      glassBody = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
        child: glassBody,
      );
    }

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
          child: glassBody,
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

class SelectCalculatorsScreen extends StatefulWidget {
  const SelectCalculatorsScreen({super.key});

  @override
  State<SelectCalculatorsScreen> createState() =>
      _SelectCalculatorsScreenState();
}

class _SelectCalculatorsScreenState extends State<SelectCalculatorsScreen> {
  final Set<String> _selected = {};

  bool get _canProceed => _selected.isNotEmpty;

  void _toggle(String key) {
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  void _selectAll() {
    setState(() {
      for (final c in kAllCalculators) {
        _selected.add(c['key'] as String);
      }
    });
  }

  void _clearAll() => setState(() => _selected.clear());

  void _onNext() {
    if (!_canProceed) return;
    final provider = context.read<ProjectProvider>();
    provider.setSelectedCalculators(_selected.toList());
    provider.setProjectStep(3);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalculatorFlowScreen()),
    );
  }

  // Safe Image Fetcher: یہ چیک کرے گا کہ اگر app_constants میں امیج نہیں ہے تو یہ خود دے دے گا
  String _getSafeImagePath(Map<String, dynamic> calc) {
    if (calc.containsKey('imagePath') && calc['imagePath'] != null) {
      return calc['imagePath'] as String;
    }
    // Fallback images based on calculator key
    switch (calc['key']) {
      case 'flooring': return 'assets/images/fl.png';
      case 'paint': return 'assets/images/p.png';
      case 'tiles': return 'assets/images/t.png';
      case 'ceiling': return 'assets/images/ce.png';
      case 'doors_windows': return 'assets/images/d.png';
      case 'electrical': return 'assets/images/e.png';
      case 'plumbing': return 'assets/images/w.png';
      case 'furniture': return 'assets/images/f.png';
      default: return 'assets/images/cr.png';
    }
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
          'Select Calculators',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selected.length == kAllCalculators.length
                ? _clearAll
                : _selectAll,
            child: Text(
              _selected.length == kAllCalculators.length
                  ? 'Clear All'
                  : 'Select All',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _ZenBackground(),

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
                // Step indicator in glass container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _PureGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Materials & Calculators', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('Step 3 of 4', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.75,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            color: Colors.white,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    _selected.isEmpty
                        ? 'Select the work you want to estimate'
                        : '${_selected.length} calculator${_selected.length > 1 ? 's' : ''} selected — flow will run in order',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selected.isEmpty ? Colors.white70 : Colors.white,
                      fontWeight: _selected.isEmpty ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ),

                // Calculator grid list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: kAllCalculators.length,
                    itemBuilder: (_, i) {
                      final calc = kAllCalculators[i];
                      final key = calc['key'] as String;
                      final isSelected = _selected.contains(key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PureGlassCard(
                          onTap: () => _toggle(key),
                          isHighlight: isSelected,
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              // Image Box with Safe Fetcher
                              Container(
                                width: 50,
                                height: 50,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Image.asset(
                                  _getSafeImagePath(calc), // <-- یہ ایرر فکس ہے
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Text info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      calc['label'] as String,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      calc['description'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Glass Checkbox
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: isSelected ? 0.8 : 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Panel
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_selected.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SelectedOrderChips(
                            selected: _selected,
                            onRemove: (k) => _toggle(k),
                          ),
                        ),
                      _PureGlassCard(
                        isHighlight: _canProceed,
                        onTap: _canProceed ? _onNext : null,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            _canProceed
                                ? 'Start  (${_selected.length} calculator${_selected.length > 1 ? 's' : ''})'
                                : 'Select at least one calculator',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _canProceed ? Colors.white : Colors.white54,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
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

/// Shows selected calculators as small glass chips in canonical order.
class _SelectedOrderChips extends StatelessWidget {
  final Set<String> selected;
  final void Function(String) onRemove;

  const _SelectedOrderChips(
      {required this.selected, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final ordered = kAllCalculators
        .where((c) => selected.contains(c['key']))
        .toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ordered.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${i + 1}. ${c['label']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => onRemove(c['key'] as String),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (i < ordered.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_ios,
                      size: 10, color: Colors.white60),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}