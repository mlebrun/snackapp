import 'package:flutter/material.dart';
import 'widgets/recipe_details_panel.dart';

/// Represents an ingredient within a recipe.
class Ingredient {
  final String id;
  final String name;

  Ingredient({required this.id, required this.name});

  /// Creates a new Ingredient with a unique ID.
  factory Ingredient.create({required String name}) {
    return Ingredient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
  }

  /// Creates a copy of this Ingredient with the given fields replaced.
  Ingredient copyWith({String? id, String? name}) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snack Recipes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Snack Recipes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Recipe> _recipes = [];
  final TextEditingController _textController = TextEditingController();
  final Map<String, TextEditingController> _ingredientControllers = {};

  /// Gets or creates a TextEditingController for a recipe's ingredient input.
  TextEditingController _getIngredientController(String recipeId) {
    return _ingredientControllers.putIfAbsent(
      recipeId,
      () => TextEditingController(),
    );
  }

  void _addRecipe() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _recipes.add(Recipe.create(name: text));
      });
      _textController.clear();
    }
  }

  void _removeRecipe(int index) {
    final recipeId = _recipes[index].id;
    setState(() {
      _recipes.removeAt(index);
    });
    // Clean up the ingredient controller for this recipe
    _ingredientControllers[recipeId]?.dispose();
    _ingredientControllers.remove(recipeId);
  }

  void _toggleStockStatus(int index) {
    setState(() {
      _recipes[index].isInStock = !_recipes[index].isInStock;
    });
  }

  void _addIngredient(int recipeIndex, String name) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      setState(() {
        _recipes[recipeIndex].ingredients.add(
          Ingredient.create(name: trimmedName),
        );
      });
    }
  }

  void _removeIngredient(int recipeIndex, int ingredientIndex) {
    setState(() {
      _recipes[recipeIndex].ingredients.removeAt(ingredientIndex);
    });
  }

  /// Opens the recipe details panel for editing a recipe.
  ///
  /// Shows a modal bottom sheet with the RecipeDetailsPanel widget,
  /// allowing the user to edit the recipe title, in-stock status,
  /// and ingredients.
  void _openRecipeDetails(BuildContext context, int recipeIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RecipeDetailsPanel(
        recipe: _recipes[recipeIndex],
        onSave: (updatedRecipe) {
          setState(() {
            _recipes[recipeIndex] = updatedRecipe;
          });
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    for (final controller in _ingredientControllers.values) {
      controller.dispose();
    }
    _ingredientControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: _recipes.isEmpty
                ? const Center(
                    child: Text('No recipes yet. Add one below!'),
                  )
                : ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return ListTile(
                        onTap: () => _openRecipeDetails(context, index),
                        title: Opacity(
                          opacity: recipe.isInStock ? 1.0 : 0.5,
                          child: Text(recipe.name),
                        ),
                        subtitle: Text(
                          recipe.ingredients.isEmpty
                              ? 'No ingredients'
                              : '${recipe.ingredients.length} ingredient${recipe.ingredients.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete recipe',
                              onPressed: () => _removeRecipe(index),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter recipe name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addRecipe(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addRecipe,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add recipe',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
