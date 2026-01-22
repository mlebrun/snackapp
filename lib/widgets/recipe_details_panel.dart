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

  /// Controller for the add ingredient quantity text field.
  late TextEditingController _ingredientQuantityController;

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
    _ingredientQuantityController = TextEditingController();
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
    _ingredientQuantityController.dispose();
    _ingredientFocusNode.dispose();
    super.dispose();
  }

  /// Returns true if the title is valid (not empty after trimming).
  bool get _isTitleValid => _titleController.text.trim().isNotEmpty;

  /// Adds an ingredient to the local ingredients list.
  ///
  /// Uses the name from [_ingredientController] and optional quantity from
  /// [_ingredientQuantityController]. Clears both fields after adding.
  void _addIngredient() {
    final trimmedName = _ingredientController.text.trim();
    final trimmedQuantity = _ingredientQuantityController.text.trim();
    if (trimmedName.isNotEmpty) {
      setState(() {
        _ingredients.add(Ingredient.create(
          name: trimmedName,
          quantity: trimmedQuantity.isNotEmpty ? trimmedQuantity : null,
        ));
      });
      _ingredientController.clear();
      _ingredientQuantityController.clear();
      _ingredientFocusNode.requestFocus();
    }
  }

  /// Shows a dialog to edit an ingredient's name and quantity.
  ///
  /// The [index] parameter is the index of the ingredient in the list.
  Future<void> _editIngredient(int index) async {
    final ingredient = _ingredients[index];
    final nameController = TextEditingController(text: ingredient.name);
    final quantityController =
        TextEditingController(text: ingredient.quantity ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field (required)
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Ingredient Name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'quantity': quantityController.text,
                });
              },
            ),
            const SizedBox(height: 16),
            // Quantity field (optional)
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity (optional)',
                hintText: 'e.g., 2 lbs, 1 dozen',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'quantity': quantityController.text,
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop({
              'name': nameController.text,
              'quantity': quantityController.text,
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    // Update ingredient if a valid result was provided
    if (result != null) {
      final trimmedName = result['name']?.trim();
      final trimmedQuantity = result['quantity']?.trim();
      if (trimmedName != null && trimmedName.isNotEmpty) {
        setState(() {
          _ingredients[index] = ingredient.copyWith(
            name: trimmedName,
            quantity: trimmedQuantity?.isNotEmpty == true ? trimmedQuantity : null,
          );
        });
      }
    }
    // Note: Controllers are not manually disposed here because the dialog
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
                      (index) {
                        final ingredient = _ingredients[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.grey,
                          ),
                          title: Text(
                            ingredient.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: ingredient.quantity != null &&
                                  ingredient.quantity!.isNotEmpty
                              ? Text(
                                  ingredient.quantity!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                tooltip: 'Edit ingredient',
                                onPressed: () => _editIngredient(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Remove ingredient',
                                onPressed: () => _removeIngredient(index),
                              ),
                            ],
                          ),
                          onTap: () => _editIngredient(index),
                        );
                      },
                    ),
                  const SizedBox(height: 8),

                  // Add ingredient input row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _ingredientController,
                          focusNode: _ingredientFocusNode,
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
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
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _ingredientQuantityController,
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Qty (optional)',
                            border: OutlineInputBorder(),
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
