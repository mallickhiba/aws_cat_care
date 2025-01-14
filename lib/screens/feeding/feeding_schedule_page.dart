import 'dart:developer';

import 'package:aws_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aws_app/blocs/get_all_users_bloc/get_all_users_bloc.dart';
import 'package:aws_app/screens/feeding/add_feeding_task_page.dart';

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

  void _initializeFeedingSchedules() {
    final userState = context.read<GetAllUsersBloc>().state;

    if (userState is! GetAllUsersSuccess) {
      context.read<GetAllUsersBloc>().add(FetchAllUsers());
      log("Dispatching FetchAllUsers event.");
    }

    context.read<GetAllUsersBloc>().stream.firstWhere((state) {
      return state is GetAllUsersSuccess;
    }).then((_) {
      log("Users fetched successfully. Setting up feeding schedules listener.");
      _setupFeedingSchedulesListener();
    }).catchError((error) {
      log("Error fetching users: $error");
    });
  }

  void _setupFeedingSchedulesListener() {
    _firestore.collection('feeding_schedules').snapshots().listen((snapshot) {
      log("Received Firestore snapshot with ${snapshot.docs.length} documents.");
      _processFeedingSchedules(snapshot);
    });
  }

  void _processFeedingSchedules(QuerySnapshot snapshot) {
    final tasks = <DateTime, List<Map<String, dynamic>>>{};
    final userState = context.read<GetAllUsersBloc>().state;

    if (userState is GetAllUsersSuccess) {
      final users = {for (var user in userState.users) user.id: user.name};
      log("Mapped users: $users");

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        log("Processing document: ${doc.id}");

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

          final volunteerId = data['volunteer'] ?? "Unknown Volunteer";
          final volunteerName = users[volunteerId] ?? 'Unknown Volunteer';

          tasks[date]!.add({
            'id': doc.id,
            'slot': data['slot'] ?? 'Unknown Slot',
            'location': data['location'] ?? 'Unknown Location',
            'volunteer': volunteerName,
            'volunteerId': volunteerId,
            'completed': data['completed'] ?? false,
          });
        } else {
          log("Invalid date format in document: ${doc.id}");
        }
      }
    } else {
      log("User data not available for processing tasks.");
    }

    setState(() {
      _feedingTasks = tasks;
      log("Updated feeding tasks state.");
    });
  }

  List<Map<String, dynamic>> _getTasksForSelectedDay() {
    final normalizedSelectedDay = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    return _feedingTasks[normalizedSelectedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<MyUserBloc>().state.user?.id ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeding Schedule"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFeedingTaskPage(),
                ),
              );
            },
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
                  trailing: task['volunteerId'] == currentUserId
                      ? (task['completed']
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.check_circle_outline,
                                  color: Colors.green),
                              onPressed: () {
                                _markTaskAsDone(task['id']);
                              },
                            ))
                      : const Icon(Icons.check_circle_outline,
                          color: Colors.grey),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markTaskAsDone(String taskId) async {
    try {
      await _firestore
          .collection('feeding_schedules')
          .doc(taskId)
          .update({'completed': true});
      log("Marked task $taskId as completed.");
    } catch (e) {
      log("Error marking task as completed: $e");
    }
  }
}
