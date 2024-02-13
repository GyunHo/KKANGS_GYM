import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  String teamName;

  Team({required String name}) : teamName = name;
  Map<String, dynamic>toJson() {
    return {"name": teamName,"time":DateTime.now()};
  }
  factory Team.fromSnapshot(QueryDocumentSnapshot snapshot) {
    return Team(name: snapshot['name']);
  }

}
