import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:aws_cat_care/blocs/update_cat_bloc/update_cat_bloc.dart';

class CatDetailScreen extends StatefulWidget {
  final Cat cat;

  const CatDetailScreen({Key? key, required this.cat}) : super(key: key);

  @override
  State<CatDetailScreen> createState() => _CatDetailScreenState();
}

class _CatDetailScreenState extends State<CatDetailScreen> {
  late Cat editableCat;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editableCat = widget.cat;

    // Initialize controllers with current cat data
    _nameController.text = editableCat.catName;
    _ageController.text = editableCat.age.toString();
    _locationController.text = editableCat.location;
    _descriptionController.text = editableCat.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCatBloc, UpdateCatState>(
      listener: (context, state) {
        if (state is UpdateCatSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cat updated successfully!")),
          );
        } else if (state is UpdateCatFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update cat: ${state.error}")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cat Details"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(editableCat.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "Name"),
                const SizedBox(height: 10),
                _buildTextField(_ageController, "Age",
                    inputType: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField(_locationController, "Location"),
                const SizedBox(height: 10),
                _buildTextField(_descriptionController, "Description",
                    maxLines: 3),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Update the editableCat object
                    setState(() {
                      editableCat = editableCat.copyWith(
                        catName: _nameController.text,
                        age: int.tryParse(_ageController.text) ??
                            editableCat.age,
                        location: _locationController.text,
                        description: _descriptionController.text,
                      );
                    });

                    // Dispatch update event
                    context.read<UpdateCatBloc>().add(UpdateCat(editableCat));
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
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
}
