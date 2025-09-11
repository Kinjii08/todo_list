import 'package:flutter/material.dart';
import 'package:todo_list/widgets/notification_tasks.dart';

class Day extends StatefulWidget {
  final Map<String, Map<String, Object>> day;
  final bool isSelected;
  const Day({super.key, required this.day, required this.isSelected});

  @override
  State<StatefulWidget> createState() => _DayState();
}

class _DayState extends State<Day> {
  @override
  void didUpdateWidget(covariant Day oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.day != widget.day) {}
  }

  String _displayDay(String date) {
    return date.split('/')[1];
  }

  @override
  Widget build(BuildContext context) {
    String newKey = "";
    Map<String, Object> newValue = {};
    widget.day.forEach((key, value) {
      newKey = key;
      newValue = value;
    });
    return SizedBox(
      width: 22.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            newValue["weekDay"] as String,
            style: TextStyle(
              fontSize: 18,
              color: widget.isSelected ? Colors.white : Colors.white70,
              fontWeight:
                  widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _displayDay(newKey),
            style: TextStyle(
              fontSize: 18,
              color: widget.isSelected ? Colors.white : Colors.white70,
              fontWeight:
                  widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          NotificationTasks(
            hasTasks: newValue["tasks"] as bool,
            hasFinishedTasks: newValue["finishedTasks"] as bool,
          ),
        ],
      ),
    );
  }
}
