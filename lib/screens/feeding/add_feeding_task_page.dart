import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aws_app/blocs/get_all_users_bloc/get_all_users_bloc.dart';

class AddFeedingTaskPage extends StatefulWidget {
  const AddFeedingTaskPage({super.key});

  @override
  State<AddFeedingTaskPage> createState() => _AddFeedingTaskPageState();
}

class _AddFeedingTaskPageState extends State<AddFeedingTaskPage> {
  DateTime? _selectedDate;
  DateTime? _repeatUntilDate; // New: End date for repeating tasks
  String? _selectedTimeSlot;
  String? _selectedVolunteer;
  String? _selectedBackup;
  bool _repeatWeekly = false; // New: Toggle for repeating weekly

  final List<String> _timeSlots = ["Morning", "Evening"];

  Future<void> _addFeedingTask() async {
    if (_selectedDate != null &&
        _selectedTimeSlot != null &&
        _selectedVolunteer != null &&
        _selectedBackup != null) {
      // Calculate all dates based on weekly repetition
      List<DateTime> taskDates = [_selectedDate!];

      if (_repeatWeekly && _repeatUntilDate != null) {
        DateTime nextDate = _selectedDate!.add(const Duration(days: 7));

        while (nextDate.isBefore(_repeatUntilDate!) ||
            nextDate.isAtSameMomentAs(_repeatUntilDate!)) {
          taskDates.add(nextDate);
          nextDate = nextDate.add(const Duration(days: 7));
        }
      }

      // Store all feeding schedules
      for (var date in taskDates) {
        await FirebaseFirestore.instance.collection('feeding_schedules').add({
          'date': Timestamp.fromDate(date),
          'slot': _selectedTimeSlot,
          'volunteer': _selectedVolunteer,
          'backup': _selectedBackup,
        });
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
      );
    }
  }

  void _pickDate({bool isRepeatUntil = false}) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          isRepeatUntil ? (_selectedDate ?? DateTime.now()) : DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        if (isRepeatUntil) {
          _repeatUntilDate = selectedDate;
        } else {
          _selectedDate = selectedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAllUsersBloc, GetAllUsersState>(
      builder: (context, state) {
        if (state is GetAllUsersLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is GetAllUsersSuccess) {
          final users = state.users;
          final userOptions = users
              .map((user) => DropdownMenuItem(
                    value: user.id,
                    child: Text(user.name),
                  ))
              .toList();

          return Scaffold(
            appBar: AppBar(title: const Text("Assign Feeding Duty")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickDate(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate != null
                                  ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                                  : "Select Date",
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedTimeSlot,
                      items: _timeSlots
                          .map((slot) => DropdownMenuItem(
                                value: slot,
                                child: Text(slot),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeSlot = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Time Slot",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedVolunteer,
                      items: userOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedVolunteer = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Volunteer",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedBackup,
                      items: userOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedBackup = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Backup",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _repeatWeekly,
                          onChanged: (bool? value) {
                            setState(() {
                              _repeatWeekly = value ?? false;
                            });
                          },
                        ),
                        const Text("Repeat this every week"),
                      ],
                    ),
                    if (_repeatWeekly)
                      GestureDetector(
                        onTap: () => _pickDate(isRepeatUntil: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _repeatUntilDate != null
                                    ? "${_repeatUntilDate!.year}-${_repeatUntilDate!.month.toString().padLeft(2, '0')}-${_repeatUntilDate!.day.toString().padLeft(2, '0')}"
                                    : "Select Repeat Until Date",
                                style: TextStyle(
                                  color: _repeatUntilDate != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
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
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text("Failed to load users.")),
          );
        }
      },
    );
  }
}
