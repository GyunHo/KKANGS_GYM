import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ggangs_gym/models/game_model.dart';
import 'package:ggangs_gym/models/record_model.dart';

class RecordController extends GetxController {
  CollectionReference recordInstance =
      FirebaseFirestore.instance.collection('record');
  CollectionReference gameInstance =
      FirebaseFirestore.instance.collection('game');

  late DocumentReference gameDoc = gameInstance.doc(gameId);

  String homeScore = '';
  String awayScore = '';

  late DocumentSnapshot homeTeamDoc;
  late DocumentSnapshot awayTeamDoc;
  Game? game;
  String? gameId;
  String? leagueId;
  List<QueryDocumentSnapshot> homeTeamPlayer = [];
  List<QueryDocumentSnapshot> awayTeamPlayer = [];
  int quarter = 1;

  String quarterToString() {
    if (quarter == 5) {
      return 'EX';
    } else {
      return '${quarter}Q';
    }
  }

  Future<void> addScoreToGame() async {
    await gameDoc
        .update({'homeScore': homeScore, 'awayScore': awayScore}).whenComplete(
            () => print('스코어 기록 완료'));
  }

  void setTeams(Game game) {
    homeTeamDoc = game.homeTeam!;
    awayTeamDoc = game.awayTeam!;
  }

  void setPlayers(Game game) {
    homeTeamPlayer = game.homePlayer!;
    awayTeamPlayer = game.awayPlayer!;
  }

  /// 게임 선택시 게임 기록들 불러와서 세팅 이어쓰기 등등
  Future<void> loadGame(QueryDocumentSnapshot gameDoc) async {
    List<QueryDocumentSnapshot> homeP = [];
    List<QueryDocumentSnapshot> awayP = [];
    DocumentSnapshot homeTeamD = await FirebaseFirestore.instance
        .collection('team')
        .doc(gameDoc['homeTeamId'])
        .get();
    DocumentSnapshot awayTeamD = await FirebaseFirestore.instance
        .collection('team')
        .doc(gameDoc['awayTeamId'])
        .get();
    await gameDoc.reference
        .collection('homeTeam')
        .get()
        .then((value) => homeP = value.docs);
    await gameDoc.reference
        .collection('awayTeam')
        .get()
        .then((value) => awayP = value.docs);
    Game game = Game(
        awayTeam: awayTeamD,
        awayPlayer: awayP,
        homePlayer: homeP,
        homeTeam: homeTeamD,
        leagueId: gameDoc['leagueId'],
        gameId: gameDoc.id);
    setTeams(game);
    setPlayers(game);
    this.game = game;
    leagueId = game.leagueId;
    gameId = game.gameId;
  }

  ///신규 게임 시작시 게임 컬렉션에 추가 및 컨트롤러 세팅
  Future<void> addGame(Game game) async {
    setTeams(game);
    setPlayers(game);
    DocumentReference documentReference = gameInstance.doc();
    this.game = game;

    gameId = documentReference.id;
    leagueId = game.leagueId;

    Map<String, dynamic> data = game.toJson();
    data['homeTeamName'] = homeTeamDoc['name'];
    data['awayTeamName'] = awayTeamDoc['name'];

    await documentReference.set(data).whenComplete(() => print('게임 문서 추가 완료'));
  }

  ///게임 문서 생성 후 홈,어웨이팀원 추가, 팀원은 추후 게임디테일 스크린 에서 사용됨
  Future<void> addPlayerToGame() async {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();

    for (var home in homeTeamPlayer) {
      DocumentReference doc =
          gameInstance.doc(gameId).collection('homeTeam').doc(home.id);
      Map<String, dynamic> data = home.data() as Map<String, dynamic>;
      writeBatch.set(doc, data);
    }
    for (var away in awayTeamPlayer) {
      DocumentReference doc =
          gameInstance.doc(gameId).collection('awayTeam').doc(away.id);
      Map<String, dynamic> data = away.data() as Map<String, dynamic>;
      writeBatch.set(doc, data);
    }
    await writeBatch.commit().whenComplete(() => print('게임 문서에 선수들 추가완료'));
  }

  ///스트림 빌더 제공용 스트림
  ///24.02.06 게임-record에서 스냅샷으로 변경
  ///기존 레코드 컬렉션에서 스냅샷찍을경우 데이터가 누적되면 파이어베이스 스트림 읽기 비용 증가 우려
  Stream<QuerySnapshot> recordStream() {
    return gameDoc
        .collection('record')
        .orderBy('time', descending: true)
        .snapshots();
  }

  ///점수, 파울 등 기록
  ///24.02.06 게임-record, record컬렉션, player-record에 직접기록으로 변경
  Future<void> recording(Recording recording) async {
    Map<String, dynamic> data = recording.toJson();
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    DocumentReference toGameDocRecord = gameDoc.collection('record').doc();
    DocumentReference toRecordDocRecord =
        recordInstance.doc(toGameDocRecord.id);

    writeBatch.set(toGameDocRecord, data);
    writeBatch.set(toRecordDocRecord, data);
    if (recording.playerId.isNotEmpty) {
      DocumentReference toPlayerDocRecord = FirebaseFirestore.instance
          .collection('player')
          .doc(recording.playerId)
          .collection('record')
          .doc(toGameDocRecord.id);
      writeBatch.set(toPlayerDocRecord, data);
    }
    await writeBatch.commit().then((value) => print('기록 완료'));
  }

  ///게임id로 모든 레코드 검색
  /// ///24.02.06 게임-record에서 스냅샷으로 변경
  Future<List<QueryDocumentSnapshot>> getGameRecord() async {
    QuerySnapshot querySnapshot = await gameDoc.collection('record').get();

    return querySnapshot.docs;
  }

  ///게임기록중 기록 삭제
  ///24.02.06 게임-record에서 삭제 하고, 레코드컬렉션에서 삭제, 플레이어-record컬렉션에서 삭제
  Future<void> deleteRecord(QueryDocumentSnapshot snapshot) async {
    // await snapshot.reference.delete().then((value) => print('기록 삭제 완료'));
    Recording record = Recording.fromQueryDocumentSnapshot(snapshot);
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    DocumentReference gameDocRecord = snapshot.reference;
    DocumentReference recordDocRecord = recordInstance.doc(gameDocRecord.id);
    if (record.playerId.isNotEmpty) {
      DocumentReference playerDocRecord = FirebaseFirestore.instance
          .collection('player')
          .doc(record.playerId)
          .collection('record')
          .doc(gameDocRecord.id);
      writeBatch.delete(playerDocRecord);
    }

    writeBatch.delete(gameDocRecord);
    writeBatch.delete(recordDocRecord);
    await writeBatch.commit().then((value) => print('기록 삭제 완료'));
  }

  ///게임 전체 레코드에서 팀 id로 분리
  List<QueryDocumentSnapshot> getTeamRecords(
      List<QueryDocumentSnapshot> rec, String teamId) {
    return rec.where((element) {
      return element['playerTeamId'] == teamId;
    }).toList();
  }

  ///전광판 점수 계산
  String calcPoint(List<QueryDocumentSnapshot> rec) {
    int point1 = 0;
    int point2 = 0;
    int point3 = 0;
    for (var element in rec) {
      switch (element['recordType']) {
        case '1점':
          point1++;
          break;
        case '2점':
          point2++;
          break;
        case '3점':
          point3++;
          break;
      }
    }
    return (point1 + (point2 * 2) + (point3 * 3)).toString();
  }

  ///전광판 쿼터별 파울 계산
  Map<String, int> calcEachQuarterFoul(List<QueryDocumentSnapshot> rec) {
    Map<String, int> data = {};

    List<QueryDocumentSnapshot> fouls =
        rec.where((element) => element['recordType'] == '파울').toList();
    for (QueryDocumentSnapshot foul in fouls) {
      if (!data.containsKey(foul['quarter'])) {
        data[foul['quarter']] = 0;
      }
      data.update(foul['quarter'], (value) => value + 1);
    }
    return data;
  }

  ///전광판 쿼터별 작전타임
  Map<String, int> calcEachQuarterTimeout(List<QueryDocumentSnapshot> rec) {
    Map<String, int> data = {};
    List<QueryDocumentSnapshot> times =
        rec.where((element) => element['recordType'] == '작전타임').toList();
    for (QueryDocumentSnapshot time in times) {
      if (!data.containsKey(time['quarter'])) {
        data[time['quarter']] = 0;
      }
      data.update(time['quarter'], (value) => value + 1);
    }
    return data;
  }

  ///게임 기록 중 선수 추가시 필요기능
  Future<List<QueryDocumentSnapshot>> getRemainingPlayer(
      String witchTeam) async {
    QuerySnapshot homeTeamCrew =
        await homeTeamDoc.reference.collection('crew').get();
    QuerySnapshot awayTeamCrew =
        await awayTeamDoc.reference.collection('crew').get();
    List<QueryDocumentSnapshot> remainHome = homeTeamCrew.docs
        .where((player) => homeTeamPlayer
            .where((inPlayer) => player.id == inPlayer.id)
            .toList()
            .isEmpty)
        .toList();
    List<QueryDocumentSnapshot> remainAway = awayTeamCrew.docs
        .where((player) => awayTeamPlayer
            .where((inPlayer) => player.id == inPlayer.id)
            .toList()
            .isEmpty)
        .toList();

    if (witchTeam == 'home') {
      return remainHome;
    } else {
      return remainAway;
    }
  }

  /// 게임기록중 게임 문서에  추가 선수 기록
  void playingGameAddPlayer(QueryDocumentSnapshot player, String witchTeam) {
    Map<String, dynamic> playerData = player.data() as Map<String, dynamic>;
    if (witchTeam == 'home') {
      homeTeamPlayer.add(player);
      gameDoc.collection('homeTeam').doc(player.reference.id).set(playerData);
    } else {
      awayTeamPlayer.add(player);
      gameDoc.collection('awayTeam').doc(player.reference.id).set(playerData);
    }
  }

  ///선수 타입별 전체기록 분류 - 선수가 경기중 현재 몇점 기록했는지 보고 싶데서...sumPoint에서 사용
  Map<String, Map<String, int>> splitRecord(
      List<QueryDocumentSnapshot> records) {
    Map<String, Map<String, int>> data = {};
    for (QueryDocumentSnapshot record in records) {
      Recording rec = Recording.fromQueryDocumentSnapshot(record);
      data.update(rec.playerId, (value) {
        Map<String, int> res = value;
        res.update(rec.recordType, (point) => point + 1, ifAbsent: () => 1);
        return res;
      }, ifAbsent: () => {rec.recordType: 1});
    }
    return data;
  }

  ///선수 기록에서 점수 합계
  int sumPoint(Map<String, int> data) {
    int point = 0;
    data.forEach((key, value) {
      switch (key) {
        case "1점":
          point += value * 1;
          break;
        case "2점":
          point += value * 2;
          break;
        case "3점":
          point += value * 3;
          break;
      }
    });
    return point;
  }
}
