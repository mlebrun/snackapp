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

  Recipe({required this.id, required this.name, List<Ingredient>? ingredients})
      : ingredients = ingredients ?? [];

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
    setState(() {
      _recipes.removeAt(index);
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
                        title: Text(recipe.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeRecipe(index),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
