
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
}


