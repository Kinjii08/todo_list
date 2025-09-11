import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/widgets/day.dart';

class DaysList extends StatefulWidget {
  final Map<String, dynamic> tasks;
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
  late final List<Map<String, Map<String, Object>>> _days = [];
  late ScrollController _controller;
  final itemKey = GlobalKey();

  @override
  void didUpdateWidget(covariant DaysList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // print('tasks : ${widget.tasks}');
    // if (oldWidget.tasks != widget.tasks) {
    //   createDaysList(); // ça va utiliser la nouvelle valeur
    // }
    // if (oldWidget.selectedDate != widget.selectedDate &&
    //     widget.isCalendarSelection) {
    //   createDaysList();
    //   initMiddleScroll();
    // }
    // if (oldWidget.selectedDate != widget.selectedDate &&
    //     widget.selectedDate == DateFormat.yMd().format(DateTime.now())) {
    //   createDaysList();
    //   initMiddleScroll();
    // }
    //TODO: le probleme c'est que ça me casse mon scroll encore
  }

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  void _listener() {
    widget.onNotMiddle(false);
  }

  void createDaysList() {
    print("tasks : ${widget.tasks}");
    print("selected date : ${widget.selectedDate}");
    // DateFormat format = DateFormat("M/d/yyyy"); // Mois/Jour/Année
    // final DateTime now = format.parse(widget.selectedDate);
    // DateTime twoWeeksBack = now.subtract(const Duration(days: 15));

    // final List<Map<String, Map<String, Object>>> newDays = [];

    // for (int i = 0; i <= 30; i++) {
    //   DateTime nextDay = twoWeeksBack.add(Duration(days: i));
    //   String weekDay = DateFormat('ccccc').format(nextDay);
    //   String date = DateFormat.yMd().format(nextDay);

    //   bool hasTasks = false;
    //   bool hasFinishedTasks = false;

    //   if (widget.tasks.containsKey(date)) {
    //     if (widget.tasks[date]!["tasks"]!.isNotEmpty) {
    //       hasTasks = true;
    //     }
    //     if (widget.tasks[date]!["finishedTasks"]!.isNotEmpty) {
    //       hasFinishedTasks = true;
    //     }
    //   }

    //   newDays.add({
    //     date: {
    //       "weekDay": weekDay,
    //       "tasks": hasTasks,
    //       "finishedTasks": hasFinishedTasks,
    //     },
    //   });
    // }

    // setState(() {
    //   _days
    //     ..clear()
    //     ..addAll(newDays);
    // });
  }

  void initMiddleScroll() {
    // _controller = ScrollController();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(Duration(milliseconds: 1500), () async {
    //     if (_controller.hasClients) {
    //       final middle = _getMiddle();
    //       await _controller.animateTo(
    //         middle,
    //         duration: const Duration(milliseconds: 600),
    //         curve: Curves.easeInOut,
    //       );
    //       _controller.addListener(_listener);
    //     } else {
    //       // Retry au prochain frame si pas encore prêt
    //       Future.delayed(Duration(milliseconds: 50), initMiddleScroll);
    //     }
    //   });
    // });
  }

  double _getMiddle() {
    return _controller.position.maxScrollExtent / 2;
  }

  void scrollToMiddle() async {
    //   _controller.removeListener(_listener);
    //   await _controller.animateTo(
    //     _getMiddle(),
    //     duration: const Duration(milliseconds: 600),
    //     curve: Curves.easeInOut,
    //   );
    //   setState(() {
    //     widget.onSelectDate(DateFormat.yMd().format(DateTime.now()), false);
    //   });
    //   _controller.addListener(_listener);
    // }

    // Future _scrollToSelectedDate() async {
    //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //     final context = itemKey.currentContext;
    //     if (context != null) {
    //       await Scrollable.ensureVisible(
    //         context,
    //         alignment: 0.5,
    //         duration: Duration(seconds: 1),
    //       );
    //     }
    //   });
  }

  @override
  Widget build(BuildContext context) {
    createDaysList();
    // initMiddleScroll();
    // print("🔄 Week.build() avec tasks = ${widget.tasks}");
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
                  // _scrollToSelectedDate(),
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
