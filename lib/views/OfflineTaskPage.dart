import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_managment_fb/collection/Task_collection.dart';
import 'package:project_managment_fb/controllers/Task_controller.dart';
import 'package:project_managment_fb/database/database.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import 'package:project_managment_fb/models/Task.dart';
import 'package:intl/intl.dart';

class OfflineTaskPage extends StatefulWidget {
  final Project project;
  const OfflineTaskPage({Key? key, required this.project}) : super(key: key);

  @override
  _OfflineTaskPageState createState() => _OfflineTaskPageState();
}

class _OfflineTaskPageState extends State<OfflineTaskPage> {
  final TaskController _taskcontroller = TaskController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPriority = 'High';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _saveTask(BuildContext context) async {
    if (_descriptionController.text.isEmpty || _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return false;
    }

    final priorityMap = {'High': 1, 'Intermediate': 2, 'Low': 3};
    final priority = priorityMap[_selectedPriority]!;

    var uuid = Uuid();
    String id = uuid.v4();

    final task = Task(
      id: id,
      description: _descriptionController.text.trim(),
      startdate: _startDate!.toIso8601String(),
      enddate: _endDate!.toIso8601String(),
      priority: priority,
      projectid: widget.project.id,
      teamId: widget.project.teamId,
      isCompleted: false,
    );

    final success = await _taskcontroller.addTask(task);
    if (success) {
      setState(() {
        _descriptionController.clear();
        _startDate = null;
        _endDate = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully to Local Storage'),
          backgroundColor: Colors.green,
        ),
      );
    }
    return success;
  }
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    items: ['High', 'Intermediate', 'Low']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (p) => setState(() => _selectedPriority = p!),
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _startDate == null
                              ? 'Select Start Date'
                              : DateFormat('yyyy-MM-dd').format(_startDate!),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() =>
                          _startDate = picked);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _endDate == null
                              ? 'Select End Date'
                              : DateFormat('yyyy-MM-dd').format(_endDate!),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _endDate = picked);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await _saveTask(context);
                    if (ok) {
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                  child: Text("Save Task"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks of ${widget.project.title}'),
        backgroundColor: Colors.purple[100],
      ),
      body: FutureBuilder<List<Task>>(
        future: _taskcontroller.getTasksByProjectId(widget.project.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks'));
          }

          final tasks = snapshot.data!
            ..sort((a, b) => a.priority.compareTo(b.priority));

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, i) => buildTaskTile(tasks[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildTaskTile(Task task) {
    Color iconColor;
    IconData iconData = Icons.circle;

    // Determine color based on priority
    switch (task.priority) {
      case 1:
        iconColor = Colors.red; // High
        break;
      case 2:
        iconColor = Colors.orange; // Intermediate
        break;
      case 3:
        iconColor = Colors.green; // Low
        break;
      default:
        iconColor = Colors.grey; // Fallback for unknown
    }
   /* return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(task.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start: ${task.startdate}'),
            Text('End: ${task.enddate}'),
            Text('Priority: ${task.priority}'),
          ],
        ),
        trailing: Icon(
          iconData,
          color: iconColor,
        ),
      ),
    );*/
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text(task.description)),

          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start: ${task.startdate}'),
            Text('End: ${task.enddate}'),
            Text('Priority: ${task.priority}'),
          ],
        ),
        trailing: Icon(
          iconData,
          color: iconColor,
        ),
      ),
    );
  }


}