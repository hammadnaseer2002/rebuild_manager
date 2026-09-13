import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/project_model.dart';

/// Generates PDF cost estimate reports for downloading and sharing.
class PdfReportService {
  PdfReportService._();

  static String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  /// Builds and returns PDF document bytes.
  static Future<Uint8List> buildPdf(ProjectModel project, String currencySymbol) async {
    final doc = pw.Document();

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

    final items = project.selectedCalculators
        .where((k) => labelMap.containsKey(k))
        .map((k) => {'label': labelMap[k]!, 'amount': costFor(k)})
        .toList();

    final dateStr =
        '${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}';

    // Premium dark/slate tone matching the new zen theme
    final primaryColor = PdfColor.fromHex('#1E222A');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ── Header ────────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Renovation Cost Estimate Report',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Project: ${project.name.isEmpty ? "Unnamed Project" : project.name}',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                pw.Text('Location: ${project.city}',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                pw.Text('Property Type: ${project.propertyType}',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                pw.Text('Room: ${project.selectedRoom}',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                pw.Text('Date: $dateStr',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Room Dimensions ───────────────────────────────────────────────
          pw.Text('Room Dimensions',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Length', 'Width', 'Height', 'Area'],
            data: [
              [
                '${project.roomLength} ${project.unit}',
                '${project.roomWidth} ${project.unit}',
                '${project.roomHeight} ${project.unit}',
                '${project.roomArea.toStringAsFixed(0)} sq ${project.unit}',
              ]
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          pw.SizedBox(height: 20),

          // ── Cost Breakdown ────────────────────────────────────────────────
          pw.Text('Cost Breakdown',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Item', 'Estimated Cost'],
            data: items
                .map((item) => [
              item['label'] as String,
              '$currencySymbol ${_fmt(item['amount'] as double)}',
            ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8F9FA')),
          ),
          pw.SizedBox(height: 12),

          // ── Total ─────────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Estimated Cost',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14)),
                pw.Text('$currencySymbol ${_fmt(project.totalEstimatedCost)}',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // ── Disclaimer ────────────────────────────────────────────────────
          pw.Text(
            'Disclaimer: This is an indicative estimate. Actual quantities, wastage, '
                'labor rates and market prices should be verified by a qualified contractor '
                'before construction.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Thank you for using Home Rebuild App!',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ],
      ),
    );

    return await doc.save();
  }

  /// Saves the PDF to storage and launches native print/save layout dialog.
  static Future<String> downloadPdf(ProjectModel project, String currencySymbol) async {
    final bytes = await buildPdf(project, currencySymbol);
    final rawName = project.name.trim().isEmpty ? 'Project' : project.name.trim();
    final filename = '${rawName.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(' ', '_')}_estimate.pdf';

    String savePath = '';
    try {
      Directory? dir;
      if (!kIsWeb && Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else if (!kIsWeb && Platform.isWindows) {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } else if (!kIsWeb) {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      if (dir != null) {
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        savePath = file.path;
      }
    } catch (e) {
      debugPrint('Direct file save error: $e');
    }

    // Trigger native Save / Print preview layout dialog
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: filename,
    );

    return savePath.isNotEmpty ? savePath : filename;
  }

  /// Opens native share dialog.
  static Future<void> sharePdf(ProjectModel project, String currencySymbol) async {
    final bytes = await buildPdf(project, currencySymbol);
    final rawName = project.name.trim().isEmpty ? 'Project' : project.name.trim();
    final filename = '${rawName.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(' ', '_')}_estimate.pdf';

    await Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }
}