import 'package:cloud_firestore/cloud_firestore.dart';

class Recording {
  String playerId;
  String playerTeamId;
  String gameId;
  String leagueId;
  String recordType;
  String quarter;

  Recording(
      {required String playerid,
      required String playerteamid,
      required String gameid,
      required String leagueid,
      required String recordtype,
      required String qt})
      : playerId = playerid,
        playerTeamId = playerteamid,
        gameId = gameid,
        leagueId = leagueid,
        recordType = recordtype,
        quarter = qt;

  Map<String, dynamic> toJson() {
    return {
      'leagueId': leagueId,
      'playerID': playerId,
      'playerTeamId': playerTeamId,
      'gameId': gameId,
      'recordType': recordType,
      'quarter': quarter,
      'time': DateTime.now()
    };
  }

  factory Recording.fromQueryDocumentSnapshot(
      QueryDocumentSnapshot queryDocumentSnapshot) {
    return Recording(
        playerid: queryDocumentSnapshot['playerID'],
        playerteamid: queryDocumentSnapshot['playerTeamId'],
        gameid: queryDocumentSnapshot['gameId'],
        leagueid: queryDocumentSnapshot['leagueId'],
        recordtype: queryDocumentSnapshot['recordType'],
        qt: queryDocumentSnapshot['quarter']);
  }
}
