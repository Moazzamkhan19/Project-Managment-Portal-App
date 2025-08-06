import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:project_managment_fb/models/team_model.dart';
import 'package:sqflite/sqflite.dart';
class TeamServices {
  final teamcollection = FirebaseFirestore.instance.collection('teams');

  Future<List<Team>> getAllTeams() async
  {
    final snapshot = await teamcollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Team.fromMap(data);
    }).toList();
  }

  Future<bool> SYNCTeam() async {
    try {
      final dbPath = await getDatabasesPath();
      final db = await openDatabase(join(dbPath, 'app.db'));

      final List<Map<String, dynamic>> localTeams = await db.query('team');

      for (var teamMap in localTeams) {
        final team = Team.fromMap(teamMap);
        final teamData = team.toMap();

        await teamcollection.doc(team.id).set({
          ...teamData,
          'addedAt': FieldValue.serverTimestamp(),
        });
        //deleting the teams from SQL
        await db.delete(
          'team',
          where: 'id = ?',
          whereArgs: [team.id],
        );
      }

      print("✅ Sync completed: All teams uploaded to Firebase.");

      return true;
    } catch (e) {
      print("❌ Sync failed: $e");
      return false;
    }
  }

  Future<List<Team>> FetchTeams() async {
    try {
      final snapshot = await teamcollection.get();
      final teams = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Team.fromMap(data);
      }).toList();

      print("✅ Fetched ${teams.length} teams from Firebase.");
      return teams;
    } catch (e) {
      print("❌ Failed to fetch teams: $e");
      return [];
    }
  }
}