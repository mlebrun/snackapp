import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/animation_utils.dart';
import '../widgets/recipe_details_panel.dart';

/// A screen that displays a list of recipes with in-stock/out-of-stock status.
///
/// This screen allows users to:
/// - View all recipes with their stock status
/// - Add new recipes via a floating action button
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
    required this.onAddRecipe,
    required this.onAddToGroceryList,
    required this.onUpdateRecipe,
  });

  /// The list of recipes to display.
  final List<Recipe> recipes;

  /// Callback when user wants to add a new recipe.
  final VoidCallback onAddRecipe;

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
  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add one!',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a list tile for a recipe.
  Widget _buildRecipeTile(BuildContext context, Recipe recipe, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use M3 Expressive colorScheme tokens for status colors:
    // - primaryContainer/onPrimaryContainer for "In Stock"
    // - errorContainer/onErrorContainer for "Out of Stock"
    final statusBackgroundColor = recipe.isInStock
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;
    final statusForegroundColor = recipe.isInStock
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;
    final iconColor = recipe.isInStock
        ? colorScheme.primary
        : colorScheme.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.restaurant,
          color: iconColor,
        ),
        title: Text(
          recipe.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Container(
              // Expressive pill shape with increased padding
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusBackgroundColor,
                // More expressive pill shape with larger radius
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                recipe.isInStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 12,
                  color: statusForegroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${recipe.ingredients.length} ingredients',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
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
            Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
          ],
        ),
        onTap: () => _openRecipeDetails(context, recipe),
      ),
    ).animateEntrance(index: index);
  }

  /// Builds the list view of recipes.
  Widget _buildListView(BuildContext context) {
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
          _buildRecipeTile(context, sortedRecipes[index], index),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: This screen is designed to be used within a TabBarView and does not
    // include its own AppBar since the parent HomeScreen provides one.
    return Scaffold(
      body: recipes.isEmpty ? _buildEmptyState(context) : _buildListView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddRecipe,
        tooltip: 'Add recipe',
        child: const Icon(Icons.add),
      ),
    );
  }
}
