import 'package:flutter/material.dart';

class VolunteerBottomNavBar extends StatelessWidget {
  const VolunteerBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: 'Profile'),
      ],
      onTap: (index) {
        // Handle volunteer navigation
      },
    );
  }
}
