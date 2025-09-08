import 'package:flutter/material.dart';

class TaskItem extends StatefulWidget {
  final String title;
  final VoidCallback? onDelete;
  final void Function(String)? onEdit;
  final void Function(bool)? onFinished;
  final bool isDone;
  const TaskItem({
    super.key,
    required this.title,
    this.onDelete,
    this.onEdit,
    this.onFinished,
    required this.isDone,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late TextEditingController _controller;
  late String taskText;
  String dismissDirection = "startToEnd";

  @override
  void initState() {
    super.initState();
    taskText = widget.title;
    _controller = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String?> _openEditDialog() => showDialog<String>(
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
    widget.onEdit!(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => {if (widget.isDone == false) _openEditDialog()},
      child: Card(
        color:
            widget.isDone
                ? Theme.of(context).colorScheme.tertiaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Dismissible(
            background: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.red),
              child: Align(
                alignment:
                    dismissDirection == "startToEnd"
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                child: Icon(Icons.delete),
              ),
            ),
            key: ValueKey(widget.title),
            onUpdate: (details) {
              setState(() {
                dismissDirection = details.direction.name;
              });
            },
            onDismissed: (direction) {
              widget.onDelete!();
            },
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(14, 0, 6, 0),
              title: Text(
                taskText,
                style: TextStyle(
                  decoration:
                      widget.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Checkbox(
                activeColor: Theme.of(context).colorScheme.onTertiaryContainer,
                key: ValueKey(widget.title),
                value: widget.isDone,
                onChanged: (_) => widget.onFinished!(!widget.isDone),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
