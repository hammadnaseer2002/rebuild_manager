import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/rates_provider.dart';
import 'initial_rates_setup_screen.dart';
import '../privacy_policy_screen.dart';
import '../terms_conditions_screen.dart';

/// The 3rd tab in the bottom nav — shows saved rates, allows editing, currency formatting and legal info.
class RatesTab extends StatelessWidget {
  const RatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RatesProvider>(
      builder: (context, provider, _) {
        final rates = provider.rates;
        final curr = provider.currencySymbol;

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings & Rates',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage prices, currency and app info',
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 1. Rates Management Section
                _ExpandableSection(
                  title: 'Rates Management',
                  icon: Icons.monetization_on_outlined,
                  isInitiallyExpanded: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current market prices',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        _GlassChip(
                          label: '↺  Reset',
                          onTap: () => _confirmReset(context, provider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _EditButton(onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InitialRatesSetupScreen(isEdit: true),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    _RateGroup(
                      icon: '',
                      title: 'Flooring',
                      unit: 'per sq ft',
                      currency: curr,
                      items: {
                        'Tiles':   rates.flooringTiles,
                        'Marble':  rates.flooringMarble,
                        'Vinyl':   rates.flooringVinyl,
                        'Wooden':  rates.flooringWooden,
                        'Granite': rates.flooringGranite,
                      },
                    ),
                    const SizedBox(height: 12),
                    _RateGroup(
                      icon: '',
                      title: 'Paint',
                      unit: 'per litre',
                      currency: curr,
                      items: {'Paint': rates.paintPricePerLiter},
                    ),
                    const SizedBox(height: 12),
                    _RateGroup(
                      icon: '',
                      title: 'Tiles',
                      unit: 'per sq ft',
                      currency: curr,
                      items: {'Default tile price': rates.defaultTilePrice},
                    ),
                    const SizedBox(height: 12),
                    _RateGroup(
                      icon: '',
                      title: 'Ceiling',
                      unit: 'per sq ft',
                      currency: curr,
                      items: {
                        'Plain':                  rates.ceilingPlain,
                        'False Ceiling (Gypsum)': rates.ceilingGypsum,
                        'False Ceiling (PVC)':    rates.ceilingPVC,
                        'Wooden':                 rates.ceilingWooden,
                      },
                    ),
                    const SizedBox(height: 12),
                    _RateGroup(
                      icon: '',
                      title: 'Doors & Windows',
                      unit: 'per unit',
                      currency: curr,
                      items: {
                        'Main Door':     rates.mainDoorPrice,
                        'Room Door':     rates.roomDoorPrice,
                        'Bathroom Door': rates.bathroomDoorPrice,
                        'Window':        rates.windowPrice,
                        'Ventilator':    rates.ventilatorPrice,
                      },
                    ),
                    const SizedBox(height: 12),
                    _RateGroup(
                      icon: '',
                      title: 'Furniture',
                      unit: 'per unit',
                      currency: curr,
                      items: {
                        'Sofa Set':     rates.sofaSetPrice,
                        'TV Unit':      rates.tvUnitPrice,
                        'Coffee Table': rates.coffeeTablePrice,
                        'Curtains':     rates.curtainsPrice,
                        'Lights':       rates.lightsPrice,
                        'Dining Table': rates.diningTablePrice,
                        'Bed':          rates.bedPrice,
                        'Wardrobe':     rates.wardrobePrice,
                      },
                    ),
                    const SizedBox(height: 12),
                    _RateGroup(
                      icon: '',
                      title: 'Electrical',
                      unit: 'per unit',
                      currency: curr,
                      items: {
                        'Electrical Point': rates.electricalPointRate,
                        'Fan':              rates.fanRate,
                        'AC Point':         rates.acPointRate,
                        'Power Socket':     rates.socketRate,
                        'Light Fixture':    rates.electricalLightRate,
                      },
                    ),
                    const SizedBox(height: 12),
                    _RateGroup(
                      icon: '',
                      title: 'Plumbing',
                      unit: 'per unit',
                      currency: curr,
                      items: {
                        'Washroom (full)':  rates.washroomRate,
                        'Kitchen Plumbing': rates.kitchenPlumbingRate,
                        'Water Tank':       rates.waterTankRate,
                        'Motor / Pump':     rates.motorPumpRate,
                        'Extra Fixture':    rates.extraFixtureRate,
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 2. Currency Format Section
                _ExpandableSection(
                  title: 'Currency Format',
                  icon: Icons.currency_exchange_outlined,
                  children: [
                    const Text(
                      'Select your preferred currency symbol',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    _CurrencySelector(provider: provider),
                  ],
                ),
                
                const SizedBox(height: 16),

                // 3. Legal Section
                _ExpandableSection(
                  title: 'Legal',
                  icon: Icons.gavel_outlined,
                  children: [
                    _LegalButton(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _LegalButton(
                      title: 'Terms and Conditions',
                      icon: Icons.description_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsConditionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmReset(BuildContext context, RatesProvider provider) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset to Zero?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will restore all rates to zero.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Reset'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        await provider.resetToDefaults();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rates reset to zero'),
              backgroundColor: Color(0xFF1B5E3B),
            ),
          );
        }
      }
    });
  }
}

// ─── Glass Chip ──────────────────────────────────────────────────────────────

class _GlassChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GlassChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Edit Button ─────────────────────────────────────────────────────────────

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Edit All Rates',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main Expandable Section ───────────────────────────────────────────────────

class _ExpandableSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isInitiallyExpanded;

  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.children,
    this.isInitiallyExpanded = false,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ─── Currency Selector ───────────────────────────────────────────────────────

class _CurrencySelector extends StatelessWidget {
  final RatesProvider provider;

  const _CurrencySelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    const symbols = ['Rs', '\$', '€', '£', '₹'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: symbols.map((symbol) {
        final isSelected = provider.currencySymbol == symbol;
        return GestureDetector(
          onTap: () => provider.setCurrencySymbol(symbol),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              symbol,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Rate Group Card ─────────────────────────────────────────────────────────

class _RateGroup extends StatefulWidget {
  final String icon;
  final String title;
  final String unit;
  final Map<String, double> items;
  final String currency;

  const _RateGroup({
    required this.icon,
    required this.title,
    required this.unit,
    required this.items,
    required this.currency,
  });

  @override
  State<_RateGroup> createState() => _RateGroupState();
}

class _RateGroupState extends State<_RateGroup> {
  bool _isExpanded = false;

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final entries = widget.items.entries.toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  if (widget.icon.isNotEmpty) ...[
                    Text(widget.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.unit,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          
          // Rate rows
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                ...entries.asMap().entries.map((e) {
                  final isLast = e.key == entries.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.value.key,
                                style: const TextStyle(fontSize: 13, color: Colors.white70),
                              ),
                            ),
                            Text(
                              '${widget.currency} ${_fmt(e.value.value)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.07),
                            indent: 16, endIndent: 16),
                    ],
                  );
                }),
                const SizedBox(height: 4),
              ],
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ─── Legal Button ────────────────────────────────────────────────────────────

class _LegalButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _LegalButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
          ],
        ),
      ),
    );
  }
}
