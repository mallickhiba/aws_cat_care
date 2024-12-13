import 'package:aws_cat_care/blocs/create_incident_bloc/create_incident_bloc.dart';
import 'package:aws_cat_care/blocs/get_cat_bloc/get_cat_bloc.dart';
import 'package:aws_cat_care/blocs/get_incident_bloc/get_incident_bloc.dart';
import 'package:aws_cat_care/screens/home/add_incident.dart';
import 'package:aws_cat_care/screens/home/incidents_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_repository/cat_repository.dart';
import 'package:aws_cat_care/blocs/update_cat_bloc/update_cat_bloc.dart';
import 'package:incident_repository/incident_repository.dart';

class CatDetailScreen extends StatefulWidget {
  final Cat cat;

  const CatDetailScreen({super.key, required this.cat});

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
                const SizedBox(height: 10),

                // Dropdown for Sex
                _buildDropdown(
                  label: "Sex",
                  value: editableCat.sex,
                  items: ["Male", "Female", "Unknown"],
                  onChanged: (value) {
                    setState(() {
                      editableCat = editableCat.copyWith(sex: value);
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Dropdown for Color
                _buildDropdown(
                  label: "Color",
                  value: editableCat.color,
                  items: ["Black", "White", "Brown", "Orange", "Mixed"],
                  onChanged: (value) {
                    setState(() {
                      editableCat = editableCat.copyWith(color: value);
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => GetIncidentBloc(
                              incidentRepository: FirebaseIncidentRepository())
                            ..add(LoadIncident(catId: editableCat.catId)),
                          child: IncidentPage(catId: editableCat.catId),
                        ),
                      ),
                    );
                  },
                  child: const Text("View Incidents"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => CreateIncidentBloc(
                            incidentRepository: FirebaseIncidentRepository(),
                          ),
                          child: AddIncidentPage(catId: editableCat.catId),
                        ),
                      ),
                    );
                  },
                  child: const Text("Create Incident"),
                ),

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
