import 'package:flutter/material.dart';

class AdoptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adoption Page'),
      ),
      body: ListView(
        children: <Widget>[
          _buildAdoptionCard('Cat 1', 'assets/images/cat1.jpg'),
          _buildAdoptionCard('Cat 2', 'assets/images/cat2.jpg'),
          _buildAdoptionCard('Cat 3', 'assets/images/cat3.jpg'),
        ],
      ),
    );
  }

  Widget _buildAdoptionCard(String name, String imagePath) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Image.asset(imagePath),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle adoption logic here
              },
              child: Text('Adopt Me'),
            ),
          ),
        ],
      ),
    );
  }
}
