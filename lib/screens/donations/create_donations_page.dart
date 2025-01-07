import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateDonationsPage extends StatefulWidget {
  const CreateDonationsPage({super.key});

  @override
  State<CreateDonationsPage> createState() => _CreateDonationsPageState();
}

class _CreateDonationsPageState extends State<CreateDonationsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _bankDetailsController = TextEditingController();
  final List<File> _images = [];

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.clear();
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (File image in _images) {
      String fileName =
          'donations/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  Future<void> _createCampaign() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _goalController.text.isNotEmpty &&
        _bankDetailsController.text.isNotEmpty &&
        _images.isNotEmpty) {
      List<String> imageUrls =
          await _uploadImages(); // Upload images and get URLs

      final campaignData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'goal': int.parse(_goalController.text),
        'progress': 0,
        'bankDetails': _bankDetailsController.text,
        'images': imageUrls,
        'createdAt': Timestamp.now(),
      };

      // Add campaign to Firestore
      await FirebaseFirestore.instance
          .collection('donations')
          .add(campaignData);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("All fields are required, including at least one image.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Donation Campaign")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: "Goal Amount",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bankDetailsController,
              decoration: const InputDecoration(
                labelText: "Bank Details",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text("Pick Images"),
            ),
            // Display thumbnails of selected images
            Wrap(
              spacing: 8.0, // Gap between adjacent chips.
              runSpacing: 4.0, // Gap between lines.
              children: _images
                  .map((file) => Image.file(file, width: 100, height: 100))
                  .toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createCampaign,
              child: const Text("Create Campaign"),
            ),
          ],
        ),
      ),
    );
  }
}
