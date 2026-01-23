import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

/// A list tile widget for displaying a grocery item with edit and delete actions.
///
/// This widget displays the grocery item's name as the title, with an optional
/// quantity shown as a subtitle. It provides a delete button in the trailing
/// position and supports tap-to-edit functionality.
class GroceryItemTile extends StatelessWidget {
  /// Creates a GroceryItemTile.
  ///
  /// The [item] parameter is required and represents the grocery item to display.
  /// The [onTap] callback is called when the tile is tapped (for editing).
  /// The [onDelete] callback is called when the delete button is pressed.
  const GroceryItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  /// The grocery item to display.
  final GroceryItem item;

  /// Callback invoked when the tile is tapped (for editing).
  final VoidCallback onTap;

  /// Callback invoked when the delete button is pressed.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key(item.id),
      onTap: onTap,
      title: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          decoration: item.isChecked ? TextDecoration.lineThrough : null,
          color: item.isChecked ? Theme.of(context).colorScheme.outline : null,
        ),
      ),
      subtitle: item.quantity != null && item.quantity!.isNotEmpty
          ? Text(
              item.quantity!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            tooltip: 'Delete item',
            onPressed: onDelete,
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
    );
  }
}
