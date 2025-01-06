import 'dart:io';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/blocs/get_all_users_bloc/get_all_users_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:incident_repository/incident_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  List<String> photoUrls = [];
  List<File> selectedImages = [];
  bool isUploading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> _uploadImages() async {
    if (selectedImages.isEmpty) return;

    setState(() {
      isUploading = true;
    });

    try {
      for (var image in selectedImages) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'incident_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(image);

        final snapshot = await uploadTask;
        final imageUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          photoUrls.add(imageUrl);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload images: $e")),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
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
                      labelText: "Volunteer",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image Picker Section
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text("Pick Images"),
                  ),
                  const SizedBox(height: 10),
                  if (selectedImages.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      children: selectedImages
                          .map((image) => Image.file(image,
                              width: 100, height: 100, fit: BoxFit.cover))
                          .toList(),
                    ),
                  if (isUploading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: CircularProgressIndicator(),
                    ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_descriptionController.text.isNotEmpty &&
                          selectedVolunteer != null) {
                        await _uploadImages();

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
                          photos: photoUrls,
                        );
                        context.read<CreateIncidentBloc>().add(
                              CreateIncident(incident, widget.catId),
                            );
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
