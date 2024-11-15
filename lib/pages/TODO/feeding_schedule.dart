import 'package:flutter/material.dart';

class FeedingSchedule extends StatelessWidget {
  const FeedingSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Schedule'),
      ),
      body: const Center(
        child: Text('Feeding Schedule Page'),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: FeedingSchedule(),
  ));
}
