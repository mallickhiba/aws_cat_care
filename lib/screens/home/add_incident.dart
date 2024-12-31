import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:aws_cat_care/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:aws_cat_care/blocs/my_user_bloc/my_user_bloc.dart';

class AddIncidentPage extends StatefulWidget {
  final String catId;

  const AddIncidentPage({super.key, required this.catId});

  @override
  State<AddIncidentPage> createState() => _AddIncidentPageState();
}

class _AddIncidentPageState extends State<AddIncidentPage> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _vetVisit = false;
  bool _followUp = false;

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
          Navigator.pop(context); // Go back after successful creation
        } else if (state is CreateIncidentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to add incident")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Incident"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<MyUserBloc, MyUserState>(
            builder: (context, userState) {
              if (userState.status == MyUserStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (userState.status == MyUserStatus.failure) {
                return const Center(
                    child: Text("Failed to load user information"));
              } else if (userState.status == MyUserStatus.success) {
                final user = userState.user!;
                return Column(
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
                      value: _vetVisit,
                      onChanged: (value) {
                        setState(() {
                          _vetVisit = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Follow Up Required"),
                      value: _followUp,
                      onChanged: (value) {
                        setState(() {
                          _followUp = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_descriptionController.text.isNotEmpty) {
                          final incident = Incident(
                            id: '',
                            catId: widget.catId,
                            reportDate: DateTime.now(),
                            reportedBy: user,
                            vetVisit: _vetVisit,
                            description: _descriptionController.text,
                            followUp: _followUp,
                            volunteer: user,
                          );

                          context
                              .read<CreateIncidentBloc>()
                              .add(CreateIncident(incident, widget.catId));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Description is required!")),
                          );
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
