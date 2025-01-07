import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts().then((data) {
      setState(() {
        products = data;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection('products').get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index]['name']),
            subtitle: Text(
                '${products[index]['category']} -  ${products[index]['campus']} Campus -  ${products[index]['location']}'),
            trailing: Text('Qty: ${products[index]['quantity']}'),
          );
        },
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final locationController = TextEditingController();
    final quantityController = TextEditingController();

    String selectedCategory = 'Food';
    List<String> categories = ['Food', 'Medicine', 'Carrier'];
    String selectedCampus = 'Main';
    List<String> campuses = ['Main', 'City'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Product Name"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  items:
                      categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration:
                      const InputDecoration(hintText: "Select Category"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCampus,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCampus = newValue!;
                    });
                  },
                  items: campuses.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(hintText: "Select Campus"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(hintText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(hintText: "Location"),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(hintText: "Quantity"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addProduct(
                  nameController.text,
                  selectedCategory,
                  selectedCampus,
                  double.parse(priceController.text),
                  locationController.text,
                  int.parse(quantityController.text),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addProduct(String name, String category, String campus, double price,
      String location, int quantity) {
    FirebaseFirestore.instance.collection('products').add({
      'name': name,
      'category': category,
      'campus': campus,
      'price': price,
      'location': location,
      'quantity': quantity,
    }).then((docRef) {
      log("Product added successfully with ID: ${docRef.id}");
    }).catchError((error) {
      log("Failed to add product: $error");
    });
  }
}
