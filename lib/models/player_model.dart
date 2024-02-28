import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  String teamUID;
  String uniformNumber;
  String? playerName;
  String? playerImg;
  DateTime? createTime;

  Player(
      {required String teamID,
      required String number,
      required String name,
      String? img,
      DateTime? createTime})
      : teamUID = teamID,
        uniformNumber = number,
        playerName = name,
        playerImg = img;

  Map<String, dynamic> toJson() {
    return {
      "teamId": teamUID,
      "uniformNumber": uniformNumber,
      "playerName": playerName,
      "playerImg": playerImg,
      "time": DateTime.now()
    };
  }

  factory Player.fromQueryDocumentSnapshot(QueryDocumentSnapshot snapshot) {
    Timestamp timestamp = snapshot['time'];
    DateTime createTime = timestamp.toDate();
    return Player(
        teamID: snapshot['teamId'],
        number: snapshot['uniformNumber'],
        name: snapshot['playerName'],
        img: snapshot['playerImg'],
        createTime: createTime);
  }
}
