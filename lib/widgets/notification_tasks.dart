import 'package:flutter/material.dart';

class NotificationTasks extends StatefulWidget {
  final bool hasTasks;
  final bool hasFinishedTasks;
  const NotificationTasks({
    super.key,
    required this.hasTasks,
    required this.hasFinishedTasks,
  });

  @override
  State<StatefulWidget> createState() => _NotificationTasksState();
}

class _NotificationTasksState extends State<NotificationTasks> {
  @override
  Widget build(BuildContext context) {
    bool hasTasks = widget.hasTasks;
    bool hasFinishedTasks = widget.hasFinishedTasks;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        hasTasks
            ? Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            )
            : Container(),
        hasFinishedTasks && hasTasks ? SizedBox(width: 5) : SizedBox(),
        hasFinishedTasks
            ? Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 139, 63, 211),
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            )
            : Container(),
      ],
    );
  }
}
