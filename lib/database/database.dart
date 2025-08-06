import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/team_model.dart';
import '../models/project_model.dart';
import 'package:project_managment_fb/models/Task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE team (
        id TEXT PRIMARY KEY ,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        designation TEXT NOT NULL,
        image TEXT
      )
    ''');
    await db.execute('''
CREATE TABLE project (
  id TEXT PRIMARY KEY,
  teamId TEXT NOT NULL,
  title TEXT NOT NULL,
  startDate TEXT NOT NULL,
  deadline TEXT NOT NULL,
  status TEXT,
  FOREIGN KEY (teamId) REFERENCES team(id)
)
''');
    await db.execute('''
  CREATE TABLE task (
    id TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    startdate TEXT NOT NULL,
    enddate TEXT NOT NULL,
    priority INTEGER NOT NULL,
    projectid INTEGER NOT NULL,
    teamId TEXT NOT NULL,
    FOREIGN KEY (projectid) REFERENCES project(id)
  )
''');
  }

  /*Future<int> insertTeam(Team team) async {
    final db = await database;
    return await db.insert('team', team.toMap());
  }*/
  Future<void> insertTeam(Team team) async {
    final db = await database;
    await db.insert('team', team.toMapForSQL());
  }


  Future<int> insertTask(Task task) async
  {
    final db = await database;
    print('Saving to SQLite: ${task.toMap()}');
    return await db.insert('task', task.toMap());

  }

  Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert('project', project.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('task');
    return List.generate(maps.length, (i) => Task.fromMap1(maps[i]));
  }

  Future<List<Team>> getAllTeams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('team');
    return List.generate(maps.length, (i) => Team.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByProjectId(String projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'task',
      where: 'projectid = ?',
      whereArgs: [projectId],
    );
    return List.generate(maps.length, (i) => Task.fromMap1(maps[i]));
  }

  Future<List<Project>> getProjectsByTeamId(String teamId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query (
      'project',
      where: 'teamId = ?',
      whereArgs: [teamId],
    );
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  Future<void> deleteAllTeams() async {
    final db = await database;
    await db.delete('team');
  }

  Future<void> deleteProject(String id) async {
    final db = await database;
    await db.delete(
      'project',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete(
      'task',
      where: 'id = ?',
      whereArgs: [taskId],
    );
    print('Trying to delete task with id: $taskId');

  }


  Future<void> deleteTeam(String id) async
  {
    final db = await database;
    await db.delete('team', where: 'id = ?', whereArgs: [id],);
  }

  Future<void> reassignProjectToTeam(String projectId, String newTeamId) async {
    final db = await database;
    await db.update(
      'project',
      {'teamId': newTeamId},
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'task',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
  Future<Project?> getProjectById(String projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'project',
      where: 'id = ?', // assuming your project table's PK is `id`
      whereArgs: [projectId],
    );
    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    }
    return null;
  }

  Future<Team?> getTeamById(String teamId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'team',
      where: 'id = ?',
      whereArgs: [teamId],
    );
    if (maps.isNotEmpty) {
      return Team.fromMap(maps.first);
    }
    return null;
  }
  Future<void> printAllTeams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('team');

    if (maps.isEmpty) {
      print("No teams found in SQLite.");
    } else {
      print("Teams in SQLite:");
      for (var map in maps) {
        print(map);
      }
    }
  }
  Future<void> debugPrintAllProjects(String teamId) async {
    final projects = await DatabaseHelper().getProjectsByTeamId(teamId);
    print("🔍 Projects in SQLite for team $teamId:");
    for (var p in projects) {
      print("📁 ${p.title} | ${p.startdate} - ${p.deadline} | Status: ${p.status}  | ID : ${p.id} | TEAMID : ${p.teamId}");
    }
  }


}

