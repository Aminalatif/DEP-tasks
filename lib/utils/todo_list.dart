
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ToDolist extends StatelessWidget {
  const ToDolist({
    Key? key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deletefunction,
    required this.taskDateTime,
  }) : super(key: key);

  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deletefunction;
  final DateTime taskDateTime;

  @override
  Widget build(BuildContext context) {
    Duration remainingTime = taskDateTime.difference(DateTime.now());
    bool isOverdue = remainingTime.isNegative;

    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 0,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (value) => deletefunction!(context),
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(17),
              backgroundColor: Colors.red,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(15),
            border: isOverdue ? Border.all(color: Colors.red, width: 2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: taskCompleted,
                    onChanged: onChanged,
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    taskName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                isOverdue
                    ? 'Overdue'
                    : 'Due in: ${remainingTime.inHours} hours ${remainingTime.inMinutes.remainder(60)} minutes',
                style: TextStyle(
                  color: isOverdue ? Colors.red : Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


