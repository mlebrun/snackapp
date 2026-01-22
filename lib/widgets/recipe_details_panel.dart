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
  /// Controller for the recipe title text field.
  late TextEditingController _titleController;

  /// Local state for the in-stock status.
  late bool _isInStock;

  /// Local state for the ingredients list.
  late List<Ingredient> _ingredients;

  @override
  void initState() {
    super.initState();
    // Initialize local state from the recipe
    _titleController = TextEditingController(text: widget.recipe.name);
    _isInStock = widget.recipe.isInStock;
    _ingredients = List.from(widget.recipe.ingredients);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Builds the updated recipe from the current local state.
  Recipe _buildUpdatedRecipe() {
    return widget.recipe.copyWith(
      name: _titleController.text.trim(),
      isInStock: _isInStock,
      ingredients: _ingredients,
    );
  }

  /// Handles the save action.
  void _handleSave() {
    widget.onSave(_buildUpdatedRecipe());
  }

  /// Handles the cancel action.
  void _handleCancel() {
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding for keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 16.0 + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Recipe',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close',
                onPressed: _handleCancel,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body with form fields
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Recipe name text field
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // In-stock status toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('In Stock'),
                      Switch(
                        value: _isInStock,
                        onChanged: (value) {
                          setState(() {
                            _isInStock = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ingredients section header
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  // Ingredients list placeholder - will be implemented in subsequent subtasks
                  if (_ingredients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No ingredients yet. Add one below!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ...List.generate(
                      _ingredients.length,
                      (index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.grey,
                        ),
                        title: Text(_ingredients[index].name),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Footer with cancel and save buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _handleCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
