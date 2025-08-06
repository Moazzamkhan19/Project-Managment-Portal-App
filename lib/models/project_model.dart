import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  String id;
  String title;
  String deadline;
  String startdate;
  String? status;
  String teamId;

  Project({
    required this.id,
    required this.title,
    required this.deadline,
    required this.startdate,
    this.status,
    required this.teamId,
  });

  factory Project.fromFirestore(Map<String, dynamic> data, String docId) {
    return Project(
      id: docId,
      title: data['title'],
      deadline: data['deadline'],
      startdate: data['startdate'],
      status: data['status'],
      teamId: data['teamId'],
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'deadline': deadline,
      'startdate': startdate,
      'status': status,
      'teamId': teamId,
    };
  }
  factory Project.fromJson(Map<String, dynamic> json, String docId) {
    return Project(
      id: docId,
      teamId: json['teamId'] ?? '',
      title: json['title'] ?? '',
      deadline: json['deadline'] ?? '',
      startdate: json['startdate'] ?? '',
      status: json['status'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'title': title,
      'startdate': startdate,
      'deadline': deadline,
      'status':status,
    };
  }
  factory Project.fromDocument(DocumentSnapshot doc) {
    return Project(
      id: doc.id,
      teamId: doc['teamId'],
      startdate: doc['startdate'],
      deadline: doc['deadline'],
      title: doc['title'],
      status: doc['status'],
    );
  }

  // to map methods for databse
  Map<String, dynamic> toMap({bool withId = true}) {
    final map = {
      'teamId': teamId,
      'title': title,
      'startdate': startdate,
      'deadline': deadline,
      'status': status,
    };

    if (withId) {
      map['id'] = id;
    }
    return map;
  }
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'].toString(),
      teamId: map['teamId'] ?? '',
      title: map['title'] ?? '',
      startdate: map['startdate'] ?? '',
      deadline: map['deadline'] ?? '',
      status: map['status'],
    );
  }


}


