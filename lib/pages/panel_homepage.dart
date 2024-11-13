import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aws_cat_care/services/authentication.dart';
import 'cats_page.dart';
import 'TODO/volunteers.dart';
import 'TODO/adoption_page.dart';
import 'TODO/community_forum.dart';
import 'TODO/donations_page.dart';
import 'TODO/feeding_schedule.dart';
import 'TODO/incidents_page.dart';

class PanelHomePage extends StatelessWidget {
  const PanelHomePage({super.key});

  Future<String?> _getUserName() async {
    final userId = AuthHelper.getCurrentUser()
        ?.uid; // Assuming getCurrentUser() returns the current user
    if (userId == null) return null;

    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return userDoc.data()?[
        'firstName']; // Assuming user's first name is stored as 'firstName'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<String?>(
              future: _getUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final userName = snapshot.data ?? "User";
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Welcome, $userName!",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Manage Cats"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CatsPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Manage Volunteers"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VolunteersPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Fostering & Adoption Page"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdoptionPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Community Forum"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommunityForumPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Fundraising & Donations"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonationsPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Feeding Schedule"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedingSchedule()),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Feeding Schedule"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedingSchedule()),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Incidents"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IncidentsPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Log out"),
              onPressed: () async {
                await AuthHelper.logOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
