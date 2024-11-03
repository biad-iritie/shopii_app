import 'package:flutter/material.dart';
import 'package:shopii/models/grocery.dart';

class GroceryItemScreen extends StatelessWidget {
  const GroceryItemScreen(this.grocery, this.onRemove, {super.key});
  final Function(GroceryItem item) onRemove;
  final GroceryItem grocery;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(grocery.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onRemove(grocery);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Grocery has been deleted"),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(grocery.name),
        leading: Container(
          width: 24,
          height: 24,
          color: grocery.category.color,
        ),
        trailing: Text(grocery.quantity.toString()),
      ),
    );
  }
}
