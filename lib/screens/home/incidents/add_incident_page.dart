import 'package:aws_cat_care/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_cat_care/blocs/get_all_users_bloc/get_all_users_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_cat_care/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:incident_repository/incident_repository.dart';

class AddIncidentPage extends StatefulWidget {
  final String catId;

  const AddIncidentPage({super.key, required this.catId});

  @override
  State<AddIncidentPage> createState() => _AddIncidentPageState();
}

class _AddIncidentPageState extends State<AddIncidentPage> {
  final TextEditingController _descriptionController = TextEditingController();
  bool vetVisit = false;
  bool followUpRequired = false;
  String? selectedVolunteer;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAllUsersBloc, GetAllUsersState>(
      builder: (context, state) {
        if (state is GetAllUsersLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is GetAllUsersSuccess) {
          final users = state.users;
          final userOptions = users
              .map((user) => DropdownMenuItem(
                    value: user.id,
                    child: Text(user.name),
                  ))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text("Add Incident"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text("Vet Visit"),
                    value: vetVisit,
                    onChanged: (value) {
                      setState(() {
                        vetVisit = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text("Follow-Up Required"),
                    value: followUpRequired,
                    onChanged: (value) {
                      setState(() {
                        followUpRequired = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedVolunteer,
                    items: userOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedVolunteer = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Assign Volunteer",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_descriptionController.text.isNotEmpty &&
                          selectedVolunteer != null) {
                        final incident = Incident(
                          id: '',
                          catId: widget.catId,
                          reportDate: DateTime.now(),
                          reportedBy: context.read<MyUserBloc>().state.user!,
                          vetVisit: vetVisit,
                          description: _descriptionController.text,
                          followUp: followUpRequired,
                          volunteer: users.firstWhere(
                              (user) => user.id == selectedVolunteer),
                        );
                        context.read<CreateIncidentBloc>().add(
                              CreateIncident(incident, widget.catId),
                            );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "All fields including Volunteer are required!")),
                        );
                      }
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text("Failed to load users.")),
          );
        }
      },
    );
  }
}
