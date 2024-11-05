// import 'package:aws_cat_care/pages/cat_profile.dart';
// import 'package:flutter/material.dart';

// class Cat {
//   final String name;
//   final String imageUrl;
//   final String breed;

//   Cat({required this.name, required this.imageUrl, required this.breed});
// }

// class CatsPage extends StatelessWidget {
//   final List<Cat> cats = [
//     Cat(
//         name: 'Cat 1',
//         imageUrl: 'https://example.com/cat1.jpg',
//         breed: 'breed 1'),
//     Cat(
//         name: 'Cat 2',
//         imageUrl: 'https://example.com/cat2.jpg',
//         breed: 'breed 2'),
//     Cat(
//         name: 'Cat 3',
//         imageUrl: 'https://example.com/cat3.jpg',
//         breed: 'breed 3'),
//     Cat(
//         name: 'Cat 4',
//         imageUrl: 'https://example.com/cat4.jpg',
//         breed: 'breed 4'),
//     Cat(
//         name: 'Cat 5',
//         imageUrl: 'https://example.com/cat5.jpg',
//         breed: 'breed 5'),
//   ];

//   CatsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cats'),
//       ),
//       body: ListView.builder(
//         itemCount: cats.length,
//         itemBuilder: (context, index) {
//           return Card(
//             child: ListTile(
//               leading: Image.network(cats[index].imageUrl),
//               title: Text(cats[index].name),
//               subtitle: Text(cats[index].breed),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CatProfilePage(cat: cats[index]),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
