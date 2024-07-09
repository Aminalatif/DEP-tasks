
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/todo_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Homepage extends StatefulWidget {
  Homepage({Key? key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _controller = TextEditingController();
  late Box _todoBox;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    openBox();
    tz.initializeTimeZones();
  }

  Future<void> openBox() async {
    _todoBox = await Hive.openBox('todoBox');
    if (_todoBox.isEmpty) {
      _todoBox.addAll([
        ['Learn singing', false, DateTime.now().add(Duration(hours: 1))],
        ['Do Exercise', false, DateTime.now().add(Duration(hours: 2))],
        ['Visit dentist', false, DateTime.now().add(Duration(hours: 3))],
      ]);
    }
    setState(() {}); // Trigger a rebuild after the box is opened
  }

  List get todolist => _todoBox.values.toList();

  void checkBoxChanged(int index) {
    setState(() {
      var task = _todoBox.getAt(index);
      _todoBox.putAt(index, [task[0], !task[1], task[2]]);
    });
  }

  void savetask(DateTime scheduleTime) {
    setState(() {
      _todoBox.add([_controller.text, false, scheduleTime]);
      _controller.clear();
    });
    scheduleNotification(_controller.text, scheduleTime); // Call notification scheduling
  }

  void deletetask(int index) {
    setState(() {
      _todoBox.deleteAt(index);
    });
  }

  void scheduleNotification(String taskName, DateTime scheduleTime) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Task Reminder',
      'It\'s time to $taskName',
      tz.TZDateTime.from(scheduleTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime scheduledTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        savetask(scheduledTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('todoBox')) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Simple Todo'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: todolist.length,
        itemBuilder: (BuildContext context, index) {
          var task = todolist[index];
          return ToDolist(
            key: Key('$index-${task[0]}'), // Add key for proper widget update
            taskName: task[0],
            taskCompleted: task[1],
            onChanged: (value) => checkBoxChanged(index),
            deletefunction: (value) => deletetask(index), // Changed to match the function signature
            taskDateTime: task[2],
          );
        },
      ),
      floatingActionButton: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Add new to list',
                  filled: true,
                  fillColor: Colors.green,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () => _selectDateTime(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
