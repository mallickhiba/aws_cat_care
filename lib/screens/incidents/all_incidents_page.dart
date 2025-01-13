import 'dart:developer';
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const Icon(
                    //   Icons.crisis_alert,
                    //   size: 30,
                    //   color: Color.fromARGB(255, 106, 52, 128),
                    // ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        incident.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.pets, color: Colors.pink, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Cat Name: $catName",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      "Reported on ${DateFormat('dd MMM yyyy, hh:mm a').format(incident.reportDate.toLocal())}",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (incident.vetVisit)
                  const Row(
                    children: [
                      Icon(Icons.local_hospital, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Vet visit",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                if (incident.followUp)
                  const Row(
                    children: [
                      Icon(Icons.add_alert, size: 20, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        "Follow up required",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 106, 52, 128),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IncidentDetailPage(
                            incident: incident,
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
  }
}
