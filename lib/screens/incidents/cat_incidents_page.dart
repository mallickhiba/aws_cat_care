import 'dart:developer';

import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/components/cat_utility.dart';
import 'package:aws_app/screens/incidents/report_incident_page.dart';
import 'package:aws_app/screens/incidents/incident_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';

class IncidentPage extends StatefulWidget {
  final String catId;

  const IncidentPage({super.key, required this.catId});

  @override
  State<IncidentPage> createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  Map<String, String> _catNames = {}; // to cache cat names

  @override
  void initState() {
    super.initState();
    _loadIncidents();
    _loadCatNames();
  }

  void _loadIncidents() {
    context
        .read<GetIncidentsForCatBloc>()
        .add(GetIncidentsForCat(catId: widget.catId));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Incidents"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportIncidentPage(catId: widget.catId),
                ),
              ).then((result) {
                if (result == true) {
                  // Reload incidents when returning from AddIncidentPage
                  _loadIncidents();
                }
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<GetIncidentsForCatBloc, GetIncidentsForCatState>(
        builder: (context, state) {
          if (state is GetIncidentsForCatSuccess) {
            final incidents = state.incidents;

            return ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                final catName = _catNames[incident.catId] ?? 'Unknown Cat';

                return incidentCard(
                  incident: incident,
                  catName: catName,
                  context: context,
                );
              },
            );
          } else if (state is GetIncidentsForCatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("Failed to load incidents."));
          }
        },
      ),
    );
  }
}
