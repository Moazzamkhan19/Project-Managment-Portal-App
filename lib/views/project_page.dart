import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:project_managment_fb/collection/team_collection.dart';
import 'package:project_managment_fb/views/OfflineTaskPage.dart';
import 'package:project_managment_fb/views/Tasks_page.dart';
import 'package:project_managment_fb/views/offline_page.dart';
import '../InternetServices/InternetServices.dart';
import '../models/project_model.dart';
import '../models/team_model.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'package:project_managment_fb/controllers/Task_controller.dart';
import 'package:project_managment_fb/collection/project_collection.dart';

class ProjectPage extends StatefulWidget {
  final Team team;

  const ProjectPage({super.key, required this.team});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  bool _isOnline = true;
  final List<Project> _projects = [];

  final TextEditingController _titleController = TextEditingController();
  String ? status;

  final List<String> statusOptions = [
    'Completed',
    'In Progress',
    'Delayed',
    'Incomplete',
  ];
  DateTime? _startDate;
  DateTime? deadline;

  @override
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _isOnline = await InternetServices.checkInternetAccess();
    if (!_isOnline) {
      await _fetchProjects(); // SQLite if offline
    }
    setState(() {}); // Trigger build()
  }
  Future<void> _fetchProjects() async {
    final projects = await DatabaseHelper().getProjectsByTeamId(
        widget.team.id);
    setState(() {
      _projects.clear();
      _projects.addAll(projects);
    });
  }
  Future<bool> _addProjectDB() async {
    if (_titleController.text.isEmpty || _startDate == null || deadline == null)
      {return false;}
    try{
      final project = Project(
        id: Uuid().v4(),
        // auto-generate a unique ID
        teamId: widget.team.id,
        title: _titleController.text,
        startdate: _startDate!.toIso8601String(),
        deadline: deadline!.toIso8601String(),
        status: status ?? '',
      );
      await DatabaseHelper().insertProject(project);
      print("✅ Project saved to SQLite: ${project.title} for team ${project.teamId}");
      await DatabaseHelper().debugPrintAllProjects(widget.team.id);
      _titleController.clear();
      _startDate = null;
      deadline = null;
      status = null;

      /*Navigator.pop(context);*/
      Get.back();
      _fetchProjects();
      return true;
    }
   catch(e)
    {
      print("Failed to add project: $e");
      return false;
    }

  }
  Future<bool> _addProject() async {
    if (_titleController.text.isEmpty || _startDate == null || deadline == null) {
      return false;
    }
    try {
      final project = Project(
        id: '',
        teamId: widget.team.id,
        title: _titleController.text,
        startdate: _startDate!.toIso8601String(),
        deadline: deadline!.toIso8601String(),
        status: status,
      );

      await ProjectServices().addProject(project);

      _titleController.clear();
      status = null;
      deadline = null;
      _startDate = null;

      setState(() {});
     /* Navigator.pop(context);*/
      Get.back();
      return true;
    } catch (e) {
      print("Failed to add project: $e");
      return false;
    }
  }
  Widget _buildFirebaseProjects() {
    return StreamBuilder(
      stream: ProjectServices().getProjectsByTeamId(widget.team.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasError) {
          return Center(child: Text('Error'));
        }
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No projects available'));
        }
        final projects = snapshot.data!;
        return ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Dismissible(
              key: Key(project.id),
              direction: DismissDirection.horizontal,
              background: Container(
                color: Colors.green,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.swap_horiz, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: const Text('Delete Project'),
                          content: const Text(
                              "Are you sure you want to delete?"),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result:true),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                  );
                } else if (direction == DismissDirection.startToEnd) {
                  final newTeam = await _showTeamSelectDialog();
                  if (newTeam != null) {
                    if (project.id != null && newTeam.id != null) {
                      await ProjectServices().reassignProjectToTeam(
                          project.id, newTeam.id);
                    }
                  }
                  return false;
                }
                return false;
              },
              onDismissed: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  await ProjectServices().deleteProject(project.id!);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.purpleAccent[80],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.2),
                          offset: const Offset(0, 4))
                    ]),
                child: ListTile(
                    title: Text(project.title),
                    subtitle: Text(
                      'From: ${project.startdate.split('T')[0]} To: ${project
                          .deadline.split('T')[0]}  Status ${project.status} ',
                    ),
                    trailing: project.status == 'Completed'
                        ? Icon(Icons.check_circle,size: 20,)
                        : project.status == 'In Progress'
                        ? Icon(Icons.autorenew,size: 20,)
                        : project.status == 'Delayed'
                        ? Icon(Icons.hourglass_bottom,size: 20,)
                        : project.status == 'Incomplete'
                        ? Icon(Icons.remove_circle_outline,size: 20,)
                        : Icon(Icons.help_outline, size: 20),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => TasksPage(project: project)),);
                    }
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildSQLiteProjects() {
    if (_projects.isEmpty) {
      return const Center(child: Text("No projects available"));
    }

    return ListView.builder(
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
        return Dismissible(
          key: Key(project.id.toString()),
          direction: DismissDirection.horizontal,
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.swap_horiz, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Project'),
                  content: const Text("Are you sure you want to delete?"),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            } else if (direction == DismissDirection.startToEnd) {
              final newTeam = await _showTeamSelectDialogFromSQLite();
              if (newTeam != null && project.id != null) {
                await DatabaseHelper().reassignProjectToTeam(
                  project.id!,
                  newTeam.id!,
                );
                await _fetchProjects(); // Refresh UI
              }
              return false; // prevent swipe dismiss
            }
            return false;
          },
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              await DatabaseHelper().deleteProject(project.id);
              await _fetchProjects(); // Refresh list
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purpleAccent[80],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              title: Text(project.title),
              subtitle: Text(
                'From: ${project.startdate.split('T')[0]} To: ${project.deadline.split('T')[0]}  Status: ${project.status ?? "Unknown"}',
              ),
              trailing: project.status == 'Completed'
                  ? const Icon(Icons.check_circle, size: 20)
                  : project.status == 'In Progress'
                  ? const Icon(Icons.autorenew, size: 20)
                  : project.status == 'Delayed'
                  ? const Icon(Icons.hourglass_bottom, size: 20)
                  : project.status == 'Incomplete'
                  ? const Icon(Icons.remove_circle_outline, size: 20)
                  : const Icon(Icons.help_outline, size: 20),
              onTap: () {
               /* Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OfflineTaskPage(project: project),
                  ),
                );*/
                Get.to(()=> OfflineTaskPage(project: project));
              },
            ),
          ),
        );
      },
    );
  }
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) =>
              AlertDialog(
                title: const Text("Add New Project"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          labelText: "Project Title"),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text("Start: "),
                        Text(_startDate == null ? "Select Date" : _startDate!
                            .toLocal().toString().split(' ')[0]),
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
                        const Text("End: "),
                        Text(deadline == null ? "Select Date" : deadline!
                            .toLocal()
                            .toString()
                            .split(' ')[0]),
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
                            deadline = picked);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Status: '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: status,
                            hint: const Text("Select Project Status"),
                            isExpanded: true,
                            items: statusOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                status = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () =>Get.back(),
                      child: const Text("Cancel")),
                 /* ElevatedButton(
                      onPressed: _addProject, child: const Text("Add")),
                  */
                  ElevatedButton(
                    onPressed: () async
                    {
                      final connection = await InternetServices.checkInternetAccess();
                      if (connection == true)
                      {
                        final  bool isSuccess = await _addProject();
                        if (isSuccess && mounted) {
                          print("Navigating...");
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Succesfully saved to Firebase 🔥',),
                              backgroundColor: Colors.grey[500],
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save'),
                              backgroundColor: Colors.grey[500],
                            ),
                          );
                        }
                      }
                      else
                      {
                        final bool  Success = await _addProjectDB();
                        if(Success && mounted)
                        {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Succesfully saved to SQL-LITE'),
                              backgroundColor: Colors.grey[500],
                            ),
                          );
                        }
                        else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }

                    },
                    child: Text("Save"),
                  ),
                ],

              ),
        );
      },
    );
  }
  Future<Team?> _showTeamSelectDialog() async {
    final teams = await TeamServices().getAllTeams();

    // Filter out current team so you don't reassign to same team
    final availableTeams = teams.where((t) => t.id != widget.team.id).toList();

    if (availableTeams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other teams available')),
      );
      return null;
    }

    return showDialog<Team>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Reassign Project To"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableTeams.length,
                itemBuilder: (context, index) {
                  final team = availableTeams[index];
                  return TextButton(
                    onPressed: () => Navigator.pop(context, team),
                    child: Text(team.name),
                  );
                },
              ),
            ),
          ),
    );
  }
  Future<Team?> _showTeamSelectDialogFromSQLite() async {
    final teams = await DatabaseHelper().getAllTeams(); // From SQLite

    // Filter out current team so we don't reassign to the same team
    final availableTeams = teams.where((t) => t.id != widget.team.id).toList();

    if (availableTeams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other teams available')),
      );
      return null;
    }

    return showDialog<Team>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reassign Project To (SQLite)"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableTeams.length,
            itemBuilder: (context, index) {
              final team = availableTeams[index];
              return TextButton(
                onPressed: () => Navigator.pop(context, team),
                child: Text(team.name),
              );
            },
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Projects of ${widget.team.name}"),
        backgroundColor: Colors.purple[100],),
      body: _isOnline
          ? _buildFirebaseProjects()
          : _buildSQLiteProjects(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
