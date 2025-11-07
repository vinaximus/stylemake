import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:stylemake/features/production/data/models/fabrication_po.dart';

/// PDF Preview Screen for Purchase Orders
class PoPdfPreviewScreen extends StatelessWidget {
  const PoPdfPreviewScreen({
    required this.po,
    required this.pdfBytes,
    super.key,
  });

  final FabricationPoWithDetails po;
  final Uint8List pdfBytes;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${po.poNumber}'),
        actions: [
          // Print button
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print',
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (format) async => pdfBytes,
                name: '${po.poNumber}.pdf',
              );
            },
          ),
          // Share/Export button
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share/Export',
            onPressed: () async {
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: '${po.poNumber}.pdf',
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: '${po.poNumber}.pdf',
        onPrinted: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF printed successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onShared: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF shared successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

