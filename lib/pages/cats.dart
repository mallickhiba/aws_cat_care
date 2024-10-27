import 'package:flutter/material.dart';

class Cat {
  final String name;
  final String imageUrl;
  final String location;

  Cat({required this.name, required this.imageUrl, required this.location});
}

class CatsPage extends StatelessWidget {
  final List<Cat> cats = [
    Cat(
        name: 'Cat 1',
        imageUrl: 'https://example.com/cat1.jpg',
        location: 'Location 1'),
    Cat(
        name: 'Cat 2',
        imageUrl: 'https://example.com/cat2.jpg',
        location: 'Location 2'),
    Cat(
        name: 'Cat 3',
        imageUrl: 'https://example.com/cat3.jpg',
        location: 'Location 3'),
    Cat(
        name: 'Cat 4',
        imageUrl: 'https://example.com/cat4.jpg',
        location: 'Location 4'),
    Cat(
        name: 'Cat 5',
        imageUrl: 'https://example.com/cat5.jpg',
        location: 'Location 5'),
  ];

  CatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cats'),
      ),
      body: ListView.builder(
        itemCount: cats.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.network(cats[index].imageUrl),
              title: Text(cats[index].name),
              subtitle: Text(cats[index].location),
            ),
          );
        },
      ),
    );
  }
}
