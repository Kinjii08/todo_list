import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/widgets/day.dart';

class DaysList extends StatefulWidget {
  final List<Task> tasks;
  final String selectedDate;
  final bool isCalendarSelection;
  final void Function(bool) onNotMiddle;
  final void Function(String, bool) onSelectDate;
  const DaysList({
    super.key,
    required this.tasks,
    required this.selectedDate,
    required this.isCalendarSelection,
    required this.onNotMiddle,
    required this.onSelectDate,
  });

  @override
  State<DaysList> createState() => DaysListState();
}

class DaysListState extends State<DaysList> {
  late final List<Map<String, dynamic>> _days = [];
  late ScrollController _controller;
  final itemKey = GlobalKey();

  @override
  void initState() {
    _controller = ScrollController();
    createDaysList();
    initMiddleScroll();
    super.initState();
  }

  void _listener() {
    if ((_controller.position.pixels).floor() == (_getMiddle() - 5).floor()) {
      widget.onNotMiddle(true);
    } else {
      widget.onNotMiddle(false);
    }
  }

  void createDaysList([String? selectedDate]) {
    final String dateToUse =
        selectedDate ?? DateFormat.yMd().format(DateTime.now());
    DateFormat format = DateFormat("M/d/yyyy"); // Mois/Jour/Année
    final DateTime now = format.parse(dateToUse);
    DateTime twoWeeksBack = now.subtract(const Duration(days: 15));

    final List<Map<String, Map<String, Object>>> newDays = [];

    for (int i = 0; i <= 30; i++) {
      DateTime nextDay = twoWeeksBack.add(Duration(days: i));
      String weekDay = DateFormat('ccccc').format(nextDay);
      String date = DateFormat.yMd().format(nextDay);

      bool hasTasks = false;
      bool hasFinishedTasks = false;
      if (widget.tasks.any((t) => t.date == date)) {
        if (widget.tasks.any((t) => !t.isDone)) {
          hasTasks = true;
        }
        if (widget.tasks.any((t) => t.isDone)) {
          hasFinishedTasks = true;
        }
      }

      newDays.add({
        date: {
          "weekDay": weekDay,
          "tasks": hasTasks,
          "finishedTasks": hasFinishedTasks,
        },
      });
    }

    setState(() {
      _days
        ..clear()
        ..addAll(newDays);
    });
    // initMiddleScroll();
  }

  void initMiddleScroll() {
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 1300), () async {
        if (_controller.hasClients) {
          final middle = _getMiddle() - 5;
          await _controller.animateTo(
            middle,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
          _controller.addListener(_listener);
        } else {
          // Retry au prochain frame si pas encore prêt
          Future.delayed(Duration(milliseconds: 50), initMiddleScroll);
        }
      });
    });
  }

  double _getMiddle() {
    return _controller.position.maxScrollExtent / 2;
  }

  void scrollToMiddle() async {
    _controller.removeListener(_listener);
    await _controller.animateTo(
      _getMiddle() - 5,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    widget.onSelectDate(DateFormat.yMd().format(DateTime.now()), false);
    _controller.addListener(_listener);
  }

  Future _scrollToSelectedDate() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = itemKey.currentContext;
      if (context != null) {
        await Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: Duration(seconds: 1),
        );
      }
    });
  }

  void updateDaysWithTasks() {
    for (var day in _days) {
      final dateKey = day.keys.first;
      final dayData = day[dateKey]!;

      if (widget.tasks.any((t) => t.date == dateKey)) {
        final hasUnfinishedTasks = widget.tasks.any(
          (t) => !t.isDone && t.date == dateKey,
        );
        final hasFinishedTasks = widget.tasks.any(
          (t) => t.isDone && t.date == dateKey,
        );
        dayData['tasks'] = hasUnfinishedTasks;
        dayData['finishedTasks'] = hasFinishedTasks;
      } else {
        dayData['tasks'] = false;
        dayData['finishedTasks'] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    updateDaysWithTasks();
    return SizedBox(
      height: 100,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          String newKey = "";
          bool isCurrentDay = false;
          _days[index].forEach((key, value) {
            newKey = key;
            isCurrentDay = newKey == widget.selectedDate;
          });
          return GestureDetector(
            onTap:
                () => {
                  widget.onSelectDate(newKey, false),
                  _scrollToSelectedDate(),
                },

            child: Day(
              key: isCurrentDay ? itemKey : null,
              day: _days[index],
              isSelected: isCurrentDay,
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 36),
        itemCount: _days.length,
      ),
    );
  }
}
