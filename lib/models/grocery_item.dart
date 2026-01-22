/// Represents a grocery item in the shopping list.
class GroceryItem {
  final String id;
  final String name;
  final String? quantity;
  bool isChecked;

  GroceryItem({
    required this.id,
    required this.name,
    this.quantity,
    this.isChecked = false,
  });

  /// Creates a new GroceryItem with a unique ID.
  factory GroceryItem.create({required String name, String? quantity}) {
    return GroceryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
    );
  }

  /// Creates a copy of this GroceryItem with the given fields replaced.
  GroceryItem copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? isChecked,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
