import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aws_cat_care/pages/TODO/incident_detail_page.dart';

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({Key? key}) : super(key: key);

  @override
  _IncidentsPageState createState() => _IncidentsPageState();
}

class _IncidentsPageState extends State<IncidentsPage> {
  final CollectionReference incidentsCollection =
      FirebaseFirestore.instance.collection('incidents');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: incidentsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final incidents = snapshot.data?.docs ?? [];
          if (incidents.isEmpty) {
            return const Center(child: Text('No incidents found.'));
          }

          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incidentData =
                  incidents[index].data() as Map<String, dynamic>;
              final incidentId = incidents[index].id;
              return ListTile(
                title: Text(incidentData['description'] ?? 'No description'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Report Date: ${incidentData['ReportDate']?.toDate() ?? ''}"),
                    Text(
                        "Vet Visit: ${incidentData['VetVisit'] ? 'Yes' : 'No'}"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _showIncidentForm(context, incidentId, incidentData),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteIncident(incidentId),
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to the IncidentDetailPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncidentDetailPage(
                        incidentReference: incidentsCollection.doc(incidentId),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIncidentForm(context, null, {}),
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Future<void> _showIncidentForm(BuildContext context, String? incidentId,
      Map<String, dynamic> incidentData) async {
    final TextEditingController descriptionController =
        TextEditingController(text: incidentData['description'] ?? '');
    final TextEditingController dateController = TextEditingController(
        text: incidentData['date']?.toDate().toString() ?? '');
    bool vetVisit = incidentData['VetVisit'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(incidentId == null ? 'Create Incident' : 'Update Incident'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: dateController,
                decoration:
                    const InputDecoration(labelText: 'Date (yyyy-mm-dd)'),
                keyboardType: TextInputType.datetime,
              ),
              CheckboxListTile(
                title: const Text("Vet Visit"),
                value: vetVisit,
                onChanged: (value) {
                  setState(() {
                    vetVisit = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final description = descriptionController.text;
                final date = DateTime.tryParse(dateController.text);
                if (description.isNotEmpty && date != null) {
                  if (incidentId == null) {
                    _createIncident(description, date, vetVisit);
                  } else {
                    _updateIncident(incidentId, description, date, vetVisit);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(incidentId == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createIncident(
      String description, DateTime date, bool vetVisit) async {
    await incidentsCollection.add({
      'description': description,
      'date': Timestamp.fromDate(date),
      'VetVisit': vetVisit,
      'ReportDate': Timestamp.now(),
      'ReportedBy': "/users/yourUserId", // Replace with actual user reference
      'volunteer':
          "/users/yourVolunteerId", // Replace with actual volunteer reference
      'cats': "/cats/yourCatId", // Replace with actual cat reference
    });
  }

  Future<void> _updateIncident(String incidentId, String description,
      DateTime date, bool vetVisit) async {
    await incidentsCollection.doc(incidentId).update({
      'description': description,
      'date': Timestamp.fromDate(date),
      'VetVisit': vetVisit,
    });
  }

  Future<void> _deleteIncident(String incidentId) async {
    await incidentsCollection.doc(incidentId).delete();
  }
}
