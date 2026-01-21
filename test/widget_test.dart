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

  group('Ingredient CRUD operations', () {
    testWidgets('Can expand recipe and add ingredient',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe first
      await tester.enterText(find.byType(TextField), 'Pasta Dish');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Expand the recipe by tapping on it
      await tester.tap(find.text('Pasta Dish'));
      await tester.pumpAndSettle();

      // Verify empty ingredients message is shown
      expect(find.text('No ingredients yet. Add one below!'), findsOneWidget);

      // Find the ingredient TextField (inside the ExpansionTile)
      // The first TextField is now the ingredient input
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

      // Verify the ingredient was added
      expect(find.text('Spaghetti'), findsOneWidget);
      expect(find.text('No ingredients yet. Add one below!'), findsNothing);
    });

    testWidgets('Can delete an ingredient', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Salad');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Expand the recipe
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

    testWidgets('Can add multiple ingredients to a recipe',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Sandwich');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Expand the recipe
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

      // Expand the recipe
      await tester.tap(find.text('Pizza'));
      await tester.pumpAndSettle();

      // Add ingredients
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

      // Verify ingredients exist
      expect(find.text('Dough'), findsOneWidget);
      expect(find.text('Tomato Sauce'), findsOneWidget);

      // Delete the recipe
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Verify recipe and all ingredients are removed
      expect(find.text('Pizza'), findsNothing);
      expect(find.text('Dough'), findsNothing);
      expect(find.text('Tomato Sauce'), findsNothing);
      expect(find.text('No recipes yet. Add one below!'), findsOneWidget);
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

    testWidgets('Empty ingredient name is not added',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe first
      await tester.enterText(find.byType(TextField), 'Test Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Expand the recipe
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

  group('Recipe expansion', () {
    testWidgets('Can collapse and expand recipe',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Add a recipe
      await tester.enterText(find.byType(TextField), 'Collapsible Recipe');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Ingredients should not be visible initially
      expect(find.text('No ingredients yet. Add one below!'), findsNothing);

      // Expand the recipe
      await tester.tap(find.text('Collapsible Recipe'));
      await tester.pumpAndSettle();

      // Now ingredient placeholder should be visible
      expect(find.text('No ingredients yet. Add one below!'), findsOneWidget);

      // Collapse the recipe
      await tester.tap(find.text('Collapsible Recipe'));
      await tester.pumpAndSettle();

      // Ingredient placeholder should be hidden again
      expect(find.text('No ingredients yet. Add one below!'), findsNothing);
    });
  });
}
