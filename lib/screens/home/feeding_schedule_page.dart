import 'package:aws_cat_care/screens/home/add_feeding_task_page.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    _loadFeedingSchedules();
  }

  Future<void> _loadFeedingSchedules() async {
    final querySnapshot =
        await _firestore.collection('feeding_schedules').get();
    final tasks = <DateTime, List<Map<String, dynamic>>>{};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(data['datetime']);
      if (!tasks.containsKey(date)) {
        tasks[date] = [];
      }
      tasks[date]!.add({
        'id': doc.id,
        'slot': data['slot'],
        'location': data['location'],
        'volunteer': data['volunteer'],
      });
    }

    setState(() {
      _feedingTasks = tasks;
    });
  }

  List<Map<String, dynamic>> _getTasksForSelectedDay() {
    return _feedingTasks[_selectedDay] ?? [];
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
                  subtitle: Text("Location: ${task['location']}"),
                  trailing: Text("Volunteers: ${task['volunteer'].length}"),
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
