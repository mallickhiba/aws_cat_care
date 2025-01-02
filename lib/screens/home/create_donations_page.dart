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
  List<File> _images = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _createCampaign() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _goalController.text.isNotEmpty &&
        _bankDetailsController.text.isNotEmpty) {
      final campaignData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'goal': int.parse(_goalController.text),
        'progress': 0,
        'bankDetails': _bankDetailsController.text,
        'images': [], // Placeholder for image URLs
        'createdAt': Timestamp.now(),
      };

      // Add campaign to Firestore
      await FirebaseFirestore.instance
          .collection('donations')
          .add(campaignData);

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
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
