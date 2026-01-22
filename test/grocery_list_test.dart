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
      await tester.pump(); // Allow setState to process
      await tester.pump(const Duration(milliseconds: 100)); // Allow snackbar to appear

      // Verify item is deleted
      expect(find.text('Undo Test Item'), findsNothing);

      // Verify snackbar is showing with Undo option
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pump(); // Allow setState to process

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

      // Verify we start on Recipes tab (shows recipe list)
      expect(find.text('Spaghetti Carbonara'), findsOneWidget);

      // Navigate to Grocery List tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Verify we're on Grocery List tab
      expect(find.text('No grocery items yet'), findsOneWidget);
      expect(find.text('Spaghetti Carbonara'), findsNothing);

      // Navigate back to Recipes tab
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();

      // Verify we're back on Recipes tab
      expect(find.text('Spaghetti Carbonara'), findsOneWidget);
      expect(find.text('No grocery items yet'), findsNothing);
    });

    testWidgets('Grocery list tab maintains state across tab switches',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

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

      // Navigate to Recipes tab
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();

      // Verify Recipes tab shows recipes
      expect(find.text('Spaghetti Carbonara'), findsOneWidget);

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

      // Verify both tabs are in the tab bar
      expect(find.widgetWithText(Tab, 'Recipes'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Grocery List'), findsOneWidget);
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

  group('Recipe ingredient quantity', () {
    /// Helper function to open the first recipe's details panel.
    Future<void> openFirstRecipeDetails(WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      // Tap the first recipe card (Spaghetti Carbonara)
      await tester.tap(find.text('Spaghetti Carbonara'));
      await tester.pumpAndSettle();
    }

    testWidgets('Recipe details panel shows ingredient quantity field',
        (WidgetTester tester) async {
      await openFirstRecipeDetails(tester);

      // Verify we're in the recipe details panel
      expect(find.text('Edit Recipe'), findsOneWidget);

      // The add ingredient input should have a quantity hint field
      expect(find.text('Qty (optional)'), findsOneWidget);
    });

    testWidgets('Can add ingredient with quantity in recipe details',
        (WidgetTester tester) async {
      await openFirstRecipeDetails(tester);

      // Find the add ingredient input fields
      final addIngredientField = find.widgetWithText(TextField, 'Add ingredient');
      final addQuantityField = find.widgetWithText(TextField, 'Qty (optional)');

      // Enter ingredient name and quantity
      await tester.enterText(addIngredientField, 'Olive Oil');
      await tester.pump();
      await tester.enterText(addQuantityField, '2 tbsp');
      await tester.pump();

      // Tap the add button
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // Verify the ingredient was added with quantity
      expect(find.text('Olive Oil'), findsOneWidget);
      expect(find.text('2 tbsp'), findsOneWidget);
    });

    testWidgets('Ingredient edit dialog shows quantity field',
        (WidgetTester tester) async {
      await openFirstRecipeDetails(tester);

      // Tap on an existing ingredient to edit it (Spaghetti)
      await tester.tap(find.text('Spaghetti'));
      await tester.pumpAndSettle();

      // Verify edit dialog shows with quantity field
      expect(find.text('Edit Ingredient'), findsOneWidget);
      expect(find.text('Ingredient Name'), findsOneWidget);
      expect(find.text('Quantity (optional)'), findsOneWidget);
    });

    testWidgets('Can edit ingredient quantity in recipe details',
        (WidgetTester tester) async {
      await openFirstRecipeDetails(tester);

      // Tap on an ingredient to edit
      await tester.tap(find.text('Spaghetti'));
      await tester.pumpAndSettle();

      // Find the quantity field in the dialog and enter a quantity
      final quantityField = find.widgetWithText(TextField, 'Quantity (optional)');
      await tester.enterText(quantityField.first, '1 lb');
      await tester.pump();

      // Save the changes
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify quantity is now shown for the ingredient
      expect(find.text('1 lb'), findsOneWidget);
    });

    testWidgets('Ingredient quantity displays in recipe details list',
        (WidgetTester tester) async {
      await openFirstRecipeDetails(tester);

      // Add an ingredient with quantity first
      final addIngredientField = find.widgetWithText(TextField, 'Add ingredient');
      final addQuantityField = find.widgetWithText(TextField, 'Qty (optional)');

      await tester.enterText(addIngredientField, 'Black Pepper');
      await tester.pump();
      await tester.enterText(addQuantityField, '1 tsp');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // Verify quantity is shown in the ingredient list
      expect(find.text('Black Pepper'), findsOneWidget);
      expect(find.text('1 tsp'), findsOneWidget);
    });
  });

  group('Recipe to Grocery List quantity transfer', () {
    /// Helper to add quantity to an ingredient in recipe details and save.
    Future<void> addQuantityToIngredient(
      WidgetTester tester,
      String ingredientName,
      String quantity,
    ) async {
      // Tap the ingredient to open edit dialog
      await tester.tap(find.text(ingredientName));
      await tester.pumpAndSettle();

      // Enter quantity
      final quantityField = find.widgetWithText(TextField, 'Quantity (optional)');
      await tester.enterText(quantityField.first, quantity);
      await tester.pump();

      // Save
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();
    }

    testWidgets('Quantity transfers from recipe to grocery list',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Open recipe details for Spaghetti Carbonara
      await tester.tap(find.text('Spaghetti Carbonara'));
      await tester.pumpAndSettle();

      // Add quantity to an ingredient
      await addQuantityToIngredient(tester, 'Spaghetti', '500g');

      // Save recipe changes
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Now tap the add to grocery list button
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pumpAndSettle();

      // Navigate to grocery list tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Verify Spaghetti was added with its quantity
      expect(find.text('Spaghetti'), findsOneWidget);
      expect(find.text('500g'), findsOneWidget);
    });

    testWidgets('Ingredients without quantity transfer without quantity',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Tap add to grocery list directly without editing quantities
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pumpAndSettle();

      // Navigate to grocery list tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Verify ingredients were added (without quantities since none were set)
      expect(find.text('Spaghetti'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Parmesan Cheese'), findsOneWidget);
      expect(find.text('Bacon'), findsOneWidget);
    });

    testWidgets('Existing ingredients without quantity transfer without quantity',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add default recipe ingredients (which have no quantity) to grocery list
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pumpAndSettle();

      // Navigate to grocery list
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Verify all 4 default ingredients were added without quantities
      // (the sample recipes don't have quantities by default)
      expect(find.text('Spaghetti'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Parmesan Cheese'), findsOneWidget);
      expect(find.text('Bacon'), findsOneWidget);
    });

    testWidgets('Snackbar shows when ingredients added to grocery list',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add ingredients to grocery list
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pump();

      // Verify snackbar message
      expect(find.text('Added 4 ingredients to grocery list'), findsOneWidget);
    });

    testWidgets('Duplicate ingredients are not added again',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add ingredients to grocery list for the first time
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pumpAndSettle();

      // Navigate to grocery list and verify count
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Should have 4 items
      expect(find.text('Spaghetti'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Parmesan Cheese'), findsOneWidget);
      expect(find.text('Bacon'), findsOneWidget);

      // Navigate back to recipes
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();

      // Try to add same ingredients again
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pumpAndSettle();

      // Navigate to grocery list
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Should still have only 4 items (no duplicates)
      expect(find.text('Spaghetti'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Parmesan Cheese'), findsOneWidget);
      expect(find.text('Bacon'), findsOneWidget);
    });
  });
}
