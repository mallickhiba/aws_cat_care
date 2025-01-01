import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddFeedingTaskPage extends StatefulWidget {
  const AddFeedingTaskPage({super.key});

  @override
  State<AddFeedingTaskPage> createState() => _AddFeedingTaskPageState();
}

class _AddFeedingTaskPageState extends State<AddFeedingTaskPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeSlotController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<Map<String, String>> _volunteer = [];

  Future<void> _addFeedingTask() async {
    if (_dateController.text.isNotEmpty &&
        _timeSlotController.text.isNotEmpty &&
        _locationController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('feeding_schedules').add({
        'datetime': _dateController.text,
        'slot': _timeSlotController.text,
        'location': _locationController.text,
        'volunteer': _volunteer,
      });
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
      appBar: AppBar(title: const Text("Add Feeding Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Date (YYYY-MM-DD)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timeSlotController,
              decoration: const InputDecoration(
                labelText: "Time Slot (e.g., 08:00-10:00)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFeedingTask,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
