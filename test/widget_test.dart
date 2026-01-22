import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snackapp/main.dart';

void main() {
  group('App initialization', () {
    testWidgets('App renders with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify app bar shows correct title
      expect(find.text('Snack App'), findsOneWidget);
    });

    testWidgets('App starts on Recipes tab by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify Recipes tab shows recipes (not Coming Soon)
      expect(find.text('Spaghetti Carbonara'), findsOneWidget);
      expect(find.text('Chicken Stir Fry'), findsOneWidget);
      expect(find.text('Greek Salad'), findsOneWidget);
    });
  });

  group('Recipe list display', () {
    testWidgets('Shows recipe list with stock status',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify recipe names are displayed
      expect(find.text('Spaghetti Carbonara'), findsOneWidget);
      expect(find.text('Chicken Stir Fry'), findsOneWidget);
      expect(find.text('Greek Salad'), findsOneWidget);

      // Verify stock status indicators are displayed
      expect(find.text('In Stock'), findsNWidgets(2)); // 2 recipes in stock
      expect(find.text('Out of Stock'), findsOneWidget); // 1 recipe out of stock
    });

    testWidgets('Shows add to cart buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify add to cart icons are displayed (one per recipe)
      expect(find.byIcon(Icons.add_shopping_cart), findsNWidgets(3));
    });

    testWidgets('Shows ingredient count', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify ingredient count is displayed
      expect(find.text('4 ingredients'), findsNWidgets(3)); // All have 4 ingredients
    });
  });

  group('Tab navigation', () {
    testWidgets('Can switch between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify we start on Recipes tab
      expect(find.text('Spaghetti Carbonara'), findsOneWidget);

      // Navigate to Grocery List tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Verify we're on Grocery List tab (empty state)
      expect(find.text('No grocery items yet'), findsOneWidget);
      expect(find.text('Spaghetti Carbonara'), findsNothing);

      // Navigate back to Recipes tab
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();

      // Verify we're back on Recipes tab
      expect(find.text('Spaghetti Carbonara'), findsOneWidget);
      expect(find.text('No grocery items yet'), findsNothing);
    });

    testWidgets('Both tab labels are visible', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify both tabs are in the tab bar
      expect(find.widgetWithText(Tab, 'Recipes'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Grocery List'), findsOneWidget);
    });
  });

  group('Add ingredients to grocery list', () {
    testWidgets('Can add recipe ingredients to grocery list',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Tap add to cart on first recipe (Spaghetti Carbonara)
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pumpAndSettle();

      // Verify snackbar shows confirmation
      expect(find.text('Added 4 ingredients to grocery list'), findsOneWidget);

      // Navigate to Grocery List tab
      await tester.tap(find.text('Grocery List'));
      await tester.pumpAndSettle();

      // Verify ingredients were added
      expect(find.text('Spaghetti'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Parmesan Cheese'), findsOneWidget);
      expect(find.text('Bacon'), findsOneWidget);
    });
  });

  group('Ingredient model', () {
    test('Ingredient.create generates unique ID', () {
      final ingredient1 = Ingredient.create(name: 'Test 1');
      // Add slight delay to ensure different timestamps
      final ingredient2 = Ingredient.create(name: 'Test 2');

      expect(ingredient1.id, isNotEmpty);
      expect(ingredient2.id, isNotEmpty);
      expect(ingredient1.name, equals('Test 1'));
      expect(ingredient2.name, equals('Test 2'));
    });

    test('Ingredient.copyWith creates new instance with updated fields', () {
      final original = Ingredient(id: '123', name: 'Original');
      final copied = original.copyWith(name: 'Updated');

      expect(copied.id, equals('123'));
      expect(copied.name, equals('Updated'));
      expect(original.name, equals('Original')); // Original unchanged
    });
  });

  group('Recipe model', () {
    test('Recipe.create generates unique ID with empty ingredients', () {
      final recipe = Recipe.create(name: 'Test Recipe');

      expect(recipe.id, isNotEmpty);
      expect(recipe.name, equals('Test Recipe'));
      expect(recipe.ingredients, isEmpty);
      expect(recipe.isInStock, isFalse);
    });

    test('Recipe.copyWith creates new instance with updated fields', () {
      final ingredient = Ingredient(id: '1', name: 'Ingredient 1');
      final original = Recipe(
        id: '123',
        name: 'Original',
        ingredients: [ingredient],
        isInStock: false,
      );

      final copied = original.copyWith(
        name: 'Updated',
        isInStock: true,
      );

      expect(copied.id, equals('123'));
      expect(copied.name, equals('Updated'));
      expect(copied.isInStock, isTrue);
      expect(copied.ingredients.length, equals(1));
      expect(original.name, equals('Original')); // Original unchanged
      expect(original.isInStock, isFalse); // Original unchanged
    });
  });
}
