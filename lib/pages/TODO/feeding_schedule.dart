import 'package:flutter/material.dart';

class FeedingSchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeding Schedule'),
      ),
      body: Center(
        child: Text('Feeding Schedule Page'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FeedingSchedule(),
  ));
}
