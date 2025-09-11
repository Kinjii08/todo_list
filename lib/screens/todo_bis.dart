import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/widgets/task_item.dart';
import 'package:todo_list/widgets/days_list.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final GlobalKey<DaysListState> _weekKey = GlobalKey<DaysListState>();
  final Map<String, dynamic> _dailyTasks = {};
  late TextEditingController _controller;
  bool _isDateRowMiddle = true;
  final String _now = DateFormat.yMd().format(DateTime.now());
  String _currentDateSelected = DateFormat.yMd().format(DateTime.now());
  bool _isCalendarSelection = false;

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

  void _addTask(String name) {
    if (_dailyTasks.isEmpty) {
      _dailyTasks.putIfAbsent(
        _currentDateSelected,
        () => {
          "tasks": [],
        },
      );
      setState(() {
        _dailyTasks[_currentDateSelected]!["tasks"]!.add({'id': 1, "title": name, "isDone": false});
      });
      // _weekKey.currentState?.createDaysList();
      return;
    }
    if (_dailyTasks.containsKey(_currentDateSelected)) {
      setState(() {
        _dailyTasks[_currentDateSelected]!["tasks"]!.add(name);
      });
    } else {
      setState(() {
        _dailyTasks.putIfAbsent(
          _currentDateSelected,
          () => {"tasks": [], "finishedTasks": []},
        );
        _dailyTasks[_currentDateSelected]!["tasks"]!.add(name);
      });
    }
    // _weekKey.currentState?.createDaysList();
  }

  void _removeTask(int index) {
    setState(() {
      _dailyTasks[_currentDateSelected]!["tasks"]!.removeAt(index);
    });
    // _weekKey.currentState?.createDaysList();
  }

  void _updateTask(int index, String name) {
    setState(() {
      _dailyTasks[_currentDateSelected]!["tasks"]![index]['title'] = name;
    });
  }

  void _changeTaskState(int index) {
    setState(() {
      _dailyTasks[_currentDateSelected]!["tasks"]![index]['isDone'] =
          !_dailyTasks[_currentDateSelected]!["tasks"]![index]['isDone'];
    });
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

  void _scrollToMiddle() {
    _weekKey.currentState?.scrollToMiddle();
    setState(() {
      _isDateRowMiddle = true;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2032),
    );
    // print(pickedDate);
    setState(() {
      _currentDateSelected = DateFormat.yMd().format(pickedDate!);
      _isCalendarSelection = true;
      _isDateRowMiddle = false;
    });
    // _weekKey.currentState?.createDaysList();
    // _weekKey.currentState?.initMiddleScroll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                !_isDateRowMiddle
                    ? GestureDetector(
                      onTap:
                          () => {
                            setState(() {
                              _isCalendarSelection = false;
                              _currentDateSelected = _now;
                            }),
                            _scrollToMiddle(),
                          },
                      child: Text("Current day"),
                    )
                    : Container(),
              ],
            ),
            SizedBox(height: 16),
            // Text(_isCalendarSelection.toString()),
            DaysList(
              key: _weekKey,
              tasks: _dailyTasks,
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
            isTasksEmpty
                ? Expanded(
                  child: ListView.separated(
                    itemCount:
                        _dailyTasks[_currentDateSelected]!["tasks"]!.length,
                    itemBuilder: (context, index) {
                      String task =
                          _dailyTasks[_currentDateSelected]!["tasks"]![index]['title'];
                      return TaskItem(
                        key: ValueKey('$_currentDateSelected$task'),
                        title: task,
                        onEdit: (newValue) => _updateTask(index, newValue),
                        onDelete: () => _removeTask(index),
                        onChangeState: () => _changeTaskState(index),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                  ),
                )
                : Center(child: Text("Aucune tâche")),
            !isFinishedTasksEmpty ? SizedBox(height: 52) : SizedBox(height: 16),
            isFinishedTasksEmpty ? Text("Finished") : SizedBox(),
            SizedBox(height: 16),
            isFinishedTasksEmpty
                ? Expanded(
                  child: ListView.separated(
                    itemCount:
                        _dailyTasks[_currentDateSelected]!["finishedTasks"]!
                            .length,
                    itemBuilder: (context, index) {
                      String task =
                          _dailyTasks[_currentDateSelected]!["tasks"]![index];
                      return TaskItem(
                        key: ValueKey('$_currentDateSelected$task'),
                        title: task.title,
                        isDone: ,
                        onDelete: () => _removeTask(index),
                        onChangeState: () => _changeTaskState(index),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                  ),
                )
                : Container(),
          ],
        ),
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
