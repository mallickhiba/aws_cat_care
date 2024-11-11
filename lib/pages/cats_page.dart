import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CatsPage extends StatefulWidget {
  const CatsPage({Key? key}) : super(key: key);

  @override
  _CatsPageState createState() => _CatsPageState();
}

class _CatsPageState extends State<CatsPage> {
  final CollectionReference _cats =
      FirebaseFirestore.instance.collection('cats');
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageUrl;

  // Text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _isFixedController = TextEditingController();
  final TextEditingController _isVaccinatedController = TextEditingController();

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('cat_images/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(File(pickedFile.path));
      final String downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
    }
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _ageController.text = documentSnapshot['age'].toString();
      _colorController.text = documentSnapshot['color'];
      _descriptionController.text = documentSnapshot['description'];
      _locationController.text = documentSnapshot['location'];
      _sexController.text = documentSnapshot['sex'];
      _isFixedController.text = documentSnapshot['isFixed'].toString();
      _isVaccinatedController.text =
          documentSnapshot['isVaccinated'].toString();
      _uploadedImageUrl = documentSnapshot['imageURL'];
    } else {
      _nameController.clear();
      _ageController.clear();
      _colorController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _sexController.clear();
      _isFixedController.clear();
      _isVaccinatedController.clear();
      _uploadedImageUrl = null;
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
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: _sexController,
                decoration: const InputDecoration(labelText: 'Sex'),
              ),
              TextField(
                controller: _isFixedController,
                decoration:
                    const InputDecoration(labelText: 'Fixed (true/false)'),
              ),
              TextField(
                controller: _isVaccinatedController,
                decoration:
                    const InputDecoration(labelText: 'Vaccinated (true/false)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickAndUploadImage,
                child: const Text('Upload Image'),
              ),
              if (_uploadedImageUrl != null)
                Image.network(_uploadedImageUrl!, height: 100),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(documentSnapshot != null ? 'Update' : 'Create'),
                onPressed: () async {
                  final String name = _nameController.text;
                  final int? age = int.tryParse(_ageController.text);
                  final String color = _colorController.text;
                  final String description = _descriptionController.text;
                  final String location = _locationController.text;
                  final String sex = _sexController.text;
                  final bool isFixed =
                      _isFixedController.text.toLowerCase() == 'true';
                  final bool isVaccinated =
                      _isVaccinatedController.text.toLowerCase() == 'true';

                  if (name.isNotEmpty &&
                      age != null &&
                      _uploadedImageUrl != null) {
                    final catData = {
                      "name": name,
                      "age": age,
                      "color": color,
                      "description": description,
                      "location": location,
                      "sex": sex,
                      "isFixed": isFixed,
                      "isVaccinated": isVaccinated,
                      "imageURL": _uploadedImageUrl,
                    };

                    if (documentSnapshot != null) {
                      await _cats.doc(documentSnapshot.id).update(catData);
                    } else {
                      await _cats.add(catData);
                    }

                    // Clear input fields
                    _nameController.clear();
                    _ageController.clear();
                    _colorController.clear();
                    _descriptionController.clear();
                    _locationController.clear();
                    _sexController.clear();
                    _isFixedController.clear();
                    _isVaccinatedController.clear();
                    _uploadedImageUrl = null;

                    Navigator.of(context).pop();
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

    ScaffoldMessenger.of(context).showSnackBar(
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
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Age: ${documentSnapshot['age']}"),
                        Text("Color: ${documentSnapshot['color']}"),
                        Text("Description: ${documentSnapshot['description']}"),
                        Text("Location: ${documentSnapshot['location']}"),
                        Text("Sex: ${documentSnapshot['sex']}"),
                        Text(
                            "Fixed: ${documentSnapshot['isFixed'] ? 'Yes' : 'No'}"),
                        Text(
                            "Vaccinated: ${documentSnapshot['isVaccinated'] ? 'Yes' : 'No'}"),
                      ],
                    ),
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
        child: const Icon(Icons.add),
        tooltip: 'Add New Cat',
      ),
    );
  }
}
