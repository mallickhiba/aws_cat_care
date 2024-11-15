import 'package:aws_cat_care/pages/cat_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CatsPage extends StatefulWidget {
  const CatsPage({super.key});

  @override
  State<CatsPage> createState() => _CatsPage();
}

class _CatsPage extends State<CatsPage> {
  final CollectionReference _cats =
      FirebaseFirestore.instance.collection('cats');

  // Text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController =
      TextEditingController(); // Controller for image URL

  // Dropdown values and boolean flags for checkboxes
  String? _location = '';
  String? _sex = '';
  bool _isFixed = false;
  bool _isVaccinated = false;

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      _nameController.text = data['name'];
      _ageController.text = data['age'].toString();
      _colorController.text = data['color'];
      _descriptionController.text = data['description'];
      _location = data['location'];
      _sex = data['sex'];
      _isFixed = data['isFixed'];
      _isVaccinated = data['isVaccinated'];
      _imageUrlController.text = data['imageURL'] ?? '';
    } else {
      _nameController.clear();
      _ageController.clear();
      _colorController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      _location = 'Tabba';
      _sex = 'M';
      _isFixed = false;
      _isVaccinated = false;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                items: [
                  'Tabba',
                  'Courtyard',
                  'Library',
                  'Student Centre',
                ].map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _sex,
                decoration: const InputDecoration(labelText: 'Sex'),
                items: ['M', 'F'].map((sex) {
                  return DropdownMenuItem(
                    value: sex,
                    child: Text(sex),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sex = value;
                  });
                },
              ),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isFixed,
                    onChanged: (bool? value) {
                      setState(() {
                        _isFixed = value ?? false;
                      });
                    },
                  ),
                  const Text('Fixed'),
                  Checkbox(
                    value: _isVaccinated,
                    onChanged: (bool? value) {
                      setState(() {
                        _isVaccinated = value ?? false;
                      });
                    },
                  ),
                  const Text('Vaccinated'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(documentSnapshot != null ? 'Update' : 'Create'),
                onPressed: () async {
                  final String name = _nameController.text;
                  final int? age = int.tryParse(_ageController.text);
                  final String color = _colorController.text;
                  final String description = _descriptionController.text;
                  final String? imageURL = _imageUrlController.text.isNotEmpty
                      ? _imageUrlController.text
                      : null;

                  if (name.isNotEmpty && age != null) {
                    final catData = {
                      "name": name,
                      "age": age,
                      "color": color,
                      "description": description,
                      "location": _location,
                      "sex": _sex,
                      "isFixed": _isFixed,
                      "isVaccinated": _isVaccinated,
                      "imageURL": imageURL,
                    };

                    if (documentSnapshot != null) {
                      await _cats.doc(documentSnapshot.id).update(catData);
                    } else {
                      await _cats.add(catData);
                    }

                    Navigator.of(context.mounted as BuildContext).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(String catId) async {
    await _cats.doc(catId).delete();
    ScaffoldMessenger.of(context.mounted as BuildContext).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted a cat')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cats'),
      ),
      body: StreamBuilder(
        stream: _cats.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                final data = documentSnapshot.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: data['imageURL'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(data['imageURL']),
                            radius: 30,
                          )
                        : const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.pets),
                          ),
                    title: Text(data['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Age: ${data['age']}"),
                        Text("Color: ${data['color']}"),
                        Text("Description: ${data['description']}"),
                        Text("Location: ${data['location']}"),
                        Text("Sex: ${data['sex']}"),
                        Text("Fixed: ${data['isFixed'] ? 'Yes' : 'No'}"),
                        Text(
                            "Vaccinated: ${data['isVaccinated'] ? 'Yes' : 'No'}"),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CatProfilePage(cat: documentSnapshot),
                        ),
                      );
                    },
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _createOrUpdate(documentSnapshot),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _delete(documentSnapshot.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        tooltip: 'Add New Cat',
        child: const Icon(Icons.add),
      ),
    );
  }
}
