import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rates_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../utils/pdf_report_service.dart';
import '../dashboard_screen.dart';
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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
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

class ProjectReportScreen extends StatefulWidget {
  const ProjectReportScreen({super.key});

  @override
  State<ProjectReportScreen> createState() => _ProjectReportScreenState();
}

class _ProjectReportScreenState extends State<ProjectReportScreen> {
  bool _generatingPdf = false;
  bool _sharingPdf = false;
  bool _isSaving = false; // Added to prevent double-taps on the Done button

  Future<void> _downloadPdf(BuildContext context) async {
    final project = context.read<ProjectProvider>().currentProject;
    if (project == null) return;

    setState(() => _generatingPdf = true);
    try {
      final currency = context.read<RatesProvider>().currencySymbol;
      final savePath = await PdfReportService.downloadPdf(project, currency);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'PDF Saved to Storage!\n$savePath',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1B5E3B),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    final project = context.read<ProjectProvider>().currentProject;
    if (project == null) return;

    setState(() => _sharingPdf = true);
    try {
      final currency = context.read<RatesProvider>().currencySymbol;
      await PdfReportService.sharePdf(project, currency);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sharingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final project = provider.currentProject;
        if (project == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Text('No project', style: TextStyle(color: Colors.white))),
          );
        }

        final date = '${project.createdAt.day} May ${project.createdAt.year}';

        // Map every possible calculator key to its label and cost
        const labelMap = {
          'flooring':      'Flooring',
          'paint':         'Paint',
          'tiles':         'Tiles',
          'ceiling':       'Ceiling',
          'doors_windows': 'Doors & Windows',
          'furniture':     'Furniture & Fixtures',
          'electrical':    'Electrical',
          'plumbing':      'Plumbing',
        };

        double costFor(String key) {
          switch (key) {
            case 'flooring':      return project.flooringCost;
            case 'paint':         return project.paintCost;
            case 'tiles':         return project.tilesCost;
            case 'ceiling':       return project.ceilingCost;
            case 'doors_windows': return project.doorsWindowsCost;
            case 'furniture':     return project.furnitureCost;
            case 'electrical':    return project.electricalCost;
            case 'plumbing':      return project.plumbingCost;
            default:              return 0;
          }
        }

        // Only rows for the calculators the user selected, in their order
        final items = project.selectedCalculators
            .where((k) => labelMap.containsKey(k))
            .map((k) => {'label': labelMap[k]!, 'amount': costFor(k)})
            .toList();

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Project Report',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              // Updated AppBar Share Button with loading indicator
              IconButton(
                icon: _sharingPdf
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.share_outlined),
                    ),
                onPressed: (_generatingPdf || _sharingPdf)
                    ? null
                    : () => _sharePdf(context),
              ),
            ],
          ),
          body: Stack(
            children: [
              _ZenBackground(),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: _PureGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Report Header ──────────────────────────────────
                              const Text(
                                'Renovation Cost Estimate Report',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(label: 'Project Name', value: project.name),
                              _InfoRow(label: 'Location', value: project.city),
                              _InfoRow(label: 'Room', value: project.selectedRoom),
                              _InfoRow(label: 'Date', value: date),
                              _InfoRow(
                                label: 'Dimensions',
                                value: '${project.roomLength} × ${project.roomWidth} × ${project.roomHeight} ${project.unit}  (${project.roomArea.toStringAsFixed(0)} sq ft)',
                              ),
                              const SizedBox(height: 20),
                              const Divider(color: Colors.white30),
                              const SizedBox(height: 12),

                              // ── Table Header ───────────────────────────────────
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Item',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'Estimated Cost (PKR)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // ── Cost Rows ──────────────────────────────────────
                              ...items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['label'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _fmt(item['amount'] as double),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                              const SizedBox(height: 12),
                              const Divider(color: Colors.white30),
                              const SizedBox(height: 12),

                              // Grand total row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Estimated Cost',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${Provider.of<RatesProvider>(context).currencySymbol} ${_fmt(project.totalEstimatedCost)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // ── Footer ─────────────────────────────────────────
                              const Center(
                                child: Text(
                                  'Thank you for using our app!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Action Buttons ─────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _generatingPdf
                                ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                                : _PureGlassCard(
                              isHighlight: true,
                              onTap: () => _downloadPdf(context),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Download PDF',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // ── UPDATED DONE BUTTON ──
                          Expanded(
                            child: _isSaving
                                ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                                : _PureGlassCard(
                              onTap: () async {
                                setState(() => _isSaving = true);

                                // Optional: Call your provider's save method here if needed
                                // e.g., await provider.saveProject(project);

                                if (context.mounted) {
                                  // This perfectly clears the navigation stack so the user
                                  // cannot hit "back" to return to the completed calculators,
                                  // and correctly opens the DashboardScreen.
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                                        (Route<dynamic> route) => false,
                                  );
                                }
                              },
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    'Done',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
      },
    );
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}