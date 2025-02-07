import 'dart:developer';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/screens/incidents/incident_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/components/cat_utility.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';

class UserDutiesPage extends StatefulWidget {
  const UserDutiesPage({super.key});

  @override
  State<UserDutiesPage> createState() => _UserDutiesPageState();
}

class _UserDutiesPageState extends State<UserDutiesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> _catNames = {};

  @override
  void initState() {
    super.initState();
    _loadCatNames();
  }

  void _loadCatNames() async {
    try {
      _catNames = await CatUtility.preloadCatNames(context);
    } catch (e) {
      print('Error loading cat names: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<MyUserBloc>().state.user?.id ?? "Unknown User";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Duties"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.food_bank), text: "Feeding Duties"),
              Tab(icon: Icon(Icons.report_problem), text: "Incident Duties"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedingDuties(userId),
            _buildIncidentDuties(userId),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingDuties(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('feeding_schedules')
          .where('volunteer', isEqualTo: userId)
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading feeding duties."));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No feeding duties assigned."));
        }

        final feedingDuties = snapshot.data!.docs;

        return ListView.builder(
          itemCount: feedingDuties.length,
          itemBuilder: (context, index) {
            final data = feedingDuties[index].data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            final location = data['location'] ?? "Unknown Location";
            final slot = data['slot'] ?? "Unknown Slot";
            final backupId = data['backup'] ?? "Unknown Backup";
            final completed = data['completed'] ?? false;

            // Fetch backup user details
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(backupId).get(),
              builder: (context, backupSnapshot) {
                String backupName = "Unknown Backup";

                if (backupSnapshot.connectionState == ConnectionState.done &&
                    backupSnapshot.hasData &&
                    backupSnapshot.data != null) {
                  final backupData =
                      backupSnapshot.data!.data() as Map<String, dynamic>;
                  backupName = backupData['name'] ?? "Unknown Backup";
                }

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildRow(Icons.access_time, "$slot slot"),
                        const SizedBox(height: 8),
                        _buildRow(Icons.location_on, "$location"),
                        const SizedBox(height: 8),
                        _buildRow(
                          Icons.calendar_today,
                          "${DateFormat('dd MMM yyyy').format(date)}",
                        ),
                        const SizedBox(height: 8),
                        _buildRow(Icons.person, "Backup: $backupName"),
                        const SizedBox(height: 8),
                        _buildRow(
                          Icons.check,
                          completed ? "Completed" : "Pending",
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildIncidentDuties(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('incidents')
          .where('volunteer.id', isEqualTo: userId)
          .orderBy('reportDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          log(snapshot.error.toString());
          return const Center(child: Text("Error loading incident duties."));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No incident duties assigned."));
        }

        final incidentDuties = snapshot.data!.docs;

        return ListView.builder(
          itemCount: incidentDuties.length,
          itemBuilder: (context, index) {
            final data = incidentDuties[index].data() as Map<String, dynamic>;
            final description = data['description'] ?? "No Description";
            final catId = data['catId'] ?? "Unknown Cat ID";
            final catName = _catNames[catId] ?? 'Unknown Cat';

            final reportedByData = data['reportedBy'] as Map<String, dynamic>?;
            final volunteerData = data['volunteer'] as Map<String, dynamic>?;

            final reportedBy = reportedByData != null
                ? MyUser(
                    id: reportedByData['id'] ?? '',
                    name: reportedByData['name'] ?? 'Unknown',
                    email: '',
                    role: '',
                  )
                : MyUser.empty;

            final volunteer = volunteerData != null
                ? MyUser(
                    id: volunteerData['id'] ?? '',
                    name: volunteerData['name'] ?? 'Unknown',
                    email: '',
                    role: '',
                  )
                : MyUser.empty;

            DateTime? reportDate;
            try {
              if (data['reportDate'] is Timestamp) {
                reportDate =
                    (data['reportDate'] as Timestamp).toDate().toLocal();
              } else if (data['reportDate'] is String) {
                reportDate = DateTime.tryParse(data['reportDate'])?.toLocal();
              }
            } catch (e) {
              log("Error parsing reportDate: $e");
            }

            final incident = Incident(
              id: data['id'] ?? '',
              description: description,
              catId: catId,
              reportDate: reportDate ?? DateTime.now(),
              vetVisit: data['vetVisit'] ?? false,
              followUp: data['followUp'] ?? false,
              reportedBy: reportedBy,
              volunteer: volunteer,
            );

            return incidentCard(
              incident: incident,
              catName: catName,
              context: context,
            );
          },
        );
      },
    );
  }

  Widget _buildRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Color.fromARGB(255, 106, 52, 128), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
