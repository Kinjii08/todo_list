import 'package:hive/hive.dart';

part 'task.g.dart'; // lien vers le code généré

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  String date;

  Task(this.id, {required this.title, this.isDone = false, required this.date});
}
