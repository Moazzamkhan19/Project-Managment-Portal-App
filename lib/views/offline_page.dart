import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:project_managment_fb/views/project_page.dart';
import '../database/database.dart';
import '../models/team_model.dart';

class OfflinePage extends StatefulWidget {
  const OfflinePage({super.key});

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  @override
  List<Team> _teamList=[];
  @override
  void initState()
  {
    super.initState();
    fetchTeam();
  }
  Future<void> fetchTeam() async
  {
    final teams = await DatabaseHelper().getAllTeams();
    setState(()=>_teamList=teams);
  }
  Widget buildTeamList() {
    if (_teamList.isEmpty) {
      return const Center(child: Text('No team members added.'));
    }

    return ListView.builder(
      itemCount: _teamList.length,
      itemBuilder: (context, index) {
        final team = _teamList[index];

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
                      onPressed: () => Get.back(result: false),
                       child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              await DatabaseHelper().deleteTeam(team.id!);
              await fetchTeam();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12 , vertical: 6),
              decoration: BoxDecoration(color: Colors.purpleAccent[80],borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(0, 4))
                  ]),
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
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectPage(team: team),
                    ),
                  );*/
                  Get.to(() => ProjectPage(team: team));
                },

              ),)

        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: const Text('Offline Saved Team'),
        centerTitle: true,
        backgroundColor: Colors.purple[100],
        leading: IconButton(
          icon: Icon(Icons.home), // or Icons.arrow_back
          tooltip: 'Go to Home',
          onPressed: () {
           /* Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
                  (Route<dynamic> route) => false, // removes all previous routes
            );*/
            Get.offAllNamed('/home');
          },
        ),
      ),
      body: buildTeamList(), // ✅ Show the list here!
    );
  }
}
