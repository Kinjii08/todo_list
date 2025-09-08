import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Week extends StatefulWidget {
  final void Function(bool) onNotMiddle;
  const Week({super.key, required this.onNotMiddle});

  @override
  State<Week> createState() => WeekState();
}

class WeekState extends State<Week> {
  late final List<Map<String, int>> _days = [];
  late ScrollController _controller;
  final itemKey = GlobalKey();

  @override
  void initState() {
    _createDaysList();
    _initMiddleScroll();
    super.initState();
  }

  void _listener() {
    widget.onNotMiddle(false);
  }

  //TODO voir la video sur l'ancre sur un item

  void _createDaysList() {
    final DateTime now = DateTime.now();
    DateTime twoWeeksBack = now.subtract(Duration(days: 15));
    for (int i = 0; i <= 30; i++) {
      DateTime nextDay = twoWeeksBack.add(Duration(days: i));
      String weekDay = DateFormat('ccccc').format(nextDay);
      int dayNumber = nextDay.day;
      _days.add({weekDay: dayNumber});
    }
  }

  void _initMiddleScroll() {
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 1500), () async {
        if (_controller.hasClients) {
          final middle = _getMiddle() + 5;
          await _controller.animateTo(
            middle,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
          _controller.addListener(_listener);
        } else {
          // Retry au prochain frame si pas encore prêt
          Future.delayed(Duration(milliseconds: 50), _initMiddleScroll);
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
      _getMiddle(),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    _controller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          String newKey = "";
          int newValue = 0;
          bool isCurrentDay = false;
          _days[index].forEach((key, value) {
            newKey = key;
            newValue = value;
            isCurrentDay = newValue == DateTime.now().day;
          });
          return Column(
            key: isCurrentDay ? itemKey : null,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                newKey,
                style: TextStyle(
                  fontSize: 18,
                  color: isCurrentDay ? Colors.white : Colors.white70,
                  fontWeight:
                      isCurrentDay ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                newValue.toString(),
                style: TextStyle(
                  fontSize: 18,
                  color: isCurrentDay ? Colors.white : Colors.white70,
                  fontWeight:
                      isCurrentDay ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 36),
        itemCount: _days.length,
      ),
    );
  }
}
