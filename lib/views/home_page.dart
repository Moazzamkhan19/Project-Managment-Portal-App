import 'dart:async';
import 'package:project_managment_fb/collection/Task_collection.dart';
import 'package:project_managment_fb/collection/project_collection.dart';
import 'package:project_managment_fb/collection/team_collection.dart';
import 'package:project_managment_fb/models/project_model.dart';
import 'package:project_managment_fb/views/project_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_managment_fb/models/team_model.dart';
import 'package:project_managment_fb/controllers/user_controller.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../InternetServices/InternetServices.dart';
import '../database/database.dart';
import '../models/Task.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isOnline = false;
  late Project project;
  late Task task;
  List<Team> _teamList = [];

  Future<void>_logout(BuildContext context) async
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacementNamed(context,'/login');
  }
  get flutterLocalNotificationsPlugin => null;
  @override
 /* void initState()
  {
    super.initState();
    fetchTeam();
  }
  Future<void> fetchTeam() async
  {
    final teams = await DatabaseHelper().getAllTeams();
    setState(()=>_teamList=teams);
  }


  Future<void> fetchTeam() async {
    final snapshot = await FirebaseFirestore.instance.collection('teams').get();
    final teams = snapshot.docs.map((doc) {
      final data = doc.data();
      return Team(
        id: doc.id.hashCode,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        designation: data['designation'] ?? '',
        image: data['image'] ?? '',
      );
    }).toList();

    setState(() => _teamList = teams);
  }
  Future<void> deleteTeamFromFirestore(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('teams')
        .where('email', isEqualTo: email)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    await fetchTeam();
  }
  */
 /* Future<void> deleteTeam(String docId) async {
    await FirebaseFirestore.instance.collection('teams').doc(docId).delete();

    await ProjectServices().deleteProjectsTeamId(docId);
    await TaskService().deleteTaskTeamId(docId);
  }
  */
  /* Widget buildTeamList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadTeams,
      child: _teams.isEmpty
          ? const Center(child: Text('No team members added.'))
          : ListView.builder(
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];

          return Dismissible(
            key: Key(team.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Member'),
                  content: const Text("Are you sure you want to delete?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              await deleteTeam(team.id);
              _teams.removeAt(index);
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purpleAccent[80],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: team.image.isNotEmpty
                      ? MemoryImage(base64Decode(team.image))
                      : null,
                  child: team.image.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text('${team.name}\n${team.designation}'),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email: ${team.email}"),
                            Text("Phone: ${team.phone}"),
                            Text("Designation: ${team.designation}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectPage(team: team),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
  */   //buildlistview
  @override
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
     fetchTeam(); // Loads Firestore teams
  }
  void fetchTeam() async {
    TeamServices service = TeamServices();
    List<Team> teams = await service.getAllTeams();
    setState(() {
      _teamList = teams;
    });
  }
  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOnline = connectivityResult != ConnectivityResult.none;
    });
  }
  Widget buildOnlineListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teams')
          .orderBy('addedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No team members added.'));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final team = Team.fromMap(doc.data() as Map<String, dynamic>);

            return Dismissible(
              key: Key(team.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Member'),
                    content: const Text("Are you sure you want to delete?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) async {
                await FirebaseFirestore.instance
                    .collection('teams')
                    .doc(team.id)
                    .delete();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[250],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: team.image.isNotEmpty
                        ? MemoryImage(base64Decode(team.image))
                        : null,
                    child: team.image.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text('${team.name}\n${team.designation}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email: ${team.email}"),
                              Text("Phone: ${team.phone}"),
                              Text("Designation: ${team.designation}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectPage(team: team),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
  /* Future<void> _loadTeams() async {
    final hasConnection = await InternetServices.checkInternetAccess();

    if (hasConnection) {
      final snapshot = await FirebaseFirestore.instance
          .collection('teams')
          .orderBy('addedAt', descending: true)
          .get();

      _teams = snapshot.docs.map((doc) {
        final data = doc.data();
        return Team(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          designation: data['designation'] ?? '',
          image: data['image'] ?? '',
        );
      }).toList();
    } else
    {
      _teams = await DatabaseHelper().getAllTeams();
    }

    setState(() {
      _isLoading = false;
    });
  }

  */
  Future<void> deleteTeam(String docId) async {
    final prefs = await SharedPreferences.getInstance();

    await FirebaseFirestore.instance.collection('teams').doc(docId).delete();
    final projectSnapshot = await ProjectServices().project_collection.where('teamId', isEqualTo: docId).get();
    for (final projectDoc in projectSnapshot.docs) {
      final projectId = projectDoc.id;

      await ProjectServices().project_collection.doc(projectId).delete();

      final taskSnapshot = await TaskService().task_collection.where('projectid', isEqualTo: projectId).get();
      for (final taskDoc in taskSnapshot.docs) {
        final taskId = taskDoc.id;
        int? notifId = prefs.getInt(taskId);
        if (notifId != null) {
          await flutterLocalNotificationsPlugin.cancel(notifId);
          await prefs.remove(taskId);
        }
        await TaskService().task_collection.doc(taskId).delete();
      }
    }
    final teamTasksSnapshot = await TaskService().task_collection.where('teamId', isEqualTo: docId).get();
    for (final taskDoc in teamTasksSnapshot.docs) {
      final taskId = taskDoc.id;

      int? notifId = prefs.getInt(taskId);
      if (notifId != null) {
        await flutterLocalNotificationsPlugin.cancel(notifId);
        await prefs.remove(taskId);
      }

      await TaskService().task_collection.doc(taskId).delete();
    }

    print("Team, associated projects, tasks, and notifications deleted.");
  }
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: ()
       async {
        Navigator.pushNamed(context, '/addTeam');
      },
      backgroundColor: Colors.purple[100],
      child: Icon(Icons.add),),

      appBar: AppBar(
        title: const Text('DASH BOARD'),
        centerTitle: true,
        backgroundColor: Colors.purple[100],
        leading: IconButton(
          icon: Icon(Icons.sync),
          tooltip: 'Sync Offline Data',
          onPressed: () async {
            try {
              bool teamsync = await TeamServices().SYNCTeam();
              bool projectsync = await ProjectServices().SYNCProject();
              bool tasksync = await TaskService().SYNCTask();


              if (teamsync && projectsync && tasksync) {
                await TeamServices().FetchTeams();
                await ProjectServices().FetchProject();
                await TaskService().FetchTasks();

                //adding a delay to refresh the UI
                Future.delayed(Duration(milliseconds: 500), () {
                  setState(() {});
                });


                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(
                      "✅ Data synced and local database cleared.")),
                );
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Sync failed. Try again.")),
                );
              }
            }
            catch (e) {
              print("❌ Sync error: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ An error occurred during sync.")),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _logout(context);
            },
            child: const Text(
              'LOG OUT',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child:buildOnlineListView(),
            ),
            ElevatedButton(
              onPressed: () {
                checkLocalTeams();
                Navigator.pushNamed(context, '/offlinepage');
              },
              child: Text('Check Offline Teams'),
            ),

          ],
        ),
      ),


    );
  }
  void checkLocalTeams() async {
    final teams = await DatabaseHelper().getAllTeams();
    print("Teams in SQLite:");
    for (final team in teams) {
      print("ID: ${team.id}, Name: ${team.name}");
    }
  }
}

