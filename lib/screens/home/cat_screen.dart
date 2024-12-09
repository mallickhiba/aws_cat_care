import 'package:flutter/material.dart';

class CatScreen extends StatelessWidget {
  const CatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Screen'),
      ),
      body: const Center(
        child: Text('Cat Screen'),
      ),
    );
  }
}
