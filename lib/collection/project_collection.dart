import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:project_managment_fb/collection/Task_collection.dart';
import 'package:project_managment_fb/models/project_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../notification/notification.dart';

class ProjectServices
{
  final project_collection = FirebaseFirestore.instance.collection('projects');// creating a collection named projects
  //adding projects
  Future<void> addProject(Project project) async
  {
    final doc = project_collection.doc();
    await doc.set(
      {
        'id':doc.id,
        'title':project.title,
        'deadline':project.deadline,
        'startdate':project.startdate,
        'status':project.status,
        'teamId':project.teamId,
      }
    );
  }
  Stream<List<Project>> getProjectsByTeamId(String teamId) {


    return project_collection
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Project.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

 /* Future<void> deleteProject(String projectId) async {
    try {
      await project_collection.doc(projectId).delete();
      final taskSnapshot = await TaskService()
          .task_collection
          .where('projectid', isEqualTo: projectId)
          .get();
      for (final doc in taskSnapshot.docs) {
        await TaskService().task_collection.doc(doc.id).delete();
      }

      print("Project and associated tasks deleted successfully.");
    } catch (e) {
      print("Error deleting project or tasks: $e");
    }
  }
  */
  Future<void> deleteProject(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taskSnapshot = await TaskService()
          .task_collection
          .where('projectid', isEqualTo: projectId)
          .get();

      for (final doc in taskSnapshot.docs) {
        final taskId = doc.id;
        int? notifId = prefs.getInt(taskId);
        if (notifId != null) {
          for (int i = 0; i < 10; i++) {
            await NotificationService.cancelNotification(notifId + i);
          }
          await prefs.remove(taskId);
        }
        await TaskService().task_collection.doc(taskId).delete();
      }
      await project_collection.doc(projectId).delete();

      print("Project and associated tasks deleted successfully.");
    } catch (e) {
      print("Error deleting project or tasks: $e");
    }
  }

  Future<void> deleteProjectsTeamId(String teamId) async {
    final snapshot = await project_collection.where('teamId', isEqualTo: teamId).get();
    for (final doc in snapshot.docs) {
      await project_collection.doc(doc.id).delete();
    }
  }
  Future<List<Project>> getAllProjects() async
  {
    final snapshot = await project_collection.get();
    return snapshot.docs.map((doc)
    {
      return Project.fromJson(doc.data() as Map<String,dynamic>, doc.id);
    }).toList();
  }
  Future<void> reassignProjectToTeam(String projectId, String newTeamId) async {
    await project_collection.doc(projectId).update({'teamId':newTeamId,});
  }
  Future<bool> SYNCProject() async {
    try {
      final dbPath = await getDatabasesPath();
      final db = await openDatabase(join(dbPath, 'app.db'));

      final List<Map<String, dynamic>> localProjects = await db.query('project');

      for (var projectMap in localProjects) {
        final project = Project.fromMap(projectMap);
        final projectData = project.toMap(withId: false);

        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .set({
          ...projectData,
          'addedAt': FieldValue.serverTimestamp(),
        });
        await db.delete(
          'project',
          where: 'id = ?',
          whereArgs: [project.id],
        );
      }

      print("✅ Sync completed: All projects uploaded to Firebase.");
      return true;
    } catch (e) {
      print("❌ Sync failed: $e");
      return false;
    }
  }



  Future<List<Project>> FetchProject() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('projects').get();

      final projects = snapshot.docs.map((doc) {
        return Project.fromFirestore(doc.data(), doc.id);
      }).toList();

      print("✅ Fetched ${projects.length} projects from Firebase.");
      return projects;
    } catch (e) {
      print("❌ Failed to fetch projects: $e");
      return [];
    }
  }




}