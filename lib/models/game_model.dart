import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  String leagueId;
  DocumentSnapshot? homeTeam;
  DocumentSnapshot? awayTeam;
  List<QueryDocumentSnapshot>? homePlayer;
  List<QueryDocumentSnapshot>? awayPlayer;
  String? gameId;

  Game(
      {required this.leagueId,
      required this.homeTeam,
      required this.awayTeam,
      required this.homePlayer,
      required this.awayPlayer,
      this.gameId});

  toJson() {
    return {
      'leagueId': leagueId,
      'homeTeamId': homeTeam!.id,
      'awayTeamId': awayTeam!.id,
      'time': DateTime.now(),
      'awayScore': '0',
      'homeScore': '0'
    };
  }

  // factory Game.fromSnapshot(QueryDocumentSnapshot snapshot) {
  //   List<QueryDocumentSnapshot> homePlayers = [];
  //   List<QueryDocumentSnapshot> awayPlayers = [];
  //   late DocumentSnapshot homeT;
  //   late DocumentSnapshot awayT;
  //   snapshot.reference
  //       .collection('awayTeam')
  //       .get()
  //       .then((value) => awayPlayers = value.docs);
  //   snapshot.reference
  //       .collection('homeTeam')
  //       .get()
  //       .then((value) => homePlayers = value.docs);
  //   FirebaseFirestore.instance
  //       .collection('team')
  //       .doc(snapshot['homeTeamId'])
  //       .get()
  //       .then((value) => homeT = value);
  //   FirebaseFirestore.instance
  //       .collection('team')
  //       .doc(snapshot['awayTeamId'])
  //       .get()
  //       .then((value) => awayT = value);
  //
  //   return Game(
  //       leagueId: snapshot['leagueId'],
  //       awayPlayer: awayPlayers,
  //       homePlayer: homePlayers,
  //       awayTeam: awayT,
  //       homeTeam: homeT,
  //       gameId: snapshot.id);
  // }
}
