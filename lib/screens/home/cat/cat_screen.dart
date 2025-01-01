import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_repository/user_repository.dart';
// import 'package:aws_cat_care/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:aws_cat_care/blocs/create_cat_bloc/create_cat_bloc.dart';

class CatScreen extends StatefulWidget {
  final MyUser myUser;
  const CatScreen(this.myUser, {super.key});

  @override
  State<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends State<CatScreen> {
  late Cat cat;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imagePath;
  String _selectedSex = "Male";
  String _selectedColor = "Black";
  bool _isFixed = false;
  bool _isAdopted = false;

  @override
  void initState() {
    cat = Cat.empty.copyWith(myUser: widget.myUser);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCatBloc, CreateCatState>(
      listener: (context, state) {
        if (state is CreateCatSuccess) {
          Navigator.pop(context);
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
                  _locationController.text.isNotEmpty &&
                  _ageController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty) {
                setState(() {
                  cat = cat.copyWith(
                    catName: _nameController.text,
                    location: _locationController.text,
                    age: int.tryParse(_ageController.text) ?? 0,
                    sex: _selectedSex,
                    color: _selectedColor,
                    description: _descriptionController.text,
                    image: _imagePath ?? '',
                    isFixed: _isFixed,
                    isAdopted: _isAdopted,
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
                _buildTextField(_nameController, "Cat Name"),
                const SizedBox(height: 10),
                _buildTextField(_locationController, "Location"),
                const SizedBox(height: 10),
                _buildTextField(_ageController, "Age",
                    inputType: TextInputType.number),
                const SizedBox(height: 10),

                // Dropdown for Sex
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

                // Dropdown for Color
                _buildDropdown(
                  label: "Color",
                  value: _selectedColor,
                  items: ["Black", "White", "Brown", "Orange", "Mixed"],
                  onChanged: (value) {
                    setState(() {
                      _selectedColor = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Switch for Is Fixed
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

                // Switch for Is Adopted
                _buildSwitch(
                  label: "Adopted",
                  value: _isAdopted,
                  onChanged: (value) {
                    setState(() {
                      _isAdopted = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(_descriptionController, "Description",
                    maxLines: 5),
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
