import 'package:flutter/material.dart';
import 'package:todo_list/screens/todo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    final myScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 0, 160, 253),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: myScheme.surface,
        colorScheme: myScheme,
        useMaterial3: true,
      ),
      home: const TodoScreen(),
    );
  }
}
