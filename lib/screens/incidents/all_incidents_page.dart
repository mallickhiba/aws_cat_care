import 'dart:developer';
import 'package:aws_app/components/cat_utility.dart';
import 'package:aws_app/screens/incidents/incident_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_all_incidents_bloc/get_all_incidents_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:aws_app/screens/incidents/incident_detail_page.dart';
import 'package:intl/intl.dart';

class AllIncidentsPage extends StatefulWidget {
  const AllIncidentsPage({super.key});

  @override
  State<AllIncidentsPage> createState() => _AllIncidentsPageState();
}

class _AllIncidentsPageState extends State<AllIncidentsPage> {
  Map<String, String> _catNames = {}; // to cache cat names

  @override
  void initState() {
    super.initState();
    log('Triggering GetAllIncidents event');
    context.read<GetAllIncidentsBloc>().add(const GetAllIncidents());

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("All Incidents"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: "All"),
              Tab(icon: Icon(Icons.local_hospital), text: "Vet Visit"),
              Tab(icon: Icon(Icons.follow_the_signs), text: "Follow Up"),
            ],
          ),
        ),
        body: BlocBuilder<GetAllIncidentsBloc, GetAllIncidentsState>(
          builder: (context, state) {
            if (state is GetAllIncidentsLoading) {
              log('State: GetAllIncidentsLoading');
              return const Center(child: CircularProgressIndicator());
            } else if (state is GetAllIncidentsSuccess) {
              log('State: GetAllIncidentsSuccess');
              log('Fetched incidents: ${state.incidents.length}');

              final allIncidents = state.incidents;
              final vetVisitIncidents =
                  allIncidents.where((i) => i.vetVisit).toList();
              final followUpIncidents =
                  allIncidents.where((i) => i.followUp).toList();

              return TabBarView(
                children: [
                  _buildIncidentList(allIncidents),
                  _buildIncidentList(vetVisitIncidents),
                  _buildIncidentList(followUpIncidents),
                ],
              );
            } else if (state is GetAllIncidentsFailure) {
              log('State: GetAllIncidentsFailure');
              return Center(
                child: Text(
                  'Error loading incidents: ${state.toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              log('State: Unknown');
              return const Center(child: Text("Unknown state."));
            }
          },
        ),
      ),
    );
  }

  Widget _buildIncidentList(List<Incident> incidents) {
    if (incidents.isEmpty) {
      log('No incidents to display in this list');
      return const Center(
        child: Text(
          "No incidents to display.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

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
  }
}
