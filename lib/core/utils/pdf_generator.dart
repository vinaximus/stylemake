import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:stylemake/core/models/fabrication_po.dart';

/// PDF Generator utility for Purchase Orders
class PdfGenerator {
  /// Generate and show PDF for a Purchase Order
  static Future<void> generateAndShowPoPdf(FabricationPoWithDetails po) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildPoContent(po),
      ),
    );

    // Show PDF preview and allow download
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${po.poNumber}.pdf',
    );
  }

  static pw.Widget _buildPoContent(FabricationPoWithDetails po) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return pw.Padding(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Center(
            child: pw.Text(
              'PURCHASE ORDER',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),

          // PO Number and Date
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PO Number:',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(po.poNumber, style: const pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Date of Issue:',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    dateFormat.format(po.dateOfIssue),
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Vendor Details
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'VENDOR DETAILS',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(po.vendorName, style: const pw.TextStyle(fontSize: 16)),
                if (po.vendorGst != null) ...[
                  pw.SizedBox(height: 5),
                  pw.Text('GST: ${po.vendorGst}'),
                ],
                if (po.vendorCity != null) ...[
                  pw.SizedBox(height: 5),
                  pw.Text('City: ${po.vendorCity}'),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // PO Details Table
          pw.Text(
            'ORDER DETAILS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _tableCellHeader('Field'),
                  _tableCellHeader('Value'),
                ],
              ),
              // Data rows
              _tableRow('Cutting Reference', po.cuttingRef),
              _tableRow('Style', po.styleName),
              _tableRow('Job Order No', po.jobOrderNo),
              _tableRow('Fabrication Type', po.fabricationType),
              _tableRow('Issue Date', dateFormat.format(po.dateOfIssue)),
              if (po.completionDate != null)
                _tableRow(
                  'Completion Date',
                  dateFormat.format(po.completionDate!),
                ),
              _tableRow('Quantity Issued', '${po.quantityIssued} pcs'),
              _tableRow(
                'Rate per Unit',
                '₹ ${po.ratePerUnit.toStringAsFixed(2)}',
              ),
            ],
          ),
          pw.SizedBox(height: 15),

          // Total Amount
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL AMOUNT',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '₹ ${po.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Instructions
          if (po.instructions != null && po.instructions!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text(
              'INSTRUCTIONS',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Text(
                po.instructions!,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ],

          pw.Spacer(),

          // Footer
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'This is a computer-generated document',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableCellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.TableRow _tableRow(String field, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            field,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}
