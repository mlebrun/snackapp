import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../widgets/grocery_item_tile.dart';
import '../widgets/grocery_form_dialog.dart';

/// A screen that displays a list of grocery items with full CRUD functionality.
///
/// This screen allows users to:
/// - View all grocery items in a scrollable list
/// - Add new items via a floating action button
/// - Edit existing items by tapping on them
/// - Delete items using the delete button on each tile
class GroceryListScreen extends StatefulWidget {
  /// Creates a GroceryListScreen.
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen>
    with AutomaticKeepAliveClientMixin {
  /// The list of grocery items.
  final List<GroceryItem> _items = [];

  @override
  bool get wantKeepAlive => true;

  /// Adds a new grocery item to the list.
  ///
  /// Opens the [GroceryFormDialog] in add mode and adds the returned
  /// item to the list if the user saves.
  Future<void> _addItem() async {
    final newItem = await GroceryFormDialog.show(context);
    if (newItem != null) {
      setState(() {
        _items.add(newItem);
      });
    }
  }

  /// Edits an existing grocery item.
  ///
  /// Opens the [GroceryFormDialog] in edit mode with the item's current
  /// values pre-filled. Updates the item in the list if the user saves.
  Future<void> _editItem(int index) async {
    final updatedItem = await GroceryFormDialog.show(
      context,
      item: _items[index],
    );
    if (updatedItem != null) {
      setState(() {
        _items[index] = updatedItem;
      });
    }
  }

  /// Deletes a grocery item from the list.
  ///
  /// Removes the item at the given index and shows a snackbar with
  /// an undo option.
  void _deleteItem(int index) {
    final deletedItem = _items[index];
    setState(() {
      _items.removeAt(index);
    });

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedItem.name} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _items.insert(index, deletedItem);
            });
          },
        ),
      ),
    );
  }

  /// Builds the empty state widget shown when there are no items.
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No grocery items yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add one!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list view of grocery items.
  Widget _buildListView() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return GroceryItemTile(
          item: item,
          onTap: () => _editItem(index),
          onDelete: () => _deleteItem(index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Required for AutomaticKeepAliveClientMixin
    super.build(context);

    // Note: This screen is designed to be used within a TabBarView and does not
    // include its own AppBar since the parent HomeScreen provides one.
    return Scaffold(
      body: _items.isEmpty ? _buildEmptyState() : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
