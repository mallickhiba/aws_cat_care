import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';

class UserDutiesPage extends StatefulWidget {
  const UserDutiesPage({super.key});

  @override
  State<UserDutiesPage> createState() => _UserDutiesPageState();
}

class _UserDutiesPageState extends State<UserDutiesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

            return ListTile(
              leading: const Icon(Icons.food_bank, color: Colors.green),
              title: Text("Location: $location"),
              subtitle: Text("Time Slot: $slot\nDate: ${date.toLocal()}"),
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

            DateTime? reportDate;
            // Handle different formats of reportDate
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

            return ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.orange),
              title: Text(description),
              subtitle: Text(
                "Cat ID: $catId\nReported On: ${reportDate != null ? reportDate : 'Invalid Date'}",
              ),
            );
          },
        );
      },
    );
  }
}
