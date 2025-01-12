import 'package:aws_app/screens/incidents/add_incident_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:incident_repository/incident_repository.dart';

class IncidentPage extends StatefulWidget {
  final String catId;

  const IncidentPage({super.key, required this.catId});

  @override
  State<IncidentPage> createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  void _loadIncidents() {
    context
        .read<GetIncidentsForCatBloc>()
        .add(GetIncidentsForCat(catId: widget.catId));
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.read<MyUserBloc>().state.user?.role ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incidents"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigate to AddIncidentPage and wait for it to return
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddIncidentPage(catId: widget.catId),
                ),
              );

              // Refresh the incident list if a new incident was added
              if (result == true) {
                _loadIncidents();
              }
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
                return ListTile(
                  title: Text(incident.description),
                  subtitle: Text(
                    "Vet Visit: ${incident.vetVisit ? "Yes" : "No"}",
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return _buildIncidentDetails(incident, userRole);
                      },
                    );
                  },
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

  Widget _buildIncidentDetails(Incident incident, String userRole) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Incident Details",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text("Description: ${incident.description}"),
          Text("Vet Visit: ${incident.vetVisit ? "Yes" : "No"}"),
          Text("Follow-Up: ${incident.followUp ? "Yes" : "No"}"),
          Text("Reported By: ${incident.reportedBy.name}"),
          Text("Volunteer: ${incident.volunteer.name}"),
          Text("Report Date: ${incident.reportDate.toString()}"),
          if (userRole == 'admin') ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddIncidentPage(
                          catId: incident.catId,
                        ),
                      ),
                    );
                  },
                  child: const Text("Edit"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    context
                        .read<GetIncidentsForCatBloc>()
                        .add(DeleteIncidentForCat(incident.id, widget.catId));
                    Navigator.pop(context);
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
