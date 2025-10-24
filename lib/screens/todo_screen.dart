import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/widgets/task_item.dart';
import 'package:todo_list/widgets/days_list.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final GlobalKey<DaysListState> _weekKey = GlobalKey<DaysListState>();
  late TextEditingController _controller;
  bool _isDateRowMiddle = true;
  final String _now = DateFormat.yMd().format(DateTime.now());
  String _currentDateSelected = DateFormat.yMd().format(DateTime.now());
  bool _isCalendarSelection = false;
  bool _isInCalendarSelectionRange = false;
  final tasksBox = Hive.box<Task>('tasks');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTask(String name) async {
    await tasksBox.add(
      Task(
        DateTime.now().millisecondsSinceEpoch,
        title: name,
        date: _currentDateSelected,
      ),
    );
  }

  void _removeTask(int id) async {
    final task = tasksBox.values.firstWhere((t) => t.id == id);
    await task.delete();
  }

  void _updateTask(int id, String name) async {
    final task = tasksBox.values.firstWhere((t) => t.id == id);

    task.title = name;
    await task.save();
  }

  void _changeTaskState(int id) async {
    final task = tasksBox.values.firstWhere((t) => t.id == id);

    task.isDone = !task.isDone;
    await task.save();
  }

  List<Task> _getFinishedTasksList(List<Task> tasks) {
    return tasks
        .where((t) => t.isDone == true && t.date == _currentDateSelected)
        .toList();
  }

  List<Task> _getTasksList(List<Task> tasks) {
    return tasks
        .where((t) => t.isDone == false && t.date == _currentDateSelected)
        .toList();
  }

  void _scrollToMiddle() {
    setState(() {
      _isDateRowMiddle = true;
    });
    _weekKey.currentState?.scrollToMiddle();
  }

  Future<String?> _openDialog() => showDialog<String>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("Task"),
          content: TextField(
            autofocus: true,
            controller: _controller,
            onSubmitted: (_) => _submit(),
          ),
          actions: [TextButton(onPressed: _submit, child: Text("Add"))],
        ),
  );

  void _submit() {
    Navigator.of(context).pop(_controller.text);
    _controller.clear();
  }

  String _getCurentDate() {
    DateTime now = DateTime.now();
    String dateFormat = DateFormat('EEEE d MMMM').format(now);
    return dateFormat;
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2032),
    );
    if (pickedDate == null) return;
    setState(() {
      _currentDateSelected = DateFormat.yMd().format(pickedDate);
      _isCalendarSelection = true;
      _isInCalendarSelectionRange = true;
      _isDateRowMiddle = false;
    });
    _weekKey.currentState?.createDaysList(DateFormat.yMd().format(pickedDate));
    _weekKey.currentState?.initMiddleScroll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0.0,
        actions: [
          IconButton(
            onPressed: () => _selectDate(),
            icon: Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Task>('tasks').listenable(),
        builder: (context, Box<Task> box, _) {
          final tasks = box.values.toList().cast<Task>();
          List<Task> tasksList = _getTasksList(tasks);
          var finishedTasksList = _getFinishedTasksList(tasks);
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 26.0,
                  ),
                ),
                Text(
                  "Schedule",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 26.0,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getCurentDate(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16.0,
                      ),
                    ),
                    !_isDateRowMiddle || _currentDateSelected != _now
                        ? GestureDetector(
                          onTap:
                              () => {
                                if (_currentDateSelected != _now &&
                                    _isInCalendarSelectionRange)
                                  {
                                    setState(() {
                                      _currentDateSelected = _now;
                                      _weekKey.currentState?.createDaysList(
                                        _now,
                                      );
                                      _weekKey.currentState?.initMiddleScroll();
                                      _isCalendarSelection = false;
                                      _isInCalendarSelectionRange = false;
                                      _isDateRowMiddle = true;
                                    }),
                                  }
                                else
                                  {
                                    setState(() {
                                      _isCalendarSelection = false;
                                    }),
                                    _scrollToMiddle(),
                                  },
                              },
                          child: Text("Current day"),
                        )
                        : Container(),
                  ],
                ),
                SizedBox(height: 16),
                DaysList(
                  key: _weekKey,
                  tasks: tasks,
                  selectedDate: _currentDateSelected,
                  isCalendarSelection: _isCalendarSelection,
                  onNotMiddle: (newValue) {
                    setState(() {
                      _isDateRowMiddle = newValue;
                    });
                  },
                  onSelectDate: (newSelectedDate, newValue) {
                    setState(() {
                      _currentDateSelected = newSelectedDate;
                      _isCalendarSelection = newValue;
                    });
                  },
                ),
                tasksList.isNotEmpty
                    ? Expanded(
                      child: ListView.separated(
                        itemCount: tasksList.length,
                        itemBuilder: (context, index) {
                          final t = tasksList[index];
                          return TaskItem(
                            key: ValueKey('$_currentDateSelected${t.title}'),
                            title: t.title,
                            isDone: t.isDone,
                            onEdit: (newValue) => _updateTask(t.id, newValue),
                            onDelete: () => _removeTask(t.id),
                            onChangeState: () => _changeTaskState(t.id),
                          );
                        },
                        separatorBuilder:
                            (context, index) => SizedBox(height: 10),
                      ),
                    )
                    : Center(child: Text("No tasks")),

                finishedTasksList.isNotEmpty
                    ? Text("Finished tasks")
                    : SizedBox(),
                SizedBox(height: 16),
                finishedTasksList.isNotEmpty
                    ? Expanded(
                      child: ListView.separated(
                        itemCount: finishedTasksList.length,
                        itemBuilder: (context, index) {
                          final ft = finishedTasksList[index];
                          return TaskItem(
                            key: ValueKey('$_currentDateSelected${ft.title}'),
                            title: ft.title,
                            isDone: ft.isDone,
                            onDelete: () => _removeTask(ft.id),
                            onChangeState: () => _changeTaskState(ft.id),
                          );
                        },
                        separatorBuilder:
                            (context, index) => SizedBox(height: 10),
                      ),
                    )
                    : Center(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () async {
          final name = await _openDialog();
          if (name == null || name.isEmpty) return;
          _addTask(name);
        },
        tooltip: 'Add task',
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
