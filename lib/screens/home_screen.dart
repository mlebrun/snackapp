import 'package:flutter/material.dart';
import '../main.dart';
import '../models/grocery_item.dart';
import 'recipe_list_screen.dart';
import 'grocery_list_screen.dart';

/// The main home screen with tab navigation.
///
/// This screen provides a tabbed interface for switching between
/// the Recipe List and Grocery List screens using a TabBar at the
/// top of the screen.
///
/// Manages shared state for recipes and grocery items, enabling
/// users to add ingredients from recipes to the grocery list.
class HomeScreen extends StatefulWidget {
  /// Creates a HomeScreen.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  /// Controller for managing tab selection.
  late TabController _tabController;

  /// Index of the currently selected tab.
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  /// Handles tab changes to track the currently selected tab.
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  /// The list of recipes.
  final List<Recipe> _recipes = [
    Recipe(
      id: '1',
      name: 'Spaghetti Carbonara',
      ingredients: [
        Ingredient(id: '1', name: 'Spaghetti'),
        Ingredient(id: '2', name: 'Eggs'),
        Ingredient(id: '3', name: 'Parmesan Cheese'),
        Ingredient(id: '4', name: 'Bacon'),
      ],
      isInStock: true,
    ),
    Recipe(
      id: '2',
      name: 'Chicken Stir Fry',
      ingredients: [
        Ingredient(id: '5', name: 'Chicken Breast'),
        Ingredient(id: '6', name: 'Bell Peppers'),
        Ingredient(id: '7', name: 'Soy Sauce'),
        Ingredient(id: '8', name: 'Garlic'),
      ],
      isInStock: false,
    ),
    Recipe(
      id: '3',
      name: 'Greek Salad',
      ingredients: [
        Ingredient(id: '9', name: 'Cucumber'),
        Ingredient(id: '10', name: 'Tomatoes'),
        Ingredient(id: '11', name: 'Feta Cheese'),
        Ingredient(id: '12', name: 'Olives'),
      ],
      isInStock: true,
    ),
  ];

  /// The list of grocery items.
  final List<GroceryItem> _groceryItems = [];

  /// Adds ingredients from a recipe to the grocery list.
  void _addIngredientsToGroceryList(Recipe recipe) {
    setState(() {
      for (final ingredient in recipe.ingredients) {
        // Check if ingredient already exists in grocery list
        final existsInList = _groceryItems.any(
          (item) => item.name.toLowerCase() == ingredient.name.toLowerCase(),
        );
        if (!existsInList) {
          _groceryItems.add(GroceryItem.create(name: ingredient.name));
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${recipe.ingredients.length} ingredients to grocery list'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Updates a recipe in the list.
  void _updateRecipe(Recipe updatedRecipe) {
    setState(() {
      final index = _recipes.indexWhere((r) => r.id == updatedRecipe.id);
      if (index != -1) {
        _recipes[index] = updatedRecipe;
      }
    });
  }

  /// Adds a grocery item to the list.
  void _addGroceryItem(GroceryItem item) {
    setState(() {
      _groceryItems.add(item);
    });
  }

  /// Updates a grocery item in the list.
  void _updateGroceryItem(int index, GroceryItem item) {
    setState(() {
      _groceryItems[index] = item;
    });
  }

  /// Deletes a grocery item from the list.
  void _deleteGroceryItem(int index) {
    final deletedItem = _groceryItems[index];
    setState(() {
      _groceryItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedItem.name} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _groceryItems.insert(index, deletedItem);
            });
          },
        ),
      ),
    );
  }

  /// Clears all grocery items from the list.
  void _clearAllGroceryItems() {
    setState(() {
      _groceryItems.clear();
    });
  }

  /// Shows a confirmation dialog for clearing all grocery items.
  ///
  /// Returns true if the user confirms the action, false otherwise.
  /// If confirmed, clears all items and shows a success snackbar.
  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Items'),
        content: const Text(
          'Are you sure you want to clear all items from your grocery list? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _clearAllGroceryItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All items cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Snack App'),
        actions: _currentTabIndex == 1
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Clear all items',
                  onPressed: _groceryItems.isEmpty ? null : _showClearAllDialog,
                ),
              ]
            : null,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recipes'),
            Tab(text: 'Grocery List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RecipeListScreen(
            recipes: _recipes,
            onAddToGroceryList: _addIngredientsToGroceryList,
            onUpdateRecipe: _updateRecipe,
          ),
          GroceryListScreen(
            items: _groceryItems,
            onAddItem: _addGroceryItem,
            onUpdateItem: _updateGroceryItem,
            onDeleteItem: _deleteGroceryItem,
          ),
        ],
      ),
    );
  }
}
