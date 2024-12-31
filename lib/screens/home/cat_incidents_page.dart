import 'package:aws_cat_care/blocs/get_incidents_for_cat_bloc/get_incidents_for_cat_bloc.dart';
import 'package:aws_cat_care/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_cat_care/blocs/get_all_incidents_bloc/get_all_incidents_bloc.dart';
import 'package:aws_cat_care/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:incident_repository/incident_repository.dart';

class IncidentPage extends StatefulWidget {
  final String catId; // The cat this page is associated with

  const IncidentPage({super.key, required this.catId});

  @override
  State<IncidentPage> createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  final TextEditingController _descriptionController = TextEditingController();
  bool vetVisit = false;

  @override
  void initState() {
    super.initState();
    // Load incidents for the given catId when the page is displayed
    context
        .read<GetIncidentsForCatBloc>()
        .add(GetIncidentsForCat(catId: widget.catId));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateIncidentBloc, CreateIncidentState>(
      listener: (context, state) {
        if (state is CreateIncidentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Incident added successfully!")),
          );
          // Reload incidents after adding a new incident
          context
              .read<GetIncidentsForCatBloc>()
              .add(GetIncidentsForCat(catId: widget.catId));
        } else if (state is CreateIncidentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to add incident")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Incidents"),
        ),
        body: Column(
          children: [
            Expanded(
              child:
                  BlocBuilder<GetIncidentsForCatBloc, GetIncidentsForCatState>(
                builder: (context, state) {
                  if (state is GetIncidentsForCatSuccess) {
                    final incidents = state.incidents;
                    return ListView.builder(
                      itemCount: incidents.length,
                      itemBuilder: (context, index) {
                        final incident = incidents[index];
                        return ListTile(
                          title: Text(incident.description),
                          subtitle: Text(incident.vetVisit
                              ? "Vet Visit: Yes"
                              : "Vet Visit: No"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context
                                  .read<GetIncidentsForCatBloc>()
                                  .add(DeleteIncidentForCat(
                                    incident.id,
                                    widget.catId,
                                  ));
                            },
                          ),
                        );
                      },
                    );
                  } else if (state is GetIncidentsForCatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(
                        child: Text("Failed to load incidents."));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Vet Visit"),
                      Switch(
                        value: vetVisit,
                        onChanged: (value) {
                          setState(() {
                            vetVisit = value;
                          });
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_descriptionController.text.isNotEmpty) {
                        final incident = Incident(
                          id: '',
                          catId: widget.catId,
                          reportDate: DateTime.now(),
                          reportedBy: context.read<MyUserBloc>().state.user!,
                          vetVisit: vetVisit,
                          description: _descriptionController.text,
                          followUp: false,
                          volunteer: context.read<MyUserBloc>().state.user!,
                        );
                        context.read<CreateIncidentBloc>().add(
                              CreateIncident(incident, widget.catId),
                            );
                      }
                    },
                    child: const Text("Add Incident"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
