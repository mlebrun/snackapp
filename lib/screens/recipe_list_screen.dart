import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/recipe_details_panel.dart';

/// A screen that displays a list of recipes with in-stock/out-of-stock status.
///
/// This screen allows users to:
/// - View all recipes with their stock status
/// - Tap a recipe to view and edit its details
/// - Add recipe ingredients to the grocery list
///
/// Note: This screen is designed to be used within a TabBarView and does not
/// include its own AppBar since the parent HomeScreen provides one.
class RecipeListScreen extends StatelessWidget {
  /// Creates a RecipeListScreen.
  const RecipeListScreen({
    super.key,
    required this.recipes,
    required this.onAddToGroceryList,
    required this.onUpdateRecipe,
  });

  /// The list of recipes to display.
  final List<Recipe> recipes;

  /// Callback when user wants to add ingredients to grocery list.
  final void Function(Recipe recipe) onAddToGroceryList;

  /// Callback when a recipe is updated.
  final void Function(Recipe recipe) onUpdateRecipe;

  /// Opens the recipe details panel in a bottom sheet.
  void _openRecipeDetails(BuildContext context, Recipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: RecipeDetailsPanel(
            recipe: recipe,
            onSave: (updatedRecipe) {
              onUpdateRecipe(updatedRecipe);
              Navigator.of(context).pop();
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  /// Builds the empty state widget shown when there are no recipes.
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No recipes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Recipes will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a list tile for a recipe.
  Widget _buildRecipeTile(BuildContext context, Recipe recipe) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.restaurant,
          color: recipe.isInStock ? Colors.green : Colors.red,
        ),
        title: Text(
          recipe.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: recipe.isInStock
                    ? Colors.green.withAlpha(25)
                    : Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                recipe.isInStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 12,
                  color: recipe.isInStock ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${recipe.ingredients.length} ingredients',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              tooltip: 'Add ingredients to grocery list',
              onPressed: () => onAddToGroceryList(recipe),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _openRecipeDetails(context, recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return _buildEmptyState();
    }

    // Create sorted copy for display - In Stock recipes appear before Out of Stock
    final sortedRecipes = List<Recipe>.from(recipes)
      ..sort((a, b) {
        // In Stock (true) comes before Out of Stock (false)
        // true = 0, false = 1, so sort ascending
        return (a.isInStock ? 0 : 1).compareTo(b.isInStock ? 0 : 1);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedRecipes.length,
      itemBuilder: (context, index) =>
          _buildRecipeTile(context, sortedRecipes[index]),
    );
  }
}
