import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopii/data/categories.dart';
import 'package:shopii/models/category.dart';
import 'package:shopii/models/grocery.dart';
import 'package:shopii/widgets/grocery_item.dart';
import 'package:shopii/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<GroceryItem> _groceryItems = [];
  // var _isLoading = true;
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;
  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        "shopiii-13c19-default-rtdb.firebaseio.com", 'shopping-list.json');

    final response = await http.get(url);
    if (response.statusCode >= 400) {
      // setState(() {
      //   _error = "Failed to fetch data. please try again later";
      // });
      throw Exception("Failed to fetch data. please try again later");
    }

    if (response.body == "null") {
      // setState(() {
      //   _isLoading = false;
      // });
      return [];
    }
    final List<GroceryItem> loadedItems = [];
    final Map<String, dynamic> listData = json.decode(response.body);
    for (var item in listData.entries) {
      final category = categories.entries
          .firstWhere((elt) => elt.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      // _isLoading = false;
    });
    return loadedItems;
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItemScreen(),
      ),
    );
    // _loadItems();
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https("shopiii-13c19-default-rtdb.firebaseio.com",
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Oups !!! Veillez réessayer la suppression"),
        ),
      );
      setState(() {
        _groceryItems.insert(index, item);
      });
      return;
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Grocery has been deleted"),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadedItems = _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("Oups ! no grociries in your store"),
    );
    // if (_isLoading) {
    //   content =
    // }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) {
            final item = _groceryItems[index];
            return GroceryItemScreen(item, _removeItem);
          });
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: FutureBuilder(
            future: _loadedItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("Oups ! no grociries in your store"),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, index) {
                      final item = snapshot.data![index];
                      return GroceryItemScreen(item, _removeItem);
                    });
              }
            }));
  }
}
