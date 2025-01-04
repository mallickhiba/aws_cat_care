import 'dart:io';

import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_app/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:image_picker/image_picker.dart';

class EditCatDetailScreen extends StatefulWidget {
  final Cat cat;

  const EditCatDetailScreen({super.key, required this.cat});

  @override
  State<EditCatDetailScreen> createState() => _EditCatDetailScreenState();
}

class _EditCatDetailScreenState extends State<EditCatDetailScreen> {
  late Cat editableCat;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    editableCat = widget.cat;

    // Initialize controllers with current cat data
    _nameController.text = editableCat.catName;
    _ageController.text = editableCat.age.toString();
    _descriptionController.text = editableCat.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        setState(() {
          _isLoading = true; // Show the loading indicator
        });

        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('cat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(File(image.path));

        final snapshot = await uploadTask;
        final imageUrl = await snapshot.ref.getDownloadURL();

        // Update the `editableCat` object with the new image URL
        setState(() {
          editableCat = editableCat.copyWith(image: imageUrl);
        });
      } catch (e) {
        // Handle upload errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide the loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCatBloc, UpdateCatState>(
      listener: (context, state) {
        if (state is UpdateCatSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cat updated successfully!")),
          );
          Navigator.pop(context);
        } else if (state is UpdateCatFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update cat: ${state.error}")),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("Edit Cat Details"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<GetCatBloc>().add(DeleteCat(widget.cat.catId));
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: editableCat.image.isNotEmpty
                                ? DecorationImage(
                                    image: editableCat.image.startsWith('http')
                                        ? NetworkImage(editableCat.image)
                                        : FileImage(File(editableCat.image))
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: Colors.grey.shade300,
                          ),
                          child: editableCat.image.isEmpty
                              ? const Icon(Icons.camera_alt,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, "Name"),
                    const SizedBox(height: 10),
                    _buildTextField(_ageController, "Age",
                        inputType: TextInputType.number),
                    const SizedBox(height: 10),
                    _buildTextField(_descriptionController, "Description",
                        maxLines: 3),
                    const SizedBox(height: 10),

                    // Dropdown for Location
                    _buildDropdown(
                      label: "Location",
                      value: editableCat.location.isNotEmpty
                          ? editableCat.location
                          : "Student Center",
                      items: [
                        "Student Center",
                        "Library",
                        "Tabba",
                        "Aman",
                        "Fauji",
                        "Adamjee",
                        "Courtyard",
                      ],
                      onChanged: (value) {
                        setState(() {
                          editableCat = editableCat.copyWith(location: value!);
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Dropdown for Sex
                    _buildDropdown(
                      label: "Sex",
                      value:
                          editableCat.sex.isNotEmpty ? editableCat.sex : "Male",
                      items: ["Male", "Female", "Unknown"],
                      onChanged: (value) {
                        setState(() {
                          editableCat = editableCat.copyWith(sex: value!);
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Switch for Is Fixed
                    _buildSwitch(
                      label: "Fixed",
                      value: editableCat.isFixed,
                      onChanged: (value) {
                        setState(() {
                          editableCat = editableCat.copyWith(isFixed: value);
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Switch for Is Adopted
                    _buildSwitch(
                      label: "Adopted",
                      value: editableCat.isAdopted,
                      onChanged: (value) {
                        setState(() {
                          editableCat = editableCat.copyWith(isAdopted: value);
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isNotEmpty &&
                            editableCat.location.isNotEmpty &&
                            _ageController.text.isNotEmpty &&
                            _descriptionController.text.isNotEmpty &&
                            editableCat.image.isNotEmpty) {
                          setState(() {
                            editableCat = editableCat.copyWith(
                              catName: _nameController.text,
                              age: int.tryParse(_ageController.text) ??
                                  editableCat.age,
                              description: _descriptionController.text,
                            );
                          });

                          // Dispatch update event
                          context
                              .read<UpdateCatBloc>()
                              .add(UpdateCat(editableCat));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill out all fields.")),
                          );
                        }
                      },
                      child: const Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
