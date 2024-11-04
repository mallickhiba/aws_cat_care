// cat_profile_page.dart
import 'package:flutter/material.dart';
import 'package:aws_cat_care/models/cat_model.dart' as model;

class CatProfilePage extends StatelessWidget {
  final model.Cat cat; // Use the prefix here

  const CatProfilePage({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cat.name.toString()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(cat.imageUrl.toString()),
          const SizedBox(height: 20),
          Text(
            cat.name.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Location: ${cat.breed.toString()}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
