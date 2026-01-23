import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

/// A dialog widget for adding and editing grocery items with validation.
///
/// This widget displays a form with fields for item name (required) and
/// quantity (optional). It validates that the name is not empty before
/// allowing the form to be saved.
///
/// Use the [show] static method to display this dialog and get the result.
class GroceryFormDialog extends StatefulWidget {
  /// Creates a GroceryFormDialog.
  ///
  /// The [item] parameter is optional. If provided, the dialog will be in
  /// edit mode with the fields pre-filled. If null, the dialog will be in
  /// add mode for creating a new item.
  const GroceryFormDialog({
    super.key,
    this.item,
  });

  /// The grocery item to edit, or null for creating a new item.
  final GroceryItem? item;

  /// Shows the grocery form dialog and returns the created/edited item.
  ///
  /// Returns the [GroceryItem] if the user saves, or null if they cancel.
  /// If [item] is provided, the dialog will be in edit mode.
  static Future<GroceryItem?> show(
    BuildContext context, {
    GroceryItem? item,
  }) {
    return showDialog<GroceryItem>(
      context: context,
      builder: (context) => GroceryFormDialog(item: item),
    );
  }

  @override
  State<GroceryFormDialog> createState() => _GroceryFormDialogState();
}

class _GroceryFormDialogState extends State<GroceryFormDialog> {
  /// Form key for validation.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the name text field.
  late TextEditingController _nameController;

  /// Controller for the quantity text field.
  late TextEditingController _quantityController;

  /// Whether the dialog is in edit mode.
  bool get _isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController =
        TextEditingController(text: widget.item?.quantity ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  /// Validates the name field.
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an item name';
    }
    return null;
  }

  /// Handles the save action.
  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final quantity = _quantityController.text.trim();

      GroceryItem result;
      if (_isEditMode) {
        // Update existing item
        result = widget.item!.copyWith(
          name: name,
          quantity: quantity.isNotEmpty ? quantity : null,
        );
      } else {
        // Create new item
        result = GroceryItem.create(
          name: name,
          quantity: quantity.isNotEmpty ? quantity : null,
        );
      }

      Navigator.of(context).pop(result);
    }
  }

  /// Handles the cancel action.
  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Item' : 'Add Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field (required) - inherits InputDecorationTheme from app theme
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Item Name',
                hintText: 'Enter item name',
              ),
              validator: _validateName,
              onFieldSubmitted: (_) => _handleSave(),
            ),
            const SizedBox(height: 16),
            // Quantity field (optional) - inherits InputDecorationTheme from app theme
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (optional)',
                hintText: 'e.g., 2 lbs, 1 dozen',
              ),
              onFieldSubmitted: (_) => _handleSave(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
