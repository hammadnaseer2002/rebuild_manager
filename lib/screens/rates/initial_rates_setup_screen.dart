import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/rates_model.dart';
import '../../providers/rates_provider.dart';
import '../../screens/dashboard_screen.dart';

// ─── Glass helpers (local copy) ─────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const _GlassCard({required this.child, this.padding, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: radius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 14),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class InitialRatesSetupScreen extends StatefulWidget {
  /// If [isEdit] is true, the screen shows "Update Rates" header and
  /// "Save & Update" button instead of "Save & Continue".
  final bool isEdit;
  const InitialRatesSetupScreen({super.key, this.isEdit = false});

  @override
  State<InitialRatesSetupScreen> createState() =>
      _InitialRatesSetupScreenState();
}

class _InitialRatesSetupScreenState extends State<InitialRatesSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // ── Controllers ─────────────────────────────────────────────────────────

  // Flooring
  late final TextEditingController _flooringTilesCtrl;
  late final TextEditingController _flooringMarbleCtrl;
  late final TextEditingController _flooringVinylCtrl;
  late final TextEditingController _flooringWoodenCtrl;
  late final TextEditingController _flooringGraniteCtrl;

  // Paint
  late final TextEditingController _paintPerLiterCtrl;

  // Tiles
  late final TextEditingController _defaultTilePriceCtrl;

  // Ceiling
  late final TextEditingController _ceilingPlainCtrl;
  late final TextEditingController _ceilingGypsumCtrl;
  late final TextEditingController _ceilingPVCCtrl;
  late final TextEditingController _ceilingWoodenCtrl;

  // Doors
  late final TextEditingController _mainDoorCtrl;
  late final TextEditingController _roomDoorCtrl;
  late final TextEditingController _bathroomDoorCtrl;

  // Windows
  late final TextEditingController _windowCtrl;
  late final TextEditingController _ventilatorCtrl;

  // Furniture
  late final TextEditingController _sofaCtrl;
  late final TextEditingController _tvUnitCtrl;
  late final TextEditingController _coffeeTableCtrl;
  late final TextEditingController _curtainsCtrl;
  late final TextEditingController _lightsCtrl;
  late final TextEditingController _diningTableCtrl;
  late final TextEditingController _bedCtrl;
  late final TextEditingController _wardrobeCtrl;

  // Electrical
  late final TextEditingController _elecPointCtrl;
  late final TextEditingController _fanCtrl;
  late final TextEditingController _acPointCtrl;
  late final TextEditingController _socketCtrl;
  late final TextEditingController _elecLightCtrl;

  // Plumbing
  late final TextEditingController _washroomCtrl;
  late final TextEditingController _kitchenPlumbCtrl;
  late final TextEditingController _tankCtrl;
  late final TextEditingController _motorCtrl;
  late final TextEditingController _fixtureCtrl;

  // ── Init ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final r = context.read<RatesProvider>().rates;
    _flooringTilesCtrl = _ctrl(r.flooringTiles);
    _flooringMarbleCtrl = _ctrl(r.flooringMarble);
    _flooringVinylCtrl = _ctrl(r.flooringVinyl);
    _flooringWoodenCtrl = _ctrl(r.flooringWooden);
    _flooringGraniteCtrl = _ctrl(r.flooringGranite);
    _paintPerLiterCtrl = _ctrl(r.paintPricePerLiter);
    _defaultTilePriceCtrl = _ctrl(r.defaultTilePrice);
    _ceilingPlainCtrl = _ctrl(r.ceilingPlain);
    _ceilingGypsumCtrl = _ctrl(r.ceilingGypsum);
    _ceilingPVCCtrl = _ctrl(r.ceilingPVC);
    _ceilingWoodenCtrl = _ctrl(r.ceilingWooden);
    _mainDoorCtrl = _ctrl(r.mainDoorPrice);
    _roomDoorCtrl = _ctrl(r.roomDoorPrice);
    _bathroomDoorCtrl = _ctrl(r.bathroomDoorPrice);
    _windowCtrl = _ctrl(r.windowPrice);
    _ventilatorCtrl = _ctrl(r.ventilatorPrice);
    _sofaCtrl = _ctrl(r.sofaSetPrice);
    _tvUnitCtrl = _ctrl(r.tvUnitPrice);
    _coffeeTableCtrl = _ctrl(r.coffeeTablePrice);
    _curtainsCtrl = _ctrl(r.curtainsPrice);
    _lightsCtrl = _ctrl(r.lightsPrice);
    _diningTableCtrl = _ctrl(r.diningTablePrice);
    _bedCtrl = _ctrl(r.bedPrice);
    _wardrobeCtrl = _ctrl(r.wardrobePrice);
    _elecPointCtrl = _ctrl(r.electricalPointRate);
    _fanCtrl = _ctrl(r.fanRate);
    _acPointCtrl = _ctrl(r.acPointRate);
    _socketCtrl = _ctrl(r.socketRate);
    _elecLightCtrl = _ctrl(r.electricalLightRate);
    _washroomCtrl = _ctrl(r.washroomRate);
    _kitchenPlumbCtrl = _ctrl(r.kitchenPlumbingRate);
    _tankCtrl = _ctrl(r.waterTankRate);
    _motorCtrl = _ctrl(r.motorPumpRate);
    _fixtureCtrl = _ctrl(r.extraFixtureRate);
  }

  TextEditingController _ctrl(double value) {
    final isSetupDone = context.read<RatesProvider>().isSetupDone;
    if (!widget.isEdit && !isSetupDone) {
      return TextEditingController(text: '');
    }
    return TextEditingController(text: value.toStringAsFixed(0));
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _allControllers => [
    _flooringTilesCtrl,
    _flooringMarbleCtrl,
    _flooringVinylCtrl,
    _flooringWoodenCtrl,
    _flooringGraniteCtrl,
    _paintPerLiterCtrl,
    _defaultTilePriceCtrl,
    _ceilingPlainCtrl,
    _ceilingGypsumCtrl,
    _ceilingPVCCtrl,
    _ceilingWoodenCtrl,
    _mainDoorCtrl,
    _roomDoorCtrl,
    _bathroomDoorCtrl,
    _windowCtrl,
    _ventilatorCtrl,
    _sofaCtrl,
    _tvUnitCtrl,
    _coffeeTableCtrl,
    _curtainsCtrl,
    _lightsCtrl,
    _diningTableCtrl,
    _bedCtrl,
    _wardrobeCtrl,
    _elecPointCtrl,
    _fanCtrl,
    _acPointCtrl,
    _socketCtrl,
    _elecLightCtrl,
    _washroomCtrl,
    _kitchenPlumbCtrl,
    _tankCtrl,
    _motorCtrl,
    _fixtureCtrl,
  ];

  // ── Build rates model from form ──────────────────────────────────────────

  double _val(TextEditingController c, double fallback) =>
      double.tryParse(c.text.trim()) ?? fallback;

  RatesModel _buildRates() {
    final d = RatesModel.zero(); // defaults for fallback
    return RatesModel(
      flooringTiles: _val(_flooringTilesCtrl, d.flooringTiles),
      flooringMarble: _val(_flooringMarbleCtrl, d.flooringMarble),
      flooringVinyl: _val(_flooringVinylCtrl, d.flooringVinyl),
      flooringWooden: _val(_flooringWoodenCtrl, d.flooringWooden),
      flooringGranite: _val(_flooringGraniteCtrl, d.flooringGranite),
      paintPricePerLiter: _val(_paintPerLiterCtrl, d.paintPricePerLiter),
      defaultTilePrice: _val(_defaultTilePriceCtrl, d.defaultTilePrice),
      ceilingPlain: _val(_ceilingPlainCtrl, d.ceilingPlain),
      ceilingGypsum: _val(_ceilingGypsumCtrl, d.ceilingGypsum),
      ceilingPVC: _val(_ceilingPVCCtrl, d.ceilingPVC),
      ceilingWooden: _val(_ceilingWoodenCtrl, d.ceilingWooden),
      mainDoorPrice: _val(_mainDoorCtrl, d.mainDoorPrice),
      roomDoorPrice: _val(_roomDoorCtrl, d.roomDoorPrice),
      bathroomDoorPrice: _val(_bathroomDoorCtrl, d.bathroomDoorPrice),
      windowPrice: _val(_windowCtrl, d.windowPrice),
      ventilatorPrice: _val(_ventilatorCtrl, d.ventilatorPrice),
      sofaSetPrice: _val(_sofaCtrl, d.sofaSetPrice),
      tvUnitPrice: _val(_tvUnitCtrl, d.tvUnitPrice),
      coffeeTablePrice: _val(_coffeeTableCtrl, d.coffeeTablePrice),
      curtainsPrice: _val(_curtainsCtrl, d.curtainsPrice),
      lightsPrice: _val(_lightsCtrl, d.lightsPrice),
      diningTablePrice: _val(_diningTableCtrl, d.diningTablePrice),
      bedPrice: _val(_bedCtrl, d.bedPrice),
      wardrobePrice: _val(_wardrobeCtrl, d.wardrobePrice),
      electricalPointRate: _val(_elecPointCtrl, d.electricalPointRate),
      fanRate: _val(_fanCtrl, d.fanRate),
      acPointRate: _val(_acPointCtrl, d.acPointRate),
      socketRate: _val(_socketCtrl, d.socketRate),
      electricalLightRate: _val(_elecLightCtrl, d.electricalLightRate),
      washroomRate: _val(_washroomCtrl, d.washroomRate),
      kitchenPlumbingRate: _val(_kitchenPlumbCtrl, d.kitchenPlumbingRate),
      waterTankRate: _val(_tankCtrl, d.waterTankRate),
      motorPumpRate: _val(_motorCtrl, d.motorPumpRate),
      extraFixtureRate: _val(_fixtureCtrl, d.extraFixtureRate),
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await context.read<RatesProvider>().saveRates(_buildRates());
    if (!mounted) return;
    setState(() => _saving = false);

    if (widget.isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rates updated successfully'),
          backgroundColor: Color(0xFF1B5E3B),
        ),
      );
    } else {
      // First-time setup done → go to dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: widget.isEdit
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Rate Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/b.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header (first-time only)
                  if (!widget.isEdit) _buildHeader(),

                  // Scrollable form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFlooringSection(),
                          _buildPaintSection(),
                          _buildTilesSection(),
                          _buildCeilingSection(),
                          _buildDoorsSection(),
                          _buildFurnitureSection(),
                          _buildElectricalSection(),
                          _buildPlumbingSection(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Save button
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            ' Welcome!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your current market rates once. All calculators will use these prices automatically — you can always update them later from the Rates tab.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Section builders ────────────────────────────────────────────────────

  Widget _buildFlooringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: '', title: 'Flooring  (Rs / sq ft)'),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _RateRow(label: 'Tiles', ctrl: _flooringTilesCtrl),
              _RateRow(label: 'Marble', ctrl: _flooringMarbleCtrl),
              _RateRow(label: 'Vinyl', ctrl: _flooringVinylCtrl),
              _RateRow(label: 'Wooden', ctrl: _flooringWoodenCtrl),
              _RateRow(
                label: 'Granite',
                ctrl: _flooringGraniteCtrl,
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaintSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: '', title: 'Paint  (Rs / litre)'),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: _RateRow(
            label: 'Paint price per litre',
            ctrl: _paintPerLiterCtrl,
            last: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: '', title: 'Tiles  (Rs / sq ft)'),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: _RateRow(
            label: 'Default tile price / sq ft',
            ctrl: _defaultTilePriceCtrl,
            last: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCeilingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: '', title: 'Ceiling  (Rs / sq ft)'),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _RateRow(label: 'Plain', ctrl: _ceilingPlainCtrl),
              _RateRow(
                label: 'False Ceiling (Gypsum)',
                ctrl: _ceilingGypsumCtrl,
              ),
              _RateRow(label: 'False Ceiling (PVC)', ctrl: _ceilingPVCCtrl),
              _RateRow(label: 'Wooden', ctrl: _ceilingWoodenCtrl, last: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: '', title: 'Doors & Windows  (Rs / unit)'),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _RateRow(label: 'Main Door', ctrl: _mainDoorCtrl),
              _RateRow(label: 'Room Door', ctrl: _roomDoorCtrl),
              _RateRow(label: 'Bathroom Door', ctrl: _bathroomDoorCtrl),
              _RateRow(label: 'Window', ctrl: _windowCtrl),
              _RateRow(label: 'Ventilator', ctrl: _ventilatorCtrl, last: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFurnitureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: '', title: 'Furniture  (Rs / unit)'),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _RateRow(label: 'Sofa Set', ctrl: _sofaCtrl),
              _RateRow(label: 'TV Unit', ctrl: _tvUnitCtrl),
              _RateRow(label: 'Coffee Table', ctrl: _coffeeTableCtrl),
              _RateRow(label: 'Curtains', ctrl: _curtainsCtrl),
              _RateRow(label: 'Lights', ctrl: _lightsCtrl),
              _RateRow(label: 'Dining Table', ctrl: _diningTableCtrl),
              _RateRow(label: 'Bed', ctrl: _bedCtrl),
              _RateRow(label: 'Wardrobe', ctrl: _wardrobeCtrl, last: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildElectricalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: '', title: 'Electrical  (Rs / unit)'),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _RateRow(label: 'Electrical Point', ctrl: _elecPointCtrl),
              _RateRow(label: 'Fan', ctrl: _fanCtrl),
              _RateRow(label: 'AC Point', ctrl: _acPointCtrl),
              _RateRow(label: 'Power Socket', ctrl: _socketCtrl),
              _RateRow(
                label: 'Light Fixture',
                ctrl: _elecLightCtrl,
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlumbingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: '', title: 'Plumbing  (Rs / unit)'),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _RateRow(label: 'Washroom (full)', ctrl: _washroomCtrl),
              _RateRow(label: 'Kitchen Plumbing', ctrl: _kitchenPlumbCtrl),
              _RateRow(label: 'Water Tank', ctrl: _tankCtrl),
              _RateRow(label: 'Motor / Pump', ctrl: _motorCtrl),
              _RateRow(label: 'Extra Fixture', ctrl: _fixtureCtrl, last: true),
            ],
          ),
        ),
      ],
    );
  }

  // ── Save Button ─────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: GestureDetector(
        onTap: _saving ? null : _save,
        child: _GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 18),
          borderRadius: BorderRadius.circular(50),
          child: Center(
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.isEdit
                        ? 'Save & Update Rates'
                        : 'Save & Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Rate Row Widget ─────────────────────────────────────────────────────────

class _RateRow extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool last;

  const _RateRow({required this.label, required this.ctrl, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Text(
                    '${Provider.of<RatesProvider>(context).currencySymbol} ',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: ctrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!last) ...[
          const SizedBox(height: 10),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
