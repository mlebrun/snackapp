import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snackapp/main.dart';

void main() {
  /// Helper function to navigate to the Grocery List tab.
  Future<void> navigateToGroceryList(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Grocery List'));
    await tester.pumpAndSettle();
  }

  /// Helper function to find a TextFormField by its label text.
  /// This finds the TextFormField that is an ancestor of the label Text widget.
  Finder findTextFormFieldByLabel(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(TextFormField),
    );
  }

  group('Grocery List empty state', () {
    testWidgets('Shows empty state when no items exist',
        (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Verify empty state message and icon are shown
      expect(find.text('No grocery items yet'), findsOneWidget);
      expect(find.text('Tap + to add one!'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('Empty state shows FAB to add items',
        (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Verify FAB is visible
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('Grocery List add item', () {
    testWidgets('Can add a grocery item', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Verify empty state
      expect(find.text('No grocery items yet'), findsOneWidget);

      // Tap FAB to open add dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify add dialog is shown
      expect(find.text('Add Item'), findsOneWidget);

      // Enter item name in the text field with label 'Item Name'
      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Milk');
      await tester.pump();

      // Tap Save button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify the item was added
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('No grocery items yet'), findsNothing);
    });

    testWidgets('Can add item with quantity', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Open add dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter item name
      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Eggs');
      await tester.pump();

      // Enter quantity
      final quantityField = findTextFormFieldByLabel('Quantity (optional)');
      await tester.enterText(quantityField.first, '1 dozen');
      await tester.pump();

      // Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify both name and quantity are shown
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('1 dozen'), findsOneWidget);
    });

    testWidgets('Can add multiple items', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add first item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Bread');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Add second item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(nameField.first, 'Butter');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify both items exist
      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('Butter'), findsOneWidget);
    });

    testWidgets('Cancel button dismisses add dialog without adding',
        (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Open add dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter item name
      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Cancelled Item');
      await tester.pump();

      // Tap Cancel button
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog closed and item was not added
      expect(find.text('Add Item'), findsNothing);
      expect(find.text('Cancelled Item'), findsNothing);
      expect(find.text('No grocery items yet'), findsOneWidget);
    });

    testWidgets('Empty name shows validation error',
        (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Open add dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Save without entering a name
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('Please enter an item name'), findsOneWidget);

      // Dialog should still be open
      expect(find.text('Add Item'), findsOneWidget);
    });
  });

  group('Grocery List edit item', () {
    testWidgets('Tapping item opens edit dialog', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item first
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Cheese');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Tap the item to edit
      await tester.tap(find.text('Cheese'));
      await tester.pumpAndSettle();

      // Verify edit dialog is shown with pre-filled values
      expect(find.text('Edit Item'), findsOneWidget);
      // The text 'Cheese' should be in the TextField
      expect(find.widgetWithText(TextFormField, 'Cheese'), findsOneWidget);
    });

    testWidgets('Can edit item name', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Original Name');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Open edit dialog
      await tester.tap(find.text('Original Name'));
      await tester.pumpAndSettle();

      // Clear and enter new name
      await tester.enterText(nameField.first, 'Updated Name');
      await tester.pump();

      // Save changes
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify name was updated
      expect(find.text('Updated Name'), findsOneWidget);
      expect(find.text('Original Name'), findsNothing);
    });

    testWidgets('Can edit item quantity', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item with quantity
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      final quantityField = findTextFormFieldByLabel('Quantity (optional)');

      await tester.enterText(nameField.first, 'Sugar');
      await tester.enterText(quantityField.first, '2 lbs');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify initial quantity
      expect(find.text('2 lbs'), findsOneWidget);

      // Open edit dialog
      await tester.tap(find.text('Sugar'));
      await tester.pumpAndSettle();

      // Update quantity
      await tester.enterText(quantityField.first, '5 lbs');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify quantity was updated
      expect(find.text('5 lbs'), findsOneWidget);
      expect(find.text('2 lbs'), findsNothing);
    });

    testWidgets('Cancel edit discards changes', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Keep This');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Open edit dialog
      await tester.tap(find.text('Keep This'));
      await tester.pumpAndSettle();

      // Change the name
      await tester.enterText(nameField.first, 'Changed Name');
      await tester.pump();

      // Cancel
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Verify original name is preserved
      expect(find.text('Keep This'), findsOneWidget);
      expect(find.text('Changed Name'), findsNothing);
    });
  });

  group('Grocery List delete item', () {
    testWidgets('Can delete an item', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Item to delete');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify item exists
      expect(find.text('Item to delete'), findsOneWidget);

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Verify item was removed
      expect(find.text('Item to delete'), findsNothing);
      expect(find.text('No grocery items yet'), findsOneWidget);
    });

    testWidgets('Delete shows snackbar with undo option',
        (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Snackbar Test');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Delete the item
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Verify snackbar is shown
      expect(find.text('Snackbar Test deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('Undo restores deleted item', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Undo Test Item');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Delete the item
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Verify item is deleted
      expect(find.text('Undo Test Item'), findsNothing);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pump();

      // Verify item is restored
      expect(find.text('Undo Test Item'), findsOneWidget);
      expect(find.text('No grocery items yet'), findsNothing);
    });

    testWidgets('Can delete one of multiple items',
        (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add first item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Item One');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Add second item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(nameField.first, 'Item Two');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify both items exist
      expect(find.text('Item One'), findsOneWidget);
      expect(find.text('Item Two'), findsOneWidget);

      // Delete first item (first delete button)
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();

      // Verify first item is deleted, second remains
      expect(find.text('Item One'), findsNothing);
      expect(find.text('Item Two'), findsOneWidget);
    });
  });

  group('Tab navigation', () {
    testWidgets('Can navigate between Recipes and Grocery List tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify we start on Recipes tab (default)
      expect(find.text('No recipes yet. Add one below!'), findsOneWidget);

      // Navigate to Grocery List tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Verify we're on Grocery List tab
      expect(find.text('No grocery items yet'), findsOneWidget);
      expect(find.text('No recipes yet. Add one below!'), findsNothing);

      // Navigate back to Recipes tab
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();

      // Verify we're back on Recipes tab
      expect(find.text('No recipes yet. Add one below!'), findsOneWidget);
      expect(find.text('No grocery items yet'), findsNothing);
    });

    testWidgets('Each tab maintains its own state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe on Recipes tab
      await tester.enterText(find.byType(TextField), 'Test Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify recipe was added
      expect(find.text('Test Recipe'), findsOneWidget);

      // Navigate to Grocery List tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Add a grocery item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Test Grocery');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify grocery item was added
      expect(find.text('Test Grocery'), findsOneWidget);

      // Navigate back to Recipes tab
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();

      // Verify recipe still exists
      expect(find.text('Test Recipe'), findsOneWidget);

      // Navigate back to Grocery List tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Verify grocery item still exists
      expect(find.text('Test Grocery'), findsOneWidget);
    });

    testWidgets('Both tabs show correct app bar title',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // App bar should show 'Snack App'
      expect(find.text('Snack App'), findsOneWidget);

      // Navigate to Grocery List tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // App bar should still show 'Snack App'
      expect(find.text('Snack App'), findsOneWidget);
    });

    testWidgets('Tab bar shows both tab labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify both tab labels are visible
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Grocery List'), findsOneWidget);
    });
  });

  group('Input validation', () {
    testWidgets('Whitespace-only name is not accepted',
        (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Open add dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter whitespace-only name
      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, '   ');
      await tester.pump();

      // Tap Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Please enter an item name'), findsOneWidget);

      // Dialog should still be open
      expect(find.text('Add Item'), findsOneWidget);
    });
  });

  group('Grocery item tile display', () {
    testWidgets('Item tile shows chevron icon', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Test Item');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify chevron icon is shown
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('Item tile shows delete icon', (WidgetTester tester) async {
      await navigateToGroceryList(tester);

      // Add an item
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final nameField = findTextFormFieldByLabel('Item Name');
      await tester.enterText(nameField.first, 'Delete Icon Test');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify delete icon is shown
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });
}
