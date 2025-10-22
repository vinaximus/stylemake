import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/features/production/screens/pos/po_form_screen.dart';

void main() {
  testWidgets('PO form shows validation on empty submit', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PoFormScreen())));
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(find.textContaining('required'), findsWidgets);
  });
}
