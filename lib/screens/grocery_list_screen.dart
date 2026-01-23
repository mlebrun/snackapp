import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../utils/animation_utils.dart';
import '../widgets/grocery_item_tile.dart';
import '../widgets/grocery_form_dialog.dart';

/// A screen that displays a list of grocery items with full CRUD functionality.
///
/// This screen allows users to:
/// - View all grocery items in a scrollable list
/// - Add new items via a floating action button
/// - Edit existing items by tapping on them
/// - Delete items using the delete button on each tile
///
/// Note: This screen is designed to be used within a TabBarView and does not
/// include its own AppBar since the parent HomeScreen provides one.
class GroceryListScreen extends StatelessWidget {
  /// Creates a GroceryListScreen.
  const GroceryListScreen({
    super.key,
    required this.items,
    required this.onAddItem,
    required this.onUpdateItem,
    required this.onDeleteItem,
  });

  /// The list of grocery items to display.
  final List<GroceryItem> items;

  /// Callback when a new item is added.
  final void Function(GroceryItem item) onAddItem;

  /// Callback when an item is updated.
  final void Function(int index, GroceryItem item) onUpdateItem;

  /// Callback when an item is deleted.
  final void Function(int index) onDeleteItem;

  /// Adds a new grocery item to the list.
  ///
  /// Opens the [GroceryFormDialog] in add mode and adds the returned
  /// item to the list if the user saves.
  Future<void> _addItem(BuildContext context) async {
    final newItem = await GroceryFormDialog.show(context);
    if (newItem != null) {
      onAddItem(newItem);
    }
  }

  /// Edits an existing grocery item.
  ///
  /// Opens the [GroceryFormDialog] in edit mode with the item's current
  /// values pre-filled. Updates the item in the list if the user saves.
  Future<void> _editItem(BuildContext context, int index) async {
    final updatedItem = await GroceryFormDialog.show(
      context,
      item: items[index],
    );
    if (updatedItem != null) {
      onUpdateItem(index, updatedItem);
    }
  }

  /// Builds the empty state widget shown when there are no items.
  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No grocery items yet',
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

  /// Builds the list view of grocery items.
  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GroceryItemTile(
          item: item,
          onTap: () => _editItem(context, index),
          onDelete: () => onDeleteItem(index),
        ).animateEntrance(index: index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: This screen is designed to be used within a TabBarView and does not
    // include its own AppBar since the parent HomeScreen provides one.
    return Scaffold(
      body: items.isEmpty ? _buildEmptyState(context) : _buildListView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context),
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
