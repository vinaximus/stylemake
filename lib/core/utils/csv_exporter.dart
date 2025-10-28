import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stylemake/core/models/cutting.dart';
import 'package:stylemake/core/models/fabrication_po.dart';
import 'package:stylemake/core/models/receipt.dart';

class CsvExporter {
  static String listOfMapsToCsv(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return '';
    final headers = rows.first.keys.toList();
    final buffer = StringBuffer();

    buffer.writeln(headers.map(_escape).join(','));
    for (final row in rows) {
      final values = headers.map((h) => _escape(row[h])).join(',');
      buffer.writeln(values);
    }
    return buffer.toString();
  }

  static String _escape(dynamic value) {
    final s = value?.toString() ?? '';
    final needsQuotes = s.contains(',') || s.contains('\n') || s.contains('"');
    var out = s.replaceAll('"', '""');
    if (needsQuotes) out = '"$out"';
    return out;
  }

  /// Export cuttings to CSV format
  static String cuttingsToCsv(List<CuttingWithStyle> cuttings) {
    if (cuttings.isEmpty) return '';

    final rows = cuttings.map((cutting) {
      return {
        'Cutting Ref': cutting.cuttingRef,
        'Date': DateFormat('yyyy-MM-dd').format(cutting.cuttingDate),
        'Style': cutting.styleName,
        'Quantity Cut': cutting.quantityCut,
        'Notes': cutting.notes ?? '',
      };
    }).toList();

    return listOfMapsToCsv(rows);
  }

  /// Export POs to CSV format
  static String posToCsv(List<FabricationPoWithDetails> pos) {
    if (pos.isEmpty) return '';

    final rows = pos.map((po) {
      return {
        'PO Number': po.poNumber,
        'Job Order No': po.jobOrderNo,
        'Vendor': po.vendorName,
        'Cutting Ref': po.cuttingRef,
        'Style': po.styleName,
        'Fabrication Type': po.fabricationType,
        'Issue Date': DateFormat('yyyy-MM-dd').format(po.dateOfIssue),
        'Completion Date': po.completionDate != null
            ? DateFormat('yyyy-MM-dd').format(po.completionDate!)
            : '',
        'Quantity Issued': po.quantityIssued,
        'Rate per Unit': po.ratePerUnit.toStringAsFixed(2),
        'Total': (po.quantityIssued * po.ratePerUnit).toStringAsFixed(2),
        'Instructions': po.instructions ?? '',
      };
    }).toList();

    return listOfMapsToCsv(rows);
  }

  /// Export receipts to CSV format
  static String receiptsToCsv(List<ReceiptWithDetails> receipts) {
    if (receipts.isEmpty) return '';

    final rows = receipts.map((receipt) {
      return {
        'Receipt ID': receipt.receiptId,
        'Date': DateFormat('yyyy-MM-dd').format(receipt.dateOfReceipt),
        'Cutting Ref': receipt.cuttingRef,
        'Style': receipt.styleName,
        'Quantity Received': receipt.quantityReceived,
        'Notes': receipt.notes ?? '',
      };
    }).toList();

    return listOfMapsToCsv(rows);
  }

  /// Download or share CSV file
  static Future<void> downloadOrShareCsv({
    required String csvContent,
    required String filename,
  }) async {
    try {
      if (kIsWeb) {
        // For web, trigger browser download
        // This would require additional web-specific implementation
        debugPrint('Web download not fully implemented - CSV content ready');
        debugPrint(csvContent);
      } else {
        // For mobile/desktop, save to temp file and share
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$filename';
        final file = File(filePath);
        await file.writeAsString(csvContent);

        // Share the file
        await Share.shareXFiles([XFile(filePath)], subject: filename);

        debugPrint('✅ CSV file shared: $filename');
      }
    } catch (e) {
      debugPrint('❌ Failed to download/share CSV: $e');
      rethrow;
    }
  }

  /// Generate filename with timestamp
  static String generateFilename(String prefix) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${prefix}_$timestamp.csv';
  }
}
