import 'package:flutter/material.dart';

class FullScreenPhoto extends StatelessWidget {
  final String photoUrl;

  const FullScreenPhoto({super.key, required this.photoUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo"),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Close on tap
        child: Center(
          child: InteractiveViewer(
            child: Image.network(
              photoUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
