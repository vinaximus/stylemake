import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/features/production/presentation/views/receipts/receipt_form_screen.dart';

void main() {
  testWidgets('Receipt form shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ReceiptFormScreen())));

    // Tap save button (AppBar action)
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    // Expect validation messages for required fields
    expect(find.textContaining('required'), findsWidgets);
  });
}
