import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  late final String id;
  final String description;
  final String startdate;
  final String enddate;
  final int priority;
  final String projectid;
  final String teamId;
  late final bool isCompleted;

  Task({
    required this.id,
    required this.description,
    required this.startdate,
    required this.enddate,
    required this.priority,
    required this.projectid,
    required this.teamId,
    required this.isCompleted,

  });

  Map<String, dynamic> toMap({bool withId = true}) {
    final map = {
      'description': description,
      'startdate': startdate,
      'enddate': enddate,
      'priority': priority,
      'projectid': projectid,
      'teamId':teamId,
      'isCompleted':isCompleted,
    };
    if (withId) map['id'] = id;
    return map;
  }

  //for database
 /* factory Task.fromMap1(Map<String, dynamic> map, String docId) {
    return Task(
      id: docId,
      description: map['description'] ?? '',
      startdate: map['startdate'] ?? '',
      enddate: map['enddate'] ?? '',
      priority: map['priority'] ?? 0,
      projectid: map['projectid'] ?? '',
      teamId: map['teamId'] ?? '',
    );
  }
  */



 /* factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      projectid: data['projectid'],
      description: data['description'],
      startdate: data['startdate'],
      enddate: data['enddate'],
      priority: data['priority'],
      teamId: data['teamId'],
      isCompleted: data['isCompleted']?? false,
    );
  }
  */
  factory Task.fromMap(String docId, Map<String, dynamic> data) {
    return Task(
      id: docId,
      description: data['description'],
      startdate: data['startdate'],
      enddate: data['enddate'],
      priority: data['priority'],
      projectid: data['projectid'],
      teamId: data['teamId'],
      isCompleted: data['isCompleted'] ?? false,
    );
  }



  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'description': description,
      'startdate': startdate,
      'enddate': enddate,
      'priority': priority,
      'projectid': projectid,
      'teamId':teamId,
      'isCompleted':isCompleted,
    };
  }

 /*factory Task.fromFirestore(Map<String, dynamic> data, String docId) {
    return Task(
      id: docId,
      description: data['description'] ?? '',
      startdate: data['startdate'] ?? '',
      enddate: data['enddate'] ?? '',
      priority: data['priority'] ?? 0,
      projectid: data['projectid']?.toString() ?? '',
      teamId: data['teamId']??'',
      isCompleted: data['isCompleted']?? false,
    );
  }*/
  factory Task.fromFirestore(Map<String, dynamic> data, String docId) {
    return Task(
      id: docId,
      description: data['description']?.toString() ?? '',
      startdate: data['startdate']?.toString() ?? '',
      enddate: data['enddate']?.toString() ?? '',
      priority: data['priority'] is int
          ? data['priority']
          : int.tryParse(data['priority']?.toString() ?? '0') ?? 0,
      projectid: data['projectid']?.toString() ?? '',
      teamId: data['teamId']?.toString() ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json, String docId) {
    return Task(
      id: docId,
      description: json['description'] ?? '',
      startdate: json['startdate'] ?? '',
      enddate: json['enddate'] ?? '',
      priority: json['priority'] ?? 0,
      projectid: json['projectid'] ?? 0,
      teamId: json['teamId']??'',
      isCompleted: json['isCompleted']?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'startdate': startdate,
      'enddate': enddate,
      'priority': priority,
      'projectid': projectid,
      'teamId': teamId,
      'isCompleted':isCompleted,
    };
  }
  factory Task.fromDocument(DocumentSnapshot doc) {
    return Task(
      id: doc.id,
      description: doc['description'],
      startdate: doc['startdate'],
      enddate: doc['enddate'],
      projectid: doc['projectid'],
      priority: doc['priority'],
      teamId: doc['teamId'],
      isCompleted: doc['isCompleted']?? false,
    );
  }
  //for database
  factory Task.fromMap1(Map<String, dynamic> map) {
    return Task(
      id: map['id'].toString(),
      projectid: map['projectid'] ?? '',
      startdate: map['startdate']??'',
      teamId: map['teamId'] ?? '',
      description: map['description'] ?? '',
      enddate: map['enddate'] ?? '',
      priority: map['priority'],
      isCompleted: map['isCompleted']??false,
    );
  }
}


