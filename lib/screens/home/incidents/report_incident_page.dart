import 'dart:io';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/blocs/get_all_users_bloc/get_all_users_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final TextEditingController _descriptionController = TextEditingController();
  bool vetVisit = false;
  bool followUpRequired = false;
  String? selectedVolunteer;
  String? selectedCat;
  List<File> selectedPhotos = [];
  bool isUploading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        selectedPhotos = images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadPhotos() async {
    List<String> uploadedUrls = [];
    try {
      for (var photo in selectedPhotos) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'incident_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(photo);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload photos: $e")),
      );
    }
    return uploadedUrls;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateIncidentBloc, CreateIncidentState>(
          listener: (context, state) {
            if (state is CreateIncidentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Incident reported successfully!")),
              );
              Navigator.pop(context);
            } else if (state is CreateIncidentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to report incident: $state")),
              );
            }
          },
        ),
      ],
      child: Scaffold(
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
              // Cat Dropdown
              BlocBuilder<GetCatBloc, GetCatState>(
                builder: (context, catState) {
                  if (catState is GetCatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (catState is GetCatSuccess) {
                    final catOptions = [
                      const DropdownMenuItem(
                        value: "unknown",
                        child: Text("Unknown"),
                      ),
                      ...catState.cats.map((cat) {
                        return DropdownMenuItem(
                          value: cat.catId,
                          child: Text(cat.catName),
                        );
                      }),
                    ];

                    return DropdownButtonFormField<String>(
                      value: selectedCat,
                      items: catOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedCat = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Cat",
                        border: OutlineInputBorder(),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text("Failed to load cats."),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              BlocBuilder<GetAllUsersBloc, GetAllUsersState>(
                builder: (context, userState) {
                  if (userState is GetAllUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (userState is GetAllUsersSuccess) {
                    final userOptions = userState.users
                        .map((user) => DropdownMenuItem(
                              value: user.id,
                              child: Text(user.name),
                            ))
                        .toList();

                    return DropdownButtonFormField<String>(
                      value: selectedVolunteer,
                      items: userOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedVolunteer = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Volunteer",
                        border: OutlineInputBorder(),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text("Failed to load users."),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: selectedPhotos
                    .map((photo) => Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(photo,
                                width: 100, height: 100, fit: BoxFit.cover),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPhotos.remove(photo);
                                });
                              },
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ))
                    .toList(),
              ),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_a_photo),
                label: const Text("Add Photos"),
              ),
              SwitchListTile(
                title: const Text("Vet Visit"),
                value: vetVisit,
                onChanged: (value) {
                  setState(() {
                    vetVisit = value;
                  });
                },
              ),
              const SizedBox(height: 5),
              SwitchListTile(
                title: const Text("Follow-Up Required"),
                value: followUpRequired,
                onChanged: (value) {
                  setState(() {
                    followUpRequired = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_descriptionController.text.isNotEmpty &&
                      selectedCat != null &&
                      selectedVolunteer != null) {
                    setState(() {
                      isUploading = true;
                    });
                    final photoUrls = await _uploadPhotos();
                    setState(() {
                      isUploading = false;
                    });

                    final incident = Incident(
                      id: '',
                      catId: selectedCat == "unknown" ? 'NA' : selectedCat!,
                      reportDate: DateTime.now(),
                      reportedBy: context.read<MyUserBloc>().state.user!,
                      vetVisit: vetVisit,
                      description: _descriptionController.text,
                      followUp: followUpRequired,
                      volunteer: (context.read<GetAllUsersBloc>().state
                              as GetAllUsersSuccess)
                          .users
                          .firstWhere((user) => user.id == selectedVolunteer),
                      photos: photoUrls,
                    );
                    context.read<CreateIncidentBloc>().add(
                          CreateIncident(incident, selectedCat!),
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "All fields including Cat and Volunteer are required!")),
                    );
                  }
                },
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
