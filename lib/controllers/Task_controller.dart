import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../models/Task.dart';
import '../notification/notification.dart';

class TaskController extends ChangeNotifier {
  final _dbHelper = DatabaseHelper();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Future<void> fetchTasks() async {
    _tasks = await _dbHelper.getAllTasks();
    notifyListeners();
  }
  Future<void> deleteTask(String id) async {
    await _dbHelper.deleteTask(id);
    await fetchTasks();
  }
  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
    await fetchTasks();
  }
  String getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Low';
      default:
        return 'Unknown';
    }
  }
  Future<bool> addTask(Task task) async {
    // Validate
    if (!await isTaskValid(task)) return false;

    try {
      // Insert into local DB
      await _dbHelper.insertTask(task);
      await fetchTasks();  // refresh list
    } catch (e) {
      print("EXCEPTION OCCURED $e");
      return false;
    }

    // Schedule notifications
    int notifId = task.id.hashCode;
    final now = DateTime.now();
    final end = DateTime.parse(task.enddate);
    final today = DateFormat('yyyy-MM-dd').format(now);
    final taskEnd = DateFormat('yyyy-MM-dd').format(end);

    if (today == taskEnd) {
      NotificationService.showDueDateNotification(
        "Task Due Today",
        "${task.description} is due today!",
        notifId,
      );
    }

    Duration interval;
    String title;
    switch (task.priority) {
      case 1:
        interval = const Duration(minutes: 15);
        title = '🔥 High Priority Task';
        break;
      case 2:
        interval = const Duration(minutes: 30);
        title = '🔔 Intermediate Priority Task';
        break;
      case 3:
        interval = const Duration(hours: 1);
        title = '🔽 Low Priority Task';
        break;
      default:
        interval = const Duration(hours: 2);
        title = '🟡 Task';
    }

    int baseId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int i = 0;
    for (DateTime time = now.add(const Duration(seconds: 5));
    time.isBefore(end);
    time = time.add(interval)) {
      await NotificationService.schedulePriorityNotification(
        title: title,
        body: '${task.description} - ${getPriorityLabel(task.priority)} priority',
        id: baseId + i,
        delay: time.difference(now),
      );
      if (++i >= 10) break;
    }

    return true;
  }

  Future<bool> isTaskValid(Task task) async {
    final project = await _dbHelper.getProjectById(task.projectid);
    if (project == null) return false;

    final team = await _dbHelper.getTeamById(project.teamId);
    return team != null;
  }
  Future<List<Task>> getTasksByProjectId(String projectId) async {
    return await DatabaseHelper().getTasksByProjectId(projectId);
  }

}


