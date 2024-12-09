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
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imagePath;

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
    _sexController.dispose();
    _colorController.dispose();
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
                  _sexController.text.isNotEmpty &&
                  _colorController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty) {
                setState(() {
                  cat = cat.copyWith(
                    catName: _nameController.text,
                    location: _locationController.text,
                    age: int.tryParse(_ageController.text) ?? 0,
                    sex: _sexController.text,
                    color: _colorController.text,
                    description: _descriptionController.text,
                    image: _imagePath ?? '',
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
                _buildTextField(_sexController, "Sex"),
                const SizedBox(height: 10),
                _buildTextField(_colorController, "Color"),
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
}
