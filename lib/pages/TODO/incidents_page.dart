import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentsPage extends StatelessWidget {
  const IncidentsPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> fetchReferencedData(
      DocumentReference reference) async {
    final snapshot = await reference.get();
    return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("incidents").snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final incidents = snapshot.data.docs;

            return ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index].data();
                final reportDate = incident['ReportDate']?.toDate();
                final date = incident['date']?.toDate();
                final description = incident['description'] ?? "No description";

                return FutureBuilder(
                  future: Future.wait([
                    fetchReferencedData(incident['ReportedBy']),
                    fetchReferencedData(incident['cat']),
                    fetchReferencedData(incident['volunteer']),
                  ]),
                  builder: (context,
                      AsyncSnapshot<List<Map<String, dynamic>?>> refSnapshot) {
                    if (refSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final reportedByData = refSnapshot.data?[0];
                    final catData = refSnapshot.data?[1];
                    final volunteerData = refSnapshot.data?[2];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(Icons.report),
                        title: Text('Incident #$index'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Report Date: ${reportDate ?? 'N/A'}"),
                            Text("Incident Date: ${date ?? 'N/A'}"),
                            Text("Description: $description"),
                            Text(
                                "Vet Visit: ${incident['VetVisit'] == true ? 'Yes' : 'No'}"),
                            Text(
                                "Reported By: ${reportedByData?['name'] ?? 'Unknown'}"),
                            Text("Cat: ${catData?['name'] ?? 'Unknown'}"),
                            Text(
                                "Volunteer: ${volunteerData?['name'] ?? 'Unknown'}"),
                          ],
                        ),
                        onTap: () {
                          // Handle tap on incident (e.g., navigate to a detail page)
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add new incident
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
