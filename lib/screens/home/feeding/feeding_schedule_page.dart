import 'dart:developer';
import 'package:aws_app/screens/home/feeding/add_feeding_task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aws_app/blocs/get_all_users_bloc/get_all_users_bloc.dart';

class FeedingSchedulePage extends StatefulWidget {
  const FeedingSchedulePage({super.key});

  @override
  State<FeedingSchedulePage> createState() => _FeedingSchedulePageState();
}

class _FeedingSchedulePageState extends State<FeedingSchedulePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _feedingTasks = {};

  @override
  void initState() {
    super.initState();
    _initializeFeedingSchedules();
  }

  Future<void> _initializeFeedingSchedules() async {
    final userState = context.read<GetAllUsersBloc>().state;
    if (userState is! GetAllUsersSuccess) {
      context.read<GetAllUsersBloc>().add(FetchAllUsers());
    }

    context.read<GetAllUsersBloc>().stream.firstWhere((state) {
      return state is GetAllUsersSuccess;
    }).then((_) {
      _loadFeedingSchedules();
    });
  }

  Future<void> _loadFeedingSchedules() async {
    try {
      final querySnapshot =
          await _firestore.collection('feeding_schedules').get();

      log('Fetched ${querySnapshot.docs.length} documents');

      final tasks = <DateTime, List<Map<String, dynamic>>>{};
      final userState = context.read<GetAllUsersBloc>().state;

      if (userState is GetAllUsersSuccess) {
        final users = {for (var user in userState.users) user.id: user.name};
        log('Mapped Users: $users');

        for (var doc in querySnapshot.docs) {
          log('Document ID: ${doc.id}');
          log('Document Data: ${doc.data()}');

          final data = doc.data();

          if (data['date'] is Timestamp) {
            final timestamp = data['date'] as Timestamp;
            final date = DateTime(
              timestamp.toDate().year,
              timestamp.toDate().month,
              timestamp.toDate().day,
            );

            if (!tasks.containsKey(date)) {
              tasks[date] = [];
            }

            final rawVolunteer = data['volunteer'];
            final volunteerId = rawVolunteer is String
                ? rawVolunteer.replaceAll('"', '') // Remove extra quotes
                : rawVolunteer;

            final volunteerName = users[volunteerId] ?? 'Unknown Volunteer';

            tasks[date]!.add({
              'id': doc.id,
              'slot': data['slot'] ?? 'Unknown Slot',
              'location': data['location'] ?? 'Unknown Location',
              'volunteer': volunteerName,
              'completed': data['completed'] ?? false, // Default to false
            });
          } else {
            log('Invalid datetime format for document: ${doc.id}');
          }
        }
      } else {
        log('User data not loaded or available');
      }

      log('Parsed tasks: $tasks');

      setState(() {
        _feedingTasks = tasks;
      });
    } catch (e, stackTrace) {
      log('Error loading feeding schedules: $e');
      log(stackTrace.toString());
    }
  }

  Future<void> _markTaskAsDone(String taskId) async {
    try {
      await _firestore
          .collection('feeding_schedules')
          .doc(taskId)
          .update({'completed': true});
      _loadFeedingSchedules(); // Reload tasks to reflect the change
    } catch (e) {
      log('Error marking task as done: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to mark task as done.")),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getTasksForSelectedDay() {
    final normalizedSelectedDay = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    return _feedingTasks[normalizedSelectedDay] ?? [];
  }

  void _addTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddFeedingTaskPage(),
      ),
    ).then((_) => _loadFeedingSchedules());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeding Schedule"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTask,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            eventLoader: (day) => _feedingTasks[day] ?? [],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: _getTasksForSelectedDay().map((task) {
                return ListTile(
                  title: Text(task['slot']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location: ${task['location']}"),
                      Text("Volunteer: ${task['volunteer']}"),
                    ],
                  ),
                  trailing: task['completed']
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.grey),
                          onPressed: () {
                            _markTaskAsDone(task['id']);
                          },
                        ),
                  onTap: () {
                    // Add functionality to view or edit task
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
