import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/widgets/task_item.dart';
import 'package:todo_list/widgets/week.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final GlobalKey<WeekState> _weekKey = GlobalKey<WeekState>();
  final Map<String, Map<String, List<String>>> _dalyTasks = {};
  late TextEditingController _controller;
  bool _isDateRowMiddle = true;
  String _currentDateSelected = DateFormat.yMd().format(DateTime.now());

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
    if (_dalyTasks.isEmpty) {
      setState(() {
        _dalyTasks.putIfAbsent(
          _currentDateSelected,
          () => {"tasks": [], "finishedTasks": []},
        );
        _dalyTasks[_currentDateSelected]!["tasks"]!.add(name);
      });
      return;
    }
    if (_dalyTasks.containsKey(_currentDateSelected)) {
      setState(() {
        _dalyTasks[_currentDateSelected]!["tasks"]!.add(name);
      });
    } else {
      setState(() {
        _dalyTasks.putIfAbsent(
          _currentDateSelected,
          () => {"tasks": [], "finishedTasks": []},
        );
        _dalyTasks[_currentDateSelected]!["tasks"]!.add(name);
      });
    }
  }

  void _removeTask(int index, bool isDone) {
    setState(() {
      if (isDone) {
        _dalyTasks[_currentDateSelected]!["finishedTasks"]!.removeAt(index);
      } else {
        _dalyTasks[_currentDateSelected]!["tasks"]!.removeAt(index);
      }
    });
  }

  void _updateTask(int index, String name) {
    setState(() {
      _dalyTasks[_currentDateSelected]!["tasks"]![index] = name;
    });
  }

  void _checkState(bool isDone, index) {
    if (isDone) _moveToFinished(index);
    if (!isDone) _removeFromFinished(index);
  }

  void _moveToFinished(int index) {
    setState(() {
      _dalyTasks[_currentDateSelected]!["finishedTasks"]!.add(
        _dalyTasks[_currentDateSelected]!["tasks"]![index],
      );
      _dalyTasks[_currentDateSelected]!["tasks"]!.removeAt(index);
    });
  }

  void _removeFromFinished(index) {
    setState(() {
      _dalyTasks[_currentDateSelected]!["tasks"]!.insert(
        0,
        _dalyTasks[_currentDateSelected]!["finishedTasks"]![index],
      );
      _dalyTasks[_currentDateSelected]!["finishedTasks"]!.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    bool isTasksEmpty =
        _dalyTasks.isNotEmpty &&
        _dalyTasks[_currentDateSelected] != null &&
        _dalyTasks[_currentDateSelected]!["tasks"] != null &&
        _dalyTasks[_currentDateSelected]!["tasks"]!.isNotEmpty;
    bool isFinishedTasksEmpty =
        _dalyTasks.isNotEmpty &&
        _dalyTasks[_currentDateSelected] != null &&
        _dalyTasks[_currentDateSelected]!["finishedTasks"] != null &&
        _dalyTasks[_currentDateSelected]!["finishedTasks"]!.isNotEmpty;
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0.0,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.calendar_month)),
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
                      onTap: () => {_scrollToMiddle()},
                      child: Text("Current day"),
                    )
                    : Container(),
              ],
            ),
            SizedBox(height: 16),
            Week(
              key: _weekKey,
              onNotMiddle: (newValue) {
                setState(() {
                  _isDateRowMiddle = newValue;
                });
              },
            ),
            isTasksEmpty
                ? Expanded(
                  child: ListView.separated(
                    itemCount:
                        _dalyTasks[_currentDateSelected]!["tasks"]!.length,
                    itemBuilder: (context, index) {
                      String task =
                          _dalyTasks[_currentDateSelected]!["tasks"]![index];
                      return TaskItem(
                        key: ValueKey('$_currentDateSelected$task'),
                        title: task,
                        isDone: false,
                        onEdit: (newValue) => _updateTask(index, newValue),
                        onDelete: () => _removeTask(index, false),
                        onFinished: (isDone) => _checkState(isDone, index),
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
                        _dalyTasks[_currentDateSelected]!["finishedTasks"]!
                            .length,
                    itemBuilder: (context, index) {
                      String finishedTask =
                          _dalyTasks[_currentDateSelected]!["finishedTasks"]![index];
                      return TaskItem(
                        key: ValueKey('$_currentDateSelected$finishedTask'),
                        title: finishedTask,
                        isDone: true,
                        onDelete: () => _removeTask(index, true),
                        onFinished: (isDone) => _checkState(isDone, index),
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
