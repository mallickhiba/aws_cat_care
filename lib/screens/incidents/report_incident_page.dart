import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_app/blocs/get_all_users_bloc/get_all_users_bloc.dart';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:incident_repository/incident_repository.dart';

class ReportIncidentPage extends StatefulWidget {
  final String? catId;

  const ReportIncidentPage({super.key, this.catId});

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

    setState(() {
      selectedPhotos = images.map((image) => File(image.path)).toList();
    });
  }

  Future<List<String>> _uploadPhotos() async {
    List<String> uploadedUrls = [];
    if (selectedPhotos.isEmpty) return uploadedUrls;

    setState(() {
      isUploading = true;
    });

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
    } finally {
      setState(() {
        isUploading = false;
      });
    }
    return uploadedUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.catId == null ? "Report Incident" : "Add Incident"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.catId == null)
              BlocBuilder<GetCatBloc, GetCatState>(
                builder: (context, state) {
                  if (state is GetCatLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is GetCatSuccess) {
                    return DropdownButtonFormField<String>(
                      value: selectedCat,
                      onChanged: (value) => setState(() => selectedCat = value),
                      items: state.cats
                          .map((cat) => DropdownMenuItem(
                                value: cat.catId,
                                child: Text(cat.catName),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: "Select Cat",
                        border: OutlineInputBorder(),
                      ),
                    );
                  } else {
                    return Text("Failed to load cats",
                        style: Theme.of(context).textTheme.bodyMedium);
                  }
                },
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            BlocBuilder<GetAllUsersBloc, GetAllUsersState>(
              builder: (context, state) {
                if (state is GetAllUsersLoading) {
                  return const CircularProgressIndicator();
                } else if (state is GetAllUsersSuccess) {
                  final users = state.users;
                  return DropdownButtonFormField<String>(
                    value: selectedVolunteer,
                    onChanged: (value) =>
                        setState(() => selectedVolunteer = value),
                    items: users
                        .map((user) => DropdownMenuItem(
                              value: user.id,
                              child: Text(user.name),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: "Select Volunteer",
                      border: OutlineInputBorder(),
                    ),
                  );
                } else {
                  return Text("Failed to load users",
                      style: Theme.of(context).textTheme.bodyMedium);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text("Pick Images"),
            ),
            Wrap(
              spacing: 10,
              children: selectedPhotos
                  .map((file) => Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(file,
                              width: 100, height: 100, fit: BoxFit.cover),
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () =>
                                setState(() => selectedPhotos.remove(file)),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            SwitchListTile(
              title: const Text("Vet Visit"),
              value: vetVisit,
              onChanged: (bool value) => setState(() => vetVisit = value),
            ),
            SwitchListTile(
              title: const Text("Follow-Up Required"),
              value: followUpRequired,
              onChanged: (bool value) =>
                  setState(() => followUpRequired = value),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_descriptionController.text.isNotEmpty &&
                    (widget.catId != null || selectedCat != null) &&
                    selectedVolunteer != null) {
                  final photoUrls = await _uploadPhotos();
                  final usersState = context.read<GetAllUsersBloc>().state;

                  if (usersState is GetAllUsersSuccess) {
                    final users = usersState.users;
                    final volunteer = users
                        .firstWhere((user) => user.id == selectedVolunteer);

                    final incident = Incident(
                      id: '',
                      catId: widget.catId ?? selectedCat!,
                      reportDate: DateTime.now(),
                      reportedBy: context.read<MyUserBloc>().state.user!,
                      vetVisit: vetVisit,
                      description: _descriptionController.text,
                      followUp: followUpRequired,
                      volunteer: volunteer,
                      photos: photoUrls,
                    );
                    context.read<CreateIncidentBloc>().add(
                        CreateIncident(incident, widget.catId ?? selectedCat!));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to get users data")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                }
              },
              child: isUploading
                  ? const CircularProgressIndicator()
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
