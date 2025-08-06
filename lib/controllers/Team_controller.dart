import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_managment_fb/database/database.dart';
import 'package:uuid/uuid.dart';
import '../models/team_model.dart';

class TeamController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  List<Team> _teams = [];

  List<Team> get teams => _teams;

  // Add team to Firestore (auto-generate ID and assign it to model)
  Future<void> addTeam(Team team) async {
    final docRef = await _firestore.collection('teams').add(team.toMap());
    final newTeam = team.copyWith(id: docRef.id);
    _teams.add(newTeam);
    notifyListeners();
  }
  Future<void> addTeamDB(Team team) async {
    final String id = (team.id == null || team.id!.isEmpty) ? _uuid.v4() : team.id!;
    final newTeam = team.copyWith(id: id);
    await _dbHelper.insertTeam(newTeam);
    _teams.add(newTeam);
    notifyListeners();
  }

  Future<void> fetchTeamsFromDB() async {
    try {
      final List<Team> fetchedTeams = await _dbHelper.getAllTeams();
      _teams = fetchedTeams;
      notifyListeners();
    } catch (e) {
      print("Error fetching teams from DB: $e");
    }
  }
  Future<void> fetchTeams() async {
    final snapshot = await _firestore.collection('teams').get();
    _teams = snapshot.docs.map((doc) {
      final teamData = doc.data();
      return Team.fromMap({
        ...teamData,
        'id': doc.id, // inject Firestore doc id into the map
      });
    }).toList();
    notifyListeners();
  }

  // Delete team by email
  Future<void> deleteTeamByEmail(String email) async {
    final query = await _firestore
        .collection('teams')
        .where('email', isEqualTo: email)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    await fetchTeams();
  }

  bool isValidEmailFormat(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email.trim());
  }

  bool isValidPhoneNumber(String phone) {
    return phone.length == 11;
  }
}

