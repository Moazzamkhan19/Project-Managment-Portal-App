import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:project_managment_fb/collection/Task_collection.dart';
import 'package:project_managment_fb/views/TaskViewFB.dart';
import '../models/project_model.dart';
import 'package:project_managment_fb/models/Task.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {
  final Project project;
  const TasksPage({Key? key, required this.project}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskService _taskcollection = TaskService();
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

    final task = Task(
      id: '',
      description: _descriptionController.text.trim(),
      startdate: _startDate!.toIso8601String(),
      enddate: _endDate!.toIso8601String(),
      priority: priority,
      projectid: widget.project.id,
      teamId: widget.project.teamId,
    );

    final success = await _taskcollection.addTaskOnPriority(task);
    if (success) {
      setState(() {
        _descriptionController.clear();
        _startDate = null;
        _endDate = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully to Firebase'),
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
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                onPressed: () async {
            final ok = await _saveTask(context);
            if (ok) {
           Get.back();
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _taskcollection.getTaskByProjectId(widget.project.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks'));
          }

          final tasks = snapshot.data!.docs
              .map((doc) =>
              Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
              .toList()
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
    return Card(
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskviewFB(
                taskId: task.id,       // make sure you have this
                projectId: widget.project.id, // make sure you have this
              ),
            ),
          );

        },
      ),
    );
  }


}
