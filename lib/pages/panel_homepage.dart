import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aws_cat_care/services/authentication.dart';
import 'cats_page.dart'; // Import the AddCatsPage

class PanelHomePage extends StatelessWidget {
  const PanelHomePage({super.key});

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
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final docs = snapshot.data.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = docs[index].data();
                      return ListTile(
                        title: Text(user['name'] ?? user['email']),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Add Cats"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CatsPage()),
                );
              },
            ),
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
