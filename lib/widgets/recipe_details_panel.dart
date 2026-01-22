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

  /// Controller for the add ingredient text field.
  late TextEditingController _ingredientController;

  /// Focus node for the add ingredient text field.
  late FocusNode _ingredientFocusNode;

  /// Local state for the in-stock status.
  late bool _isInStock;

  /// Local state for the ingredients list.
  late List<Ingredient> _ingredients;

  @override
  void initState() {
    super.initState();
    // Initialize local state from the recipe
    _titleController = TextEditingController(text: widget.recipe.name);
    _ingredientController = TextEditingController();
    _ingredientFocusNode = FocusNode();
    _isInStock = widget.recipe.isInStock;
    _ingredients = List.from(widget.recipe.ingredients);

    // Listen to title changes to update save button state
    _titleController.addListener(_onTitleChanged);
  }

  /// Called when the title text changes to trigger a rebuild.
  void _onTitleChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    super.dispose();
  }

  /// Returns true if the title is valid (not empty after trimming).
  bool get _isTitleValid => _titleController.text.trim().isNotEmpty;

  /// Adds an ingredient to the local ingredients list.
  void _addIngredient() {
    final trimmedName = _ingredientController.text.trim();
    if (trimmedName.isNotEmpty) {
      setState(() {
        _ingredients.add(Ingredient.create(name: trimmedName));
      });
      _ingredientController.clear();
      _ingredientFocusNode.requestFocus();
    }
  }

  /// Shows a dialog to edit an ingredient's name.
  ///
  /// The [index] parameter is the index of the ingredient in the list.
  Future<void> _editIngredient(int index) async {
    final ingredient = _ingredients[index];
    final editController = TextEditingController(text: ingredient.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Ingredient'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Ingredient Name',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(editController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    // Update ingredient if a new name was provided
    final trimmedName = newName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      setState(() {
        _ingredients[index] = ingredient.copyWith(name: trimmedName);
      });
    }
    // Note: editController is not manually disposed here because the dialog
    // manages its own lifecycle. Manual disposal can cause race conditions
    // with ongoing animations.
  }

  /// Removes an ingredient from the local ingredients list.
  ///
  /// The [index] parameter is the index of the ingredient to remove.
  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
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

  /// Dismisses the keyboard by unfocusing any active text field.
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding for keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name',
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

                  // Ingredients list
                  if (_ingredients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No ingredients yet. Add one below!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  else
                    ...List.generate(
                      _ingredients.length,
                      (index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.circle,
                          size: 8,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        title: Text(
                          _ingredients[index].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              tooltip: 'Edit ingredient',
                              onPressed: () => _editIngredient(index),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              tooltip: 'Remove ingredient',
                              onPressed: () => _removeIngredient(index),
                            ),
                          ],
                        ),
                        onTap: () => _editIngredient(index),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Add ingredient input row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientController,
                          focusNode: _ingredientFocusNode,
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Add ingredient',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10.0,
                            ),
                          ),
                          onSubmitted: (_) => _addIngredient(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add_circle),
                        tooltip: 'Add ingredient',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
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
                onPressed: _isTitleValid ? _handleSave : null,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
