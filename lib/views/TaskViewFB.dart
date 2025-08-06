import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_managment_fb/models/Task.dart';
import 'package:project_managment_fb/models/project_model.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_managment_fb/models/Task.dart';
import 'package:project_managment_fb/models/project_model.dart';

class TaskviewFB extends StatelessWidget {
  final String taskId;
  final String projectId;

  const TaskviewFB({
    super.key,
    required this.taskId,
    required this.projectId,
  });

  Future<Task> fetchTask() async {
    final doc = await FirebaseFirestore.instance.collection('tasks').doc(taskId).get();
    return Task.fromFirestore(doc.data()!, doc.id);
  }

  Future<Project> fetchProject() async {
    final doc = await FirebaseFirestore.instance.collection('projects').doc(projectId).get();
    return Project.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([fetchTask(), fetchProject()]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        }

        final task = snapshot.data![0] as Task;
        final project = snapshot.data![1] as Project;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Task Details"),
            backgroundColor: Colors.purple[100],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        task.description ?? 'Task Name',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),

                    buildRow("Task ID", task.id),
                    buildRow("Project ID", projectId),
                    buildRow("Project Title", project.title),
                    buildRow("Project Status", project.status ?? 'N/A'), // Optional
                    buildRow("Start Date", task.startdate.toString().split(' ')[0]),
                    buildRow("End Date", task.enddate.toString().split(' ')[0]),

                    const SizedBox(height: 20),
                    const Text("Description:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(
                "$label:",
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(color: Colors.grey),
              )),
        ],
      ),
    );
  }
}




