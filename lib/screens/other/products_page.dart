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
  bool isAdmin = true; // Set this based on the user's role

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
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.food_bank;
      case 'medicine':
        return Icons.medical_services;
      case 'carrier':
        return Icons.pets_outlined;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Products'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddProductDialog(context),
              tooltip: 'Add Product',
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: products.isEmpty
            ? const Center(
                child: Text(
                  "No products available.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getCategoryIcon(product['category']),
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              if (isAdmin)
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.grey),
                                  onPressed: () =>
                                      _showEditProductDialog(context, product),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${product['category']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location: ${product['location']} - ${product['campus']} Campus',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Required: ${product['required'] ? 'Yes' : 'No'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Qty: ${product['quantity']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Price: Rs. ${product['price']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    _showProductDialog(context, null);
  }

  void _showEditProductDialog(
      BuildContext context, Map<String, dynamic> product) {
    _showProductDialog(context, product);
  }

  void _showProductDialog(BuildContext context, Map<String, dynamic>? product) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController =
        TextEditingController(text: product?['price']?.toString() ?? '');
    final locationController =
        TextEditingController(text: product?['location'] ?? '');
    final quantityController =
        TextEditingController(text: product?['quantity']?.toString() ?? '');
    bool isRequired = product?['required'] ?? false;

    String selectedCategory = product?['category'] ?? 'Food';
    List<String> categories = ['Food', 'Medicine', 'Carrier'];
    String selectedCampus = product?['campus'] ?? 'Main';
    List<String> campuses = ['Main', 'City'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                product == null ? 'Add New Product' : 'Edit Product',
                style: const TextStyle(color: Colors.deepPurple),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Product Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: categories
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCampus,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedCampus = newValue!;
                        });
                      },
                      items: campuses
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: "Campus",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: "Price",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: "Quantity",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Required:"),
                        Switch(
                          value: isRequired,
                          onChanged: (value) {
                            setDialogState(() {
                              isRequired = value;
                            });
                          },
                        ),
                      ],
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
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        quantityController.text.isNotEmpty) {
                      if (product == null) {
                        _addProduct(
                          nameController.text,
                          selectedCategory,
                          selectedCampus,
                          double.parse(priceController.text),
                          locationController.text,
                          int.parse(quantityController.text),
                          isRequired,
                        );
                      } else {
                        _updateProduct(
                          product['id'],
                          nameController.text,
                          selectedCategory,
                          selectedCampus,
                          double.parse(priceController.text),
                          locationController.text,
                          int.parse(quantityController.text),
                          isRequired,
                        );
                      }
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("All fields are required!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(product == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addProduct(
    String name,
    String category,
    String campus,
    double price,
    String location,
    int quantity,
    bool required,
  ) {
    FirebaseFirestore.instance.collection('products').add({
      'name': name,
      'category': category,
      'campus': campus,
      'price': price,
      'location': location,
      'quantity': quantity,
      'required': required,
    }).then((docRef) {
      log("Product added successfully with ID: ${docRef.id}");
      fetchProducts().then((data) {
        setState(() {
          products = data;
        });
      });
    }).catchError((error) {
      log("Failed to add product: $error");
    });
  }

  void _updateProduct(
    String productId,
    String name,
    String category,
    String campus,
    double price,
    String location,
    int quantity,
    bool required,
  ) {
    FirebaseFirestore.instance.collection('products').doc(productId).update({
      'name': name,
      'category': category,
      'campus': campus,
      'price': price,
      'location': location,
      'quantity': quantity,
      'required': required,
    }).then((_) {
      log("Product updated successfully with ID: $productId");
      fetchProducts().then((data) {
        setState(() {
          products = data;
        });
      });
    }).catchError((error) {
      log("Failed to update product: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update product."),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}
