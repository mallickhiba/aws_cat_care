import 'package:flutter/material.dart';
import 'package:aws_cat_care/pages/cats_page.dart';
import 'package:aws_cat_care/pages/panel_homepage.dart';
import 'package:aws_cat_care/pages/TODO/incidents_page.dart';

class PanelBottomNavBar extends StatefulWidget {
  const PanelBottomNavBar({super.key});

  @override
  State<PanelBottomNavBar> createState() {
    return _PanelBottomNavBar();
  }
}

class _PanelBottomNavBar extends State<PanelBottomNavBar> {
  int _selectedIndex = 0; // Track the currently selected tab index

  // List of pages that each tab should navigate to
  final List<Widget> _pages = [
    const PanelHomePage(),
    const CatsPage(),
    const IncidentsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the currently selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Set the selected tab
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
        ],
        onTap: _onItemTapped, // Handle tab selection
      ),
    );
  }
}
