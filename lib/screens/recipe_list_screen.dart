import 'package:flutter/material.dart';

/// A placeholder screen for the recipe list feature.
///
/// This screen displays a 'Coming Soon' message as the recipe list
/// functionality is not yet implemented.
///
/// Note: This screen is designed to be used within a TabBarView and does not
/// include its own AppBar since the parent HomeScreen provides one.
class RecipeListScreen extends StatelessWidget {
  /// Creates a RecipeListScreen.
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            'Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Recipe list feature is under development',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
