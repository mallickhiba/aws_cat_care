import 'package:flutter/material.dart';

class PanelDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Dashboard'),
      ),
      body: Center(
        child: Text('Welcome to the Panel Dashboard!'),
      ),
    );
  }
}
