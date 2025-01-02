import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_cat_care/blocs/get_all_incidents_bloc/get_all_incidents_bloc.dart';
import 'package:aws_cat_care/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:incident_repository/incident_repository.dart';

class AllIncidentsPage extends StatefulWidget {
  const AllIncidentsPage({super.key});

  @override
  State<AllIncidentsPage> createState() => _AllIncidentsPageState();
}

class _AllIncidentsPageState extends State<AllIncidentsPage> {
  Map<String, String> _catNames = {}; // Map to cache cat names

  @override
  void initState() {
    super.initState();
    log('Triggering GetAllIncidents event');
    context.read<GetAllIncidentsBloc>().add(const GetAllIncidents());

    _preloadCatNames();
  }

  Future<void> _preloadCatNames() async {
    final catBloc = context.read<GetCatBloc>();
    catBloc.add(GetCats()); // Fetch all cats

    final catState =
        await catBloc.stream.firstWhere((state) => state is GetCatSuccess);
    if (catState is GetCatSuccess) {
      _catNames = {
        for (var cat in catState.cats) cat.catId: cat.catName,
      };
      log('Cat names preloaded: $_catNames');
      setState(() {}); // Update UI with cat names
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
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

              log('All Incidents: ${allIncidents.length}');
              log('Vet Visit Incidents: ${vetVisitIncidents.length}');
              log('Follow Up Incidents: ${followUpIncidents.length}');

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
      return const Center(child: Text("No incidents to display."));
    }

    return ListView.builder(
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        log('Displaying incident: ${incident.description}');

        final catName = _catNames[incident.catId] ?? 'Unknown Cat';

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(incident.description),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cat Name: $catName"),
                Text("Date: ${incident.reportDate.toLocal()}"),
                if (incident.vetVisit) const Text("Vet Visit: Yes"),
                if (incident.followUp) const Text("Follow Up Required: Yes"),
              ],
            ),
            onTap: () {
              // Add functionality to navigate or view details
            },
          ),
        );
      },
    );
  }
}
