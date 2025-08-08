import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:project_managment_fb/collection/project_collection.dart';
import 'package:project_managment_fb/models/Task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_managment_fb/notification/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/project_model.dart';
import '../notification/notification.dart';
class TaskService {
  final task_collection = FirebaseFirestore.instance.collection('tasks');

 /* Future<void> addTask(Task task) async {
    final docRef = task_collection.doc();
    final newTask = Task(
      id: docRef.id,
      description: task.description,
      startdate: task.startdate,
      enddate: task.enddate,
      priority: task.priority,
      projectid: task.projectid,
    );
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final taskEnd = DateFormat('yyyy-MM-dd').format(
        DateTime.parse(task.enddate));

    int notifId = docRef.id.hashCode ^ DateTime
        .now()
        .millisecondsSinceEpoch;

    if (today == taskEnd) {
      NotificationService.showDueDateNotification(
        "Task Due Today",
        "${task.description} is due today!",
        notifId,
      );
    }
    Duration delay;
    switch (task.priority) {
      case 1:
        delay = const Duration(seconds: 1);
        break;
      case 2:
        delay = const Duration(seconds: 5);
        break;
      case 3:
        delay = const Duration(seconds: 10);
        break;
      default:
        delay = const Duration(seconds: 12);
    }

    NotificationService.schedulePriorityNotification(
      title: "Reminder: ${task.description}",
      body: "Your task is marked as priority ${getPriorityLabel(
          task.priority)}",
      id: notifId + 1000,
      delay: delay,
    );
    await docRef.set(newTask.toFirebase());
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
  */

  Future<void> deleteTask(String taskid) async
  {
    await task_collection.doc(taskid).delete();
  }

  Future<void> updateTask(Task task) async {
    await task_collection.doc(task.id).update(task.toFirebase());
  }

  Future<List<Task>> getAllTask() async
  {
    final snapshot = await task_collection.get();
    return snapshot.docs
        .map((doc) =>
        Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<Task?> getTaskById(String id) async
  {
    final doc = await task_collection.doc(id).get();
    if (doc.exists) {
      return Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }


  Stream<QuerySnapshot> getTaskByProjectId(String projectId) {
    return task_collection
        .where('projectid', isEqualTo: projectId)
        .snapshots(); // returns Stream<QuerySnapshot>
  }
  /*Future<void> deleteTaskTeamId(String teamId) async {
    final snapshot = await task_collection.where('teamId', isEqualTo: teamId).get();
    for (final doc in snapshot.docs) {
      await task_collection.doc(doc.id).delete();
    }
  }
   */
  Future<void> deleteTaskTeamId(String teamId) async {
    final snapshot = await task_collection.where('teamId', isEqualTo: teamId).get();
    final prefs = await SharedPreferences.getInstance();

    for (final doc in snapshot.docs) {
      final taskId = doc.id;
      int? notifId = prefs.getInt(taskId);
      if (notifId != null) {
        for (int i = 0; i < 10; i++) {
          await NotificationService.cancelNotification(notifId + i);
        }
        await prefs.remove(taskId);
      }
      await task_collection.doc(taskId).delete();
    }
  }

  Future<void> addTaskHighprior(Task task) async {
    final docRef = await FirebaseFirestore.instance
        .collection('tasks')
        .add(task.toMap(withId: false));
    final generatedId = docRef.id;
    await docRef.update({'id': generatedId});

    final now = DateTime.now();
    final end = DateTime.parse(task.enddate);
    Duration repeatInterval = Duration(minutes: 15);

    int notificationIdBase = DateTime
        .now()
        .millisecondsSinceEpoch ~/ 1000;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(generatedId, notificationIdBase);

    int i = 0;
    for (DateTime time = now.add(Duration(seconds: 5));
    time.isBefore(end);
    time = time.add(repeatInterval)) {
      await NotificationService.schedulePriorityNotification(
        title: '🔥 High Priority Task',
        body: 'This task is urgent: ${task.description}!',
        id: notificationIdBase + i,
        delay: time.difference(now),
      );
      i++;
      if (i >= 10) break;
    }
  }

  Future<void> addTaskIntermediateprior(Task task) async {
    final docRef = await FirebaseFirestore.instance
        .collection('tasks')
        .add(task.toMap(withId: false));

    final generatedId = docRef.id;
    await docRef.update({'id': generatedId});

    final now = DateTime.now();
    final end = DateTime.parse(task.enddate);
    Duration repeatInterval = Duration(minutes: 30);

    int notificationIdBase = DateTime
        .now()
        .millisecondsSinceEpoch ~/ 1000;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(generatedId, notificationIdBase);

    int i = 0;
    for (DateTime time = now.add(Duration(seconds: 5)); time.isBefore(end);
    time = time.add(repeatInterval)) {
      await NotificationService.schedulePriorityNotification(
        title: '🔔Intermediate Priority Task ${task.description}',
        body: 'This task is important DO IT: ${task.description}!',
        id: notificationIdBase + i, // unique ID for each
        delay: time.difference(now),
      );
      i++;
      if (i >= 10) break;
    }
  }

  Future<void> addTaskLowprior(Task task) async {
    final docRef = await FirebaseFirestore.instance
        .collection('tasks')
        .add(task.toMap(withId: false));

    final generatedId = docRef.id;
    await docRef.update({'id': generatedId});

    final now = DateTime.now();
    final end = DateTime.parse(task.enddate);
    Duration repeatInterval = Duration(hours: 1);

    int notificationIdBase = DateTime
        .now()
        .millisecondsSinceEpoch ~/ 1000;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(generatedId, notificationIdBase);

    int i = 0;
    for (DateTime time = now.add(Duration(seconds: 5)); time.isBefore(end);
    time = time.add(repeatInterval)) {
      await NotificationService.schedulePriorityNotification(
        title: '🔽Low Priority Task ${task.description}',
        body: 'This task is Low priority But dont forget : ${task
            .description}!',
        id: notificationIdBase + i, // unique ID for each
        delay: time.difference(now),
      );
      i++;
      if (i >= 10) break;
    }
  }

  Future<bool> addTaskOnPriority(Task task) async {
    if (!await isTaskValid(task)) {
      return false;
    }

    try {
      switch (task.priority) {
        case 1:
          await addTaskHighprior(task);
          break;
        case 2:
          await addTaskIntermediateprior(task);
          break;
        case 3:
          await addTaskLowprior(task);
          break;
        default:
          print("Invalid priority level: ${task.priority}");
          return false;
      }
      return true;
    } catch (e) {
      print("Error in addTaskOnPriority: $e");
      return false;
    }
  }

  Future<bool> isTaskValid(Task task) async {
    try {
      // Get all projects and find the one with matching ID
      List<Project> allProjects = await ProjectServices().getAllProjects();

      final Project? project = allProjects.firstWhere(
            (p) => p.id == task.projectid,
        orElse: () => null as Project,
      );
      if (project == null) {
        debugPrint('Project not found for ID: ${task.projectid}');

        // Delete task from Firestore
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(task.id)
            .delete();

        debugPrint('Deleted task with ID: ${task.id} due to missing project');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating task: $e');
      return false;
    }
  }
  Future<void> deleteNotificationsForDeletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final taskId in keys) {
      final doc = await task_collection.doc(taskId).get();

      if (!doc.exists) {
        final notifId = prefs.getInt(taskId);
        if (notifId != null) {
          await NotificationService.cancelNotification(notifId);
          print('Cancelled notification $notifId for deleted task $taskId');
        }
        await prefs.remove(taskId); // Clean up
      }
    }
  }

  Future<bool> SYNCTask() async {
    try {
      final dbPath = await getDatabasesPath();
      final db = await openDatabase(join(dbPath, 'app.db'));

      final List<Map<String, dynamic>> localTasks = await db.query('task');

      for (var taskMap in localTasks) {
        final task = Task.fromMap1(taskMap);
        final taskData = task.toMap(withId: false);
        final taskId = task.id;
        taskData['addedAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .set(taskData);
        await db.delete(
          'task',
          where: 'id = ?',
          whereArgs: [task.id],
        );
      }
      print(" Sync completed: All tasks uploaded to Firebase.");
      return true;
    } catch (e) {
      print(" Sync failed: $e");
      return false;
    }
  }

  Future<List<Task>> FetchTasks() async {
    try {
      final snapshot = await task_collection.get();

      final tasks = snapshot.docs.map((doc) {
        return Task.fromDocument(doc);
      }).toList();

      print("✅ Fetched ${tasks.length} tasks from Firebase.");
      return tasks;
    } catch (e) {
      print("❌ Failed to fetch tasks: $e");
      return [];
    }
  }

}
