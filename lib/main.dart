import 'package:flutter/material.dart';

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
                      final ingredientController = _getIngredientController(recipe.id);
                      return ExpansionTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Opacity(
                                opacity: recipe.isInStock ? 1.0 : 0.5,
                                child: Text(recipe.name),
                              ),
                            ),
                            Switch(
                              value: recipe.isInStock,
                              onChanged: (value) => _toggleStockStatus(index),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete recipe',
                          onPressed: () => _removeRecipe(index),
                        ),
                        children: [
                          Opacity(
                            opacity: recipe.isInStock ? 1.0 : 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ingredient list or empty placeholder
                                if (recipe.ingredients.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32.0,
                                      vertical: 8.0,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'No ingredients yet. Add one below!',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...recipe.ingredients.asMap().entries.map(
                                    (entry) {
                                      final ingredientIndex = entry.key;
                                      final ingredient = entry.value;
                                      return ListTile(
                                        contentPadding: const EdgeInsets.only(
                                          left: 32.0,
                                          right: 16.0,
                                        ),
                                        leading: const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Colors.grey,
                                        ),
                                        title: Text(ingredient.name),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.redAccent,
                                          ),
                                          tooltip: 'Remove ingredient',
                                          onPressed: () => _removeIngredient(
                                            index,
                                            ingredientIndex,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                // Add ingredient input row
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32.0,
                                    right: 16.0,
                                    top: 8.0,
                                    bottom: 16.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: ingredientController,
                                          decoration: const InputDecoration(
                                            hintText: 'Add ingredient',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 10.0,
                                            ),
                                          ),
                                          onSubmitted: (value) {
                                            _addIngredient(index, value);
                                            ingredientController.clear();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          _addIngredient(
                                            index,
                                            ingredientController.text,
                                          );
                                          ingredientController.clear();
                                        },
                                        icon: const Icon(Icons.add_circle),
                                        tooltip: 'Add ingredient',
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
