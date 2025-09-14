import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/screens/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());

  await Hive.openBox<Task>('tasks');

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
