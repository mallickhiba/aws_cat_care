import 'dart:io';
import 'package:aws_app/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_repository/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aws_app/blocs/create_cat_bloc/create_cat_bloc.dart';

class CatScreen extends StatefulWidget {
  final MyUser myUser;
  const CatScreen(this.myUser, {super.key});

  @override
  State<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends State<CatScreen> {
  late Cat cat;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  String? _imagePath;
  String _selectedSex = "Male";
  String _selectedLocation = "Student Center";
  String _selectedCampus = "Main Campus";
  String _selectedStatus = "Available";
  bool _isFixed = false;
  bool _isVaccinated = false;
  bool _isHealthy = true;
  List<File> _photoFiles = [];
  final List<String> _photoUrls = [];

  @override
  void initState() {
    cat = Cat.empty.copyWith(myUser: widget.myUser);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('cat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(File(_imagePath!));

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        cat = cat.copyWith(
          image: imageUrl,
        );
      });
    }
  }

  Future<void> _pickPhotos() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        _photoFiles = images.map((image) => File(image.path)).toList();
      });

      for (var photo in _photoFiles) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('cat_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(photo);

        final snapshot = await uploadTask;
        final photoUrl = await snapshot.ref.getDownloadURL();

        if (mounted) {
          setState(() {
            _photoUrls.add(photoUrl);
          });
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photos uploaded successfully.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCatBloc, CreateCatState>(
      listener: (context, state) {
        if (state is CreateCatSuccess) {
          context.read<GetCatBloc>().add(GetCats());
          Navigator.pop(context);
        } else if (state is CreateCatFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to create cat: $state")),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text('Create a Cat'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  _selectedLocation.isNotEmpty &&
                  _ageController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty &&
                  _colorController.text.isNotEmpty &&
                  cat.image.isNotEmpty) {
                setState(() {
                  cat = cat.copyWith(
                    catName: _nameController.text,
                    location: _selectedLocation,
                    age: int.tryParse(_ageController.text) ?? 0,
                    sex: _selectedSex,
                    color: _colorController.text,
                    description: _descriptionController.text,
                    isFixed: _isFixed,
                    isVaccinated: _isVaccinated,
                    isHealthy: _isHealthy,
                    campus: _selectedCampus,
                    status: _selectedStatus,
                    photos: _photoUrls,
                  );
                });
                context.read<CreateCatBloc>().add(CreateCat(cat));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill out all fields.")),
                );
              }
            },
            child: const Icon(CupertinoIcons.add),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      image: _imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imagePath == null
                        ? const Icon(
                            CupertinoIcons.photo,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickPhotos,
                  child: const Text("Upload Cat Photos"),
                ),
                const SizedBox(height: 20),
                if (_photoFiles.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    children: _photoFiles
                        .map((file) => Image.file(
                              file,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "Cat Name"),
                const SizedBox(height: 10),
                _buildDropdown(
                  label: "Location",
                  value: _selectedLocation,
                  items: [
                    "Student Center",
                    "Library",
                    "Tabba",
                    "Aman",
                    "Fauji",
                    "Adamjee",
                    "Courtyard"
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(_ageController, "Age",
                    inputType: TextInputType.number),
                const SizedBox(height: 10),
                _buildDropdown(
                  label: "Sex",
                  value: _selectedSex,
                  items: ["Male", "Female", "Unknown"],
                  onChanged: (value) {
                    setState(() {
                      _selectedSex = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(_colorController, "Color"),
                const SizedBox(height: 10),
                _buildDropdown(
                  label: "Campus",
                  value: _selectedCampus,
                  items: ["Main Campus", "City Campus"],
                  onChanged: (value) {
                    setState(() {
                      _selectedCampus = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildDropdown(
                  label: "Status",
                  value: _selectedStatus,
                  items: ["Lost", "Deceased", "Adopted", "Available"],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildSwitch(
                  label: "Fixed",
                  value: _isFixed,
                  onChanged: (value) {
                    setState(() {
                      _isFixed = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildSwitch(
                  label: "Vaccinated",
                  value: _isVaccinated,
                  onChanged: (value) {
                    setState(() {
                      _isVaccinated = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildSwitch(
                  label: "Healthy",
                  value: _isHealthy,
                  onChanged: (value) {
                    setState(() {
                      _isHealthy = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  _descriptionController,
                  "Description",
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
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
