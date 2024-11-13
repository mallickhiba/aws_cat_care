import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteersPage extends StatelessWidget {
  const VolunteersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteers'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Welcome to the Volunteers Page!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final docs = snapshot.data.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = docs[index].data();

                      // Convert timestamps to readable DateTime if necessary
                      final lastSeen = user['lastSeen']?.toDate();
                      final lastLogin = user['last_login']?.toDate();

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title:
                              Text(user['name'] ?? user['email'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Role: ${user['role'] ?? 'N/A'}"),
                              Text("Email: ${user['email'] ?? 'N/A'}"),
                              Text(
                                  "Build Number: ${user['buildNumber'] ?? 'N/A'}"),
                              Text(
                                  "Created At: ${DateTime.fromMillisecondsSinceEpoch(user['created_at']).toLocal()}"),
                              if (lastSeen != null)
                                Text("Last Seen: $lastSeen"),
                              if (lastLogin != null)
                                Text("Last Login: $lastLogin"),
                              if (user['photoURL'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.network(
                                    user['photoURL'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
