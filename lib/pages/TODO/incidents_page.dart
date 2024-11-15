import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aws_cat_care/pages/TODO/incident_detail_page.dart';

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({super.key});

  @override
  State<IncidentsPage> createState() => _IncidentsPage();
}

class _IncidentsPage extends State<IncidentsPage> {
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showIncidentForm(
    BuildContext context,
    String? incidentId,
    Map<String, dynamic> incidentData,
  ) async {
    final TextEditingController descriptionController =
        TextEditingController(text: incidentData['description'] ?? '');
    final TextEditingController dateController = TextEditingController(
        text: incidentData['date'] != null
            ? (incidentData['date'] as Timestamp)
                .toDate()
                .toIso8601String()
                .split('T')[0]
            : '');

    bool vetVisit = incidentData['VetVisit'] ?? false;

    // Track selected IDs
    String? selectedReportedBy = incidentData['ReportedBy'];
    String? selectedVolunteer = incidentData['volunteer'];
    String? selectedCat = incidentData['cats'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                  incidentId == null ? 'Create Incident' : 'Update Incident'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Description TextField
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    // Date TextField
                    TextField(
                      controller: dateController,
                      decoration:
                          const InputDecoration(labelText: 'Date (yyyy-mm-dd)'),
                      keyboardType: TextInputType.datetime,
                    ),
                    // Vet Visit Checkbox
                    CheckboxListTile(
                      title: const Text("Vet Visit"),
                      value: vetVisit,
                      onChanged: (value) {
                        setModalState(() {
                          vetVisit = value ?? false;
                        });
                      },
                    ),
                    // Dropdown for ReportedBy
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final users = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          value: selectedReportedBy,
                          decoration:
                              const InputDecoration(labelText: 'Reported By'),
                          items: users.map((user) {
                            final userData =
                                user.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: user.id,
                              child: Text(userData['name'] ?? 'Unnamed User'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedReportedBy = value;
                            });
                          },
                        );
                      },
                    ),
                    // Dropdown for Volunteer
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final users = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          value: selectedVolunteer,
                          decoration:
                              const InputDecoration(labelText: 'Volunteer'),
                          items: users.map((user) {
                            final userData =
                                user.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: user.id,
                              child: Text(userData['name'] ?? 'Unnamed User'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedVolunteer = value;
                            });
                          },
                        );
                      },
                    ),
                    // Dropdown for Cat
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('cats')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final cats = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          value: selectedCat,
                          decoration: const InputDecoration(labelText: 'Cat'),
                          items: cats.map((cat) {
                            final catData = cat.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: cat.id,
                              child: Text(catData['name'] ?? 'Unnamed Cat'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedCat = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
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
                        _createIncident(
                          description,
                          date,
                          vetVisit,
                          selectedReportedBy,
                          selectedVolunteer,
                          selectedCat,
                        );
                      } else {
                        _updateIncident(
                          incidentId,
                          description,
                          date,
                          vetVisit,
                          selectedReportedBy,
                          selectedVolunteer,
                          selectedCat,
                        );
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
      },
    );
  }

  Future<void> _createIncident(String description, DateTime date, bool vetVisit,
      String? reportedBy, String? volunteer, String? cat) async {
    await incidentsCollection.add({
      'description': description,
      'date': Timestamp.fromDate(date),
      'VetVisit': vetVisit,
      'ReportDate': Timestamp.now(),
      'ReportedBy': reportedBy,
      'volunteer': volunteer,
      'cats': cat,
    });
  }

  Future<void> _updateIncident(
      String incidentId,
      String description,
      DateTime date,
      bool vetVisit,
      String? reportedBy,
      String? volunteer,
      String? cat) async {
    await incidentsCollection.doc(incidentId).update({
      'description': description,
      'date': Timestamp.fromDate(date),
      'VetVisit': vetVisit,
      'ReportedBy': reportedBy,
      'volunteer': volunteer,
      'cats': cat,
    });
  }

  Future<void> _deleteIncident(String incidentId) async {
    await incidentsCollection.doc(incidentId).delete();
  }
}
