import 'package:flutter/material.dart';
import '../main.dart';

/// A panel widget for viewing and editing recipe details.
///
/// This widget is designed to be shown in a modal bottom sheet and provides
/// a comprehensive interface for managing recipe properties including title
/// editing, in-stock status toggling, and ingredient CRUD operations.
class RecipeDetailsPanel extends StatefulWidget {
  /// Creates a RecipeDetailsPanel.
  ///
  /// The [recipe] parameter is required and represents the recipe to edit.
  /// The [onSave] callback is called when the user saves changes.
  /// The [onCancel] callback is called when the user cancels editing.
  const RecipeDetailsPanel({
    super.key,
    required this.recipe,
    required this.onSave,
    required this.onCancel,
  });

  /// The recipe to edit.
  final Recipe recipe;

  /// Callback invoked when the user saves changes.
  final void Function(Recipe updatedRecipe) onSave;

  /// Callback invoked when the user cancels editing.
  final VoidCallback onCancel;

  @override
  State<RecipeDetailsPanel> createState() => _RecipeDetailsPanelState();
}

class _RecipeDetailsPanelState extends State<RecipeDetailsPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with title
          Text(
            'Recipe Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Placeholder content - will be implemented in subsequent subtasks
          Text(widget.recipe.name),
        ],
      ),
    );
  }
}
