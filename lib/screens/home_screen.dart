import 'package:flutter/material.dart';
import 'recipe_list_screen.dart';
import 'grocery_list_screen.dart';

/// The main home screen with tab navigation.
///
/// This screen provides a tabbed interface for switching between
/// the Recipe List and Grocery List screens using a TabBar at the
/// top of the screen.
///
/// Uses [DefaultTabController] for simple tab state management without
/// requiring a separate StatefulWidget.
class HomeScreen extends StatelessWidget {
  /// Creates a HomeScreen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Snack App'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recipes'),
              Tab(text: 'Grocery List'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RecipeListScreen(),
            GroceryListScreen(),
          ],
        ),
      ),
    );
  }
}
