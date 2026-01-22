import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snackapp/main.dart';

void main() {
  group('Recipe CRUD operations', () {
    testWidgets('Can add a recipe', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify empty state message is shown
      expect(find.text('No recipes yet. Add one below!'), findsOneWidget);

      // Enter recipe name in the text field
      await tester.enterText(find.byType(TextField), 'Chocolate Cake');
      await tester.pump();

      // Tap the add button (IconButton.filled with add icon)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify the recipe was added
      expect(find.text('Chocolate Cake'), findsOneWidget);
      expect(find.text('No recipes yet. Add one below!'), findsNothing);
    });

    testWidgets('Can delete a recipe', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe first
      await tester.enterText(find.byType(TextField), 'Recipe to delete');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify recipe exists
      expect(find.text('Recipe to delete'), findsOneWidget);

      // Tap the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Verify recipe was removed and empty state is shown
      expect(find.text('Recipe to delete'), findsNothing);
      expect(find.text('No recipes yet. Add one below!'), findsOneWidget);
    });

    testWidgets('Can add multiple recipes', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add first recipe
      await tester.enterText(find.byType(TextField).first, 'Recipe One');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Add second recipe
      await tester.enterText(find.byType(TextField).first, 'Recipe Two');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify both recipes exist
      expect(find.text('Recipe One'), findsOneWidget);
      expect(find.text('Recipe Two'), findsOneWidget);
    });
  });

  group('Recipe Details Panel', () {
    testWidgets('Tapping recipe opens details panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe first
      await tester.enterText(find.byType(TextField), 'Test Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Tap the recipe to open the panel
      await tester.tap(find.text('Test Recipe'));
      await tester.pumpAndSettle();

      // Verify panel is shown with Edit Recipe header
      expect(find.text('Edit Recipe'), findsOneWidget);
      // Verify recipe name is shown in the panel's text field
      expect(find.text('Recipe Name'), findsOneWidget);
    });

    testWidgets('Can close panel with cancel button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe and open panel
      await tester.enterText(find.byType(TextField), 'Cancel Test');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.text('Cancel Test'));
      await tester.pumpAndSettle();

      // Verify panel is open
      expect(find.text('Edit Recipe'), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify panel is closed
      expect(find.text('Edit Recipe'), findsNothing);
    });

    testWidgets('Can close panel with close icon button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe and open panel
      await tester.enterText(find.byType(TextField), 'Close Test');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.text('Close Test'));
      await tester.pumpAndSettle();

      // Verify panel is open
      expect(find.text('Edit Recipe'), findsOneWidget);

      // Tap close icon button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify panel is closed
      expect(find.text('Edit Recipe'), findsNothing);
    });
  });

  group('Ingredient CRUD operations via panel', () {
    testWidgets('Can open panel and add ingredient',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe first
      await tester.enterText(find.byType(TextField), 'Pasta Dish');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Tap the recipe to open the panel
      await tester.tap(find.text('Pasta Dish'));
      await tester.pumpAndSettle();

      // Verify empty ingredients message is shown in panel
      expect(find.text('No ingredients yet. Add one below!'), findsOneWidget);

      // Find the ingredient TextField (by hint text)
      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      expect(ingredientTextField, findsOneWidget);

      // Enter ingredient name
      await tester.enterText(ingredientTextField, 'Spaghetti');
      await tester.pump();

      // Tap the add ingredient button (add_circle icon)
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Verify the ingredient was added in the panel
      expect(find.text('Spaghetti'), findsOneWidget);
      expect(find.text('No ingredients yet. Add one below!'), findsNothing);
    });

    testWidgets('Can delete an ingredient in panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Salad');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Salad'));
      await tester.pumpAndSettle();

      // Add an ingredient
      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Lettuce');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Verify ingredient exists
      expect(find.text('Lettuce'), findsOneWidget);

      // Tap the remove ingredient button (remove_circle_outline icon)
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pump();

      // Verify ingredient was removed
      expect(find.text('Lettuce'), findsNothing);
      expect(find.text('No ingredients yet. Add one below!'), findsOneWidget);
    });

    testWidgets('Can add multiple ingredients in panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Sandwich');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Sandwich'));
      await tester.pumpAndSettle();

      // Add first ingredient
      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Bread');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Add second ingredient
      await tester.enterText(ingredientTextField, 'Cheese');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Verify both ingredients exist
      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('Cheese'), findsOneWidget);
    });

    testWidgets('Deleting a recipe removes all its ingredients',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Pizza');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel and add ingredients
      await tester.tap(find.text('Pizza'));
      await tester.pumpAndSettle();

      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Dough');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      await tester.enterText(ingredientTextField, 'Tomato Sauce');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Verify ingredients exist in panel
      expect(find.text('Dough'), findsOneWidget);
      expect(find.text('Tomato Sauce'), findsOneWidget);

      // Save and close the panel
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Delete the recipe
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Verify recipe is removed and empty state is shown
      expect(find.text('Pizza'), findsNothing);
      expect(find.text('No recipes yet. Add one below!'), findsOneWidget);
    });

    testWidgets('Saved ingredients persist after closing and reopening panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Persist Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel and add an ingredient
      await tester.tap(find.text('Persist Recipe'));
      await tester.pumpAndSettle();

      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Persisted Ingredient');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Save the changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify panel is closed
      expect(find.text('Edit Recipe'), findsNothing);

      // Reopen the panel
      await tester.tap(find.text('Persist Recipe'));
      await tester.pumpAndSettle();

      // Verify the ingredient persisted
      expect(find.text('Persisted Ingredient'), findsOneWidget);
    });

    testWidgets('Cancelled changes do not persist',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Cancel Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel and add an ingredient
      await tester.tap(find.text('Cancel Recipe'));
      await tester.pumpAndSettle();

      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Cancelled Ingredient');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Verify ingredient shows in panel
      expect(find.text('Cancelled Ingredient'), findsOneWidget);

      // Cancel without saving
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Reopen the panel
      await tester.tap(find.text('Cancel Recipe'));
      await tester.pumpAndSettle();

      // Verify the ingredient was NOT persisted
      expect(find.text('Cancelled Ingredient'), findsNothing);
      expect(find.text('No ingredients yet. Add one below!'), findsOneWidget);
    });

    testWidgets('Can edit ingredient name via dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Edit Ingredient Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Edit Ingredient Recipe'));
      await tester.pumpAndSettle();

      // Add an ingredient
      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Original Ingredient');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Verify ingredient exists
      expect(find.text('Original Ingredient'), findsOneWidget);

      // Tap the edit icon to open the edit dialog
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify the edit dialog is shown
      expect(find.text('Edit Ingredient'), findsOneWidget);

      // Find the edit dialog TextField and change the name
      final editDialogTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Ingredient Name',
      );
      expect(editDialogTextField, findsOneWidget);

      await tester.enterText(editDialogTextField, 'Renamed Ingredient');
      await tester.pump();

      // Tap Save in the dialog
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify the ingredient name was updated
      expect(find.text('Renamed Ingredient'), findsOneWidget);
      expect(find.text('Original Ingredient'), findsNothing);

      // Save and reopen to verify persistence
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Ingredient Recipe'));
      await tester.pumpAndSettle();

      // Verify the renamed ingredient persisted
      expect(find.text('Renamed Ingredient'), findsOneWidget);
    });

    testWidgets('Edited ingredient reverts on cancel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Revert Ingredient Test');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel and add an ingredient
      await tester.tap(find.text('Revert Ingredient Test'));
      await tester.pumpAndSettle();

      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Keep This Name');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Save to persist the ingredient
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Reopen the panel
      await tester.tap(find.text('Revert Ingredient Test'));
      await tester.pumpAndSettle();

      // Edit the ingredient via dialog
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      final editDialogTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Ingredient Name',
      );
      await tester.enterText(editDialogTextField, 'Changed Name');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify change shows in panel
      expect(find.text('Changed Name'), findsOneWidget);

      // Cancel the panel without saving
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Reopen the panel to verify reversion
      await tester.tap(find.text('Revert Ingredient Test'));
      await tester.pumpAndSettle();

      // Verify the original name is preserved
      expect(find.text('Keep This Name'), findsOneWidget);
      expect(find.text('Changed Name'), findsNothing);
    });
  });

  group('Input validation', () {
    testWidgets('Empty recipe name is not added', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Try to add empty recipe
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify empty state is still shown
      expect(find.text('No recipes yet. Add one below!'), findsOneWidget);

      // Try with whitespace only
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify empty state is still shown
      expect(find.text('No recipes yet. Add one below!'), findsOneWidget);
    });

    testWidgets('Empty ingredient name is not added in panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe first
      await tester.enterText(find.byType(TextField), 'Test Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Test Recipe'));
      await tester.pumpAndSettle();

      // Try to add empty ingredient
      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, '');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Verify empty ingredients message is still shown
      expect(find.text('No ingredients yet. Add one below!'), findsOneWidget);

      // Try with whitespace only
      await tester.enterText(ingredientTextField, '   ');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Verify empty ingredients message is still shown
      expect(find.text('No ingredients yet. Add one below!'), findsOneWidget);
    });
  });

  group('Stock status toggle in panel', () {
    testWidgets('New recipe defaults to out-of-stock',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'New Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel to see the Switch
      await tester.tap(find.text('New Recipe'));
      await tester.pumpAndSettle();

      // Verify Switch is present and defaulted to false (out-of-stock)
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);
    });

    testWidgets('Can toggle recipe to in stock via panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Toggle Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Toggle Recipe'));
      await tester.pumpAndSettle();

      // Verify initial state is out-of-stock
      final switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, isFalse);

      // Tap the switch to toggle to in-stock
      await tester.tap(switchFinder);
      await tester.pump();

      // Verify the switch is now on (in stock)
      expect(tester.widget<Switch>(switchFinder).value, isTrue);
    });

    testWidgets('Stock status change persists after save',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Stock Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Stock Recipe'));
      await tester.pumpAndSettle();

      // Toggle to in-stock
      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pump();

      // Save the changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Reopen the panel to verify
      await tester.tap(find.text('Stock Recipe'));
      await tester.pumpAndSettle();

      // Verify the switch state persisted
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('Stock status change does not persist on cancel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Cancel Stock Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Cancel Stock Recipe'));
      await tester.pumpAndSettle();

      // Toggle to in-stock
      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pump();
      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      // Cancel without saving
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Reopen the panel to verify
      await tester.tap(find.text('Cancel Stock Recipe'));
      await tester.pumpAndSettle();

      // Verify the switch reverted to original state
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    });

    testWidgets('Out of stock recipe has reduced opacity in list',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Opacity Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Find the Opacity widget wrapping the recipe name text
      // When out-of-stock (default), opacity should be 0.5
      final opacityFinder = find.ancestor(
        of: find.text('Opacity Recipe'),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsOneWidget);
      expect(tester.widget<Opacity>(opacityFinder).opacity, equals(0.5));

      // Open panel and toggle to in-stock
      await tester.tap(find.text('Opacity Recipe'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the opacity is now full (1.0)
      expect(tester.widget<Opacity>(opacityFinder).opacity, equals(1.0));
    });

    testWidgets('Multiple recipes have independent stock status',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add three recipes
      await tester.enterText(find.byType(TextField).first, 'Recipe One');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'Recipe Two');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'Recipe Three');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open panel for middle recipe (Recipe Two) and toggle to in-stock
      await tester.tap(find.text('Recipe Two'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify Recipe One is still out-of-stock (opacity 0.5)
      final opacityOne = find.ancestor(
        of: find.text('Recipe One'),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(opacityOne).opacity, equals(0.5));

      // Verify Recipe Two is in-stock (opacity 1.0)
      final opacityTwo = find.ancestor(
        of: find.text('Recipe Two'),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(opacityTwo).opacity, equals(1.0));

      // Verify Recipe Three is still out-of-stock (opacity 0.5)
      final opacityThree = find.ancestor(
        of: find.text('Recipe Three'),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(opacityThree).opacity, equals(0.5));
    });
  });

  group('Recipe title editing in panel', () {
    testWidgets('Can edit recipe title in panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Original Title');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Original Title'));
      await tester.pumpAndSettle();

      // Find the recipe name TextField in the panel (labeled 'Recipe Name')
      final titleTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Recipe Name',
      );
      expect(titleTextField, findsOneWidget);

      // Clear and enter new title
      await tester.enterText(titleTextField, 'Updated Title');
      await tester.pump();

      // Save the changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the title was updated in the list
      expect(find.text('Updated Title'), findsOneWidget);
      expect(find.text('Original Title'), findsNothing);
    });

    testWidgets('Title change does not persist on cancel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Keep This Title');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Keep This Title'));
      await tester.pumpAndSettle();

      // Find the recipe name TextField and change it
      final titleTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Recipe Name',
      );
      await tester.enterText(titleTextField, 'Changed Title');
      await tester.pump();

      // Cancel without saving
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify the original title is still shown
      expect(find.text('Keep This Title'), findsOneWidget);
      expect(find.text('Changed Title'), findsNothing);
    });

    testWidgets('Empty title disables save button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Valid Title');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Valid Title'));
      await tester.pumpAndSettle();

      // Find the recipe name TextField and clear it
      final titleTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Recipe Name',
      );
      await tester.enterText(titleTextField, '');
      await tester.pump();

      // Find the Save button and verify it's disabled
      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      expect(saveButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(saveButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('Whitespace-only title disables save button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Valid Title');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open the panel
      await tester.tap(find.text('Valid Title'));
      await tester.pumpAndSettle();

      // Find the recipe name TextField and enter whitespace only
      final titleTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Recipe Name',
      );
      await tester.enterText(titleTextField, '   ');
      await tester.pump();

      // Find the Save button and verify it's disabled
      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      expect(saveButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(saveButton);
      expect(button.onPressed, isNull);
    });
  });

  group('Comprehensive panel edit flow', () {
    testWidgets('Can edit multiple fields and save all changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Multi Edit Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify initial state
      expect(find.text('Multi Edit Recipe'), findsOneWidget);
      expect(find.text('No ingredients'), findsOneWidget);
      final initialOpacity = find.ancestor(
        of: find.text('Multi Edit Recipe'),
        matching: find.byType(Opacity),
      );
      expect(
          tester.widget<Opacity>(initialOpacity).opacity, equals(0.5)); // Out of stock

      // Open the panel
      await tester.tap(find.text('Multi Edit Recipe'));
      await tester.pumpAndSettle();

      // 1. Edit the title
      final titleTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Recipe Name',
      );
      await tester.enterText(titleTextField, 'Comprehensive Recipe');
      await tester.pump();

      // 2. Toggle in-stock status
      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pump();

      // 3. Add ingredients
      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'First Item');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      await tester.enterText(ingredientTextField, 'Second Item');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Save all changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify all changes persisted
      // Title changed
      expect(find.text('Comprehensive Recipe'), findsOneWidget);
      expect(find.text('Multi Edit Recipe'), findsNothing);

      // In-stock status changed (opacity 1.0)
      final updatedOpacity = find.ancestor(
        of: find.text('Comprehensive Recipe'),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(updatedOpacity).opacity, equals(1.0));

      // Ingredients persisted
      expect(find.text('2 ingredients'), findsOneWidget);

      // Reopen and verify ingredients are there
      await tester.tap(find.text('Comprehensive Recipe'));
      await tester.pumpAndSettle();
      expect(find.text('First Item'), findsOneWidget);
      expect(find.text('Second Item'), findsOneWidget);
    });

    testWidgets('Cancel discards all changes made to multiple fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe with initial state
      await tester.enterText(find.byType(TextField), 'Original Name');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open panel and add an ingredient, then save to establish baseline
      await tester.tap(find.text('Original Name'));
      await tester.pumpAndSettle();

      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Original Ingredient');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify baseline
      expect(find.text('Original Name'), findsOneWidget);
      expect(find.text('1 ingredient'), findsOneWidget);
      final baselineOpacity = find.ancestor(
        of: find.text('Original Name'),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(baselineOpacity).opacity, equals(0.5)); // Out of stock

      // Reopen panel and make multiple changes
      await tester.tap(find.text('Original Name'));
      await tester.pumpAndSettle();

      // 1. Change title
      final titleTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Recipe Name',
      );
      await tester.enterText(titleTextField, 'Changed Name');
      await tester.pump();

      // 2. Toggle status
      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pump();

      // 3. Add another ingredient
      await tester.enterText(ingredientTextField, 'New Ingredient');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // 4. Remove original ingredient
      // Find the first remove button (for 'Original Ingredient')
      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      await tester.pump();

      // Verify changes are visible in panel
      expect(find.text('Changed Name'), findsOneWidget);
      expect(find.text('New Ingredient'), findsOneWidget);
      expect(find.text('Original Ingredient'), findsNothing);

      // Cancel without saving
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify ALL changes were discarded
      // Title reverted
      expect(find.text('Original Name'), findsOneWidget);
      expect(find.text('Changed Name'), findsNothing);

      // Status reverted (still out of stock)
      final revertedOpacity = find.ancestor(
        of: find.text('Original Name'),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(revertedOpacity).opacity, equals(0.5));

      // Ingredient count still 1
      expect(find.text('1 ingredient'), findsOneWidget);

      // Verify original ingredient is back
      await tester.tap(find.text('Original Name'));
      await tester.pumpAndSettle();
      expect(find.text('Original Ingredient'), findsOneWidget);
      expect(find.text('New Ingredient'), findsNothing);
    });
  });

  group('Recipe list display', () {
    testWidgets('Recipe shows ingredient count in subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Count Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify initial "No ingredients" text
      expect(find.text('No ingredients'), findsOneWidget);

      // Open panel and add ingredients
      await tester.tap(find.text('Count Recipe'));
      await tester.pumpAndSettle();

      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Ingredient 1');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      await tester.enterText(ingredientTextField, 'Ingredient 2');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Save and close
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify ingredient count is shown
      expect(find.text('2 ingredients'), findsOneWidget);
    });

    testWidgets('Single ingredient shows singular form',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Singular Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Open panel and add one ingredient
      await tester.tap(find.text('Singular Recipe'));
      await tester.pumpAndSettle();

      final ingredientTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Add ingredient',
      );
      await tester.enterText(ingredientTextField, 'Single Ingredient');
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pump();

      // Save and close
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify singular form "1 ingredient" is shown
      expect(find.text('1 ingredient'), findsOneWidget);
    });
  });
}
