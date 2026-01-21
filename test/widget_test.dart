import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snackapp/main.dart';

void main() {
  testWidgets('Add item to list', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify empty state message is shown
    expect(find.text('No items yet. Add one below!'), findsOneWidget);

    // Enter text in the text field
    await tester.enterText(find.byType(TextField), 'Test Item');
    await tester.pump();

    // Tap the add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify the item was added
    expect(find.text('Test Item'), findsOneWidget);
    expect(find.text('No items yet. Add one below!'), findsNothing);
  });

  testWidgets('Remove item from list', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Add an item first
    await tester.enterText(find.byType(TextField), 'Item to delete');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify item exists
    expect(find.text('Item to delete'), findsOneWidget);

    // Tap the delete button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    // Verify item was removed and empty state is shown
    expect(find.text('Item to delete'), findsNothing);
    expect(find.text('No items yet. Add one below!'), findsOneWidget);
  });
}
