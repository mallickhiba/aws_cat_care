import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentDetailPage extends StatefulWidget {
  final DocumentReference? incidentReference;

  const IncidentDetailPage({super.key, this.incidentReference});

  @override
  State<IncidentDetailPage> createState() => _IncidentDetailPage();
}

class _IncidentDetailPage extends State<IncidentDetailPage> {
  final _formKey = GlobalKey<FormState>();

  bool isEditMode = false;
  DateTime? reportDate;
  DateTime? incidentDate;
  String description = '';
  bool vetVisit = false;
  String reportedBy = 'Unknown';
  String catName = 'Unknown';
  String volunteerName = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadIncidentData();
  }

  Future<void> _loadIncidentData() async {
    if (widget.incidentReference != null) {
      final snapshot = await widget.incidentReference!.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          reportDate = data['ReportDate']?.toDate();
          incidentDate = data['date']?.toDate();
          description = data['description'] ?? '';
          vetVisit = data['VetVisit'] ?? false;
        });

        // Fetch referenced data for ReportedBy, Cats, and Volunteer
        await _fetchReferencedData(data);
      }
    }
  }

  Future<void> _fetchReferencedData(Map<String, dynamic> data) async {
    final reportedByRef = data['ReportedBy'] as DocumentReference?;
    final catRef = data['cats'] as DocumentReference?;
    final volunteerRef = data['volunteer'] as DocumentReference?;

    if (reportedByRef != null) {
      final reportedBySnapshot = await reportedByRef.get();
      setState(() {
        reportedBy =
            (reportedBySnapshot.data() as Map<String, dynamic>?)?['name'] ??
                'Unknown';
      });
    }

    if (catRef != null) {
      final catSnapshot = await catRef.get();
      setState(() {
        catName =
            (catSnapshot.data() as Map<String, dynamic>?)?['name'] ?? 'Unknown';
      });
    }

    if (volunteerRef != null) {
      final volunteerSnapshot = await volunteerRef.get();
      setState(() {
        volunteerName =
            (volunteerSnapshot.data() as Map<String, dynamic>?)?['name'] ??
                'Unknown';
      });
    }
  }

  Future<void> _saveIncident() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final incidentData = {
        'ReportDate': reportDate,
        'date': incidentDate,
        'description': description,
        'VetVisit': vetVisit,
      };

      if (widget.incidentReference != null) {
        await widget.incidentReference!.update(incidentData);
        ScaffoldMessenger.of(context.mounted as BuildContext).showSnackBar(
          const SnackBar(content: Text('Incident updated successfully')),
        );
      }

      setState(() {
        isEditMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.incidentReference != null
            ? 'Incident Details'
            : 'New Incident'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditMode) {
                _saveIncident();
              } else {
                setState(() {
                  isEditMode = true;
                });
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ListTile(
                title: const Text('Report Date'),
                subtitle: isEditMode
                    ? TextFormField(
                        initialValue: reportDate?.toLocal().toString() ?? '',
                        decoration:
                            const InputDecoration(labelText: 'Report Date'),
                        onSaved: (value) {
                          reportDate = DateTime.parse(value!);
                        },
                      )
                    : Text(reportDate?.toLocal().toString() ?? 'N/A'),
              ),
              ListTile(
                title: const Text('Incident Date'),
                subtitle: isEditMode
                    ? TextFormField(
                        initialValue: incidentDate?.toLocal().toString() ?? '',
                        decoration:
                            const InputDecoration(labelText: 'Incident Date'),
                        onSaved: (value) {
                          incidentDate = DateTime.parse(value!);
                        },
                      )
                    : Text(incidentDate?.toLocal().toString() ?? 'N/A'),
              ),
              ListTile(
                title: const Text('Description'),
                subtitle: isEditMode
                    ? TextFormField(
                        initialValue: description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        onSaved: (value) {
                          description = value ?? '';
                        },
                      )
                    : Text(description),
              ),
              SwitchListTile(
                title: const Text('Vet Visit'),
                value: vetVisit,
                onChanged: isEditMode
                    ? (value) {
                        setState(() {
                          vetVisit = value;
                        });
                      }
                    : null,
              ),
              ListTile(
                title: const Text('Reported By'),
                subtitle: Text(reportedBy),
              ),
              ListTile(
                title: const Text('Cat'),
                subtitle: Text(catName),
              ),
              ListTile(
                title: const Text('Volunteer'),
                subtitle: Text(volunteerName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
