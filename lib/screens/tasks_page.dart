import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String? content;
  Box? _box;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Daily Planner",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _tasksWidget(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: displayTaskPop,
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),
    );
  }

  Widget _todoList() {
    List tasks = _box!.values.toList();

    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No tasks yet.\nTap + to add one.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              task.done ? Icons.check_circle : Icons.circle_outlined,
              color: task.done ? Colors.green : Colors.grey,
            ),
            title: Text(
              task.todo,
              style: TextStyle(
                decoration:
                    task.done ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              "${task.timeStamp}",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.delete_outline),
            onTap: () {
              task.done = !task.done;
              _box!.putAt(index, task.toMap());
              setState(() {});
            },
            onLongPress: () {
              _box!.deleteAt(index);
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget _tasksWidget() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _todoList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void displayTaskPop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Add New Task"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Enter task...",
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                var task = Task(
                  todo: value,
                  timeStamp: DateTime.now(),
                  done: false,
                );

                _box!.add(task.toMap());

                Navigator.pop(context);
                setState(() {});
              }
            },
          ),
        );
      },
    );
  }
}
