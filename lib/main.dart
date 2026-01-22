import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// Represents an ingredient within a recipe.
class Ingredient {
  final String id;
  final String name;
  final String? quantity;

  Ingredient({required this.id, required this.name, this.quantity});

  /// Creates a new Ingredient with a unique ID.
  factory Ingredient.create({required String name, String? quantity}) {
    return Ingredient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
    );
  }

  /// Creates a copy of this Ingredient with the given fields replaced.
  Ingredient copyWith({String? id, String? name, String? quantity}) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Represents a recipe containing a list of ingredients.
class Recipe {
  final String id;
  final String name;
  final List<Ingredient> ingredients;
  bool isInStock;

  Recipe({
    required this.id,
    required this.name,
    List<Ingredient>? ingredients,
    this.isInStock = false,
  }) : ingredients = ingredients ?? [];

  /// Creates a new Recipe with a unique ID.
  factory Recipe.create({required String name}) {
    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
  }

  /// Creates a copy of this Recipe with the given fields replaced.
  Recipe copyWith({
    String? id,
    String? name,
    List<Ingredient>? ingredients,
    bool? isInStock,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      ingredients: ingredients ?? List.from(this.ingredients),
      isInStock: isInStock ?? this.isInStock,
    );
  }
}

void main() {
  runApp(const MyApp());
}

/// The root widget of the Snack App.
///
/// Configures the app-wide theme using Material Design 3 with a deep purple
/// color scheme and sets up [HomeScreen] as the home page.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snack App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
