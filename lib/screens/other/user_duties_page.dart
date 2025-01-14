import 'dart:developer';

import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/screens/incidents/incident_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:intl/intl.dart';

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
    _preloadCatNames();
  }

  Future<void> _preloadCatNames() async {
    final catBloc = context.read<GetCatBloc>();
    catBloc.add(GetCats());

    final catState =
        await catBloc.stream.firstWhere((state) => state is GetCatSuccess);
    if (catState is GetCatSuccess) {
      _catNames = {
        for (var cat in catState.cats) cat.catId: cat.catName,
      };
      log('Cat names preloaded: $_catNames');
      setState(() {});
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
            final backup = data['backup'] ?? "Unknown Backup";

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(Icons.food_bank, "Location: $location"),
                    _buildRow(Icons.access_time, "Slot: $slot"),
                    _buildRow(Icons.person, "Backup: $backup"),
                    _buildRow(
                      Icons.calendar_today,
                      "Date: ${DateFormat('dd MMM yyyy').format(date)}",
                    ),
                  ],
                ),
              ),
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

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRow(Icons.pets, "Cat Name: $catName"),
                    _buildRow(
                      Icons.calendar_today,
                      "Reported On: ${reportDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(reportDate) : 'Invalid Date'}",
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncidentDetailPage(
                                incident: data[
                                    incidentDuties], // Adjust as per your model
                                catName: catName,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "View Details",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
