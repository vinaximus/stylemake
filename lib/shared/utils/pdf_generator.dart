import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stylemake/features/production/data/models/fabrication_po.dart';
import 'package:stylemake/features/production/presentation/views/pos/po_pdf_preview_screen.dart';

/// PDF Generator utility for Purchase Orders
class PdfGenerator {
  /// Generate PDF bytes for a Purchase Order
  static Future<Uint8List> generatePoPdfBytes(
    FabricationPoWithDetails po,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildPoContent(po),
      ),
    );

    return await pdf.save();
  }

  /// Generate and show PDF preview screen for a Purchase Order
  static Future<void> generateAndShowPoPdf(
    BuildContext context,
    FabricationPoWithDetails po,
  ) async {
    try {
      // Generate PDF bytes
      final pdfBytes = await generatePoPdfBytes(po);

      // Navigate to preview screen
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PoPdfPreviewScreen(
              po: po,
              pdfBytes: pdfBytes,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  static pw.Widget _buildPoContent(FabricationPoWithDetails po) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Hardcoded company information
    const companyName = 'Kaamini Fashion';
    const companyAddress = 'H1-102B, Hans Vihar, RIICO Industrial Area, Mansarovar, Jaipur, Rajasthan 302020, GST:08AILPK5999B1ZT';

    return pw.Padding(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Company Header - Centered
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  companyName,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  companyAddress,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Order Details Section
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left Column - Order Details
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _detailRow('Job Order No', po.jobOrderNo, underline: true),
                    pw.SizedBox(height: 12),
                    _detailRow('Cutting Reference', po.cuttingRef, underline: true),
                    pw.SizedBox(height: 12),
                    _detailRow(
                      'Completion date',
                      po.completionDate != null
                          ? dateFormat.format(po.completionDate!)
                          : '',
                      underline: true,
                    ),
                    pw.SizedBox(height: 12),
                    _detailRow('Firm Name', po.vendorName, underline: true),
                  ],
                ),
              ),
              
              // Right Column - Date of Issue
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    dateFormat.format(po.dateOfIssue),
                    style: pw.TextStyle(
                      fontSize: 14,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 25),

          // Order Items Table (if available)
          if (po.orderItems != null && po.orderItems!.isNotEmpty) ...[
            pw.Text(
              'Order Items',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    _tableCell('Description', isHeader: true),
                    _tableCell('Qty', isHeader: true),
                    _tableCell('Rate', isHeader: true),
                    _tableCell('Amount', isHeader: true),
                  ],
                ),
                // Data rows
                ...po.orderItems!.map((item) {
                  return pw.TableRow(
                    children: [
                      _tableCell(item.orderDescription),
                      _tableCell(item.quantity.toString()),
                      _tableCell('${item.rate.toStringAsFixed(2)}'),
                      _tableCell('${item.totalAmount.toStringAsFixed(2)}'),
                    ],
                  );
                }),
                // Total row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                  ),
                  children: [
                    _tableCell('Total', isHeader: true),
                    _tableCell(''),
                    _tableCell(''),
                    _tableCell(
                      '${po.totalAmountFromItems.toStringAsFixed(2)}',
                      isHeader: true,
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 25),
          ],

          // Instructions Box - Bottom Left
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Instructions',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  po.instructions ?? '',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _detailRow(String label, String value, {required bool underline}) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              decoration: underline ? pw.TextDecoration.underline : pw.TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
