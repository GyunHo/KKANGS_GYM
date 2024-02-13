import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GameQuery extends GetxController {
  late QueryDocumentSnapshot _gameDoc;
  List<QueryDocumentSnapshot> homePlayers = [];
  List<QueryDocumentSnapshot> awayPlayers = [];
  CollectionReference recordInstance =
      FirebaseFirestore.instance.collection('record');
  Map<String, Map<String, Map<String, int>>> homePlayerRecords = {};
  Map<String, Map<String, Map<String, int>>> awayPlayerRecords = {};
  Map<String, Map<String, Map<String, int>>> eachTeamRecords = {};

  List<String> teamHeaders = ['1점', '2점', '3점', '리바운드', '어시스트', '파울', '작전타임'];
  List<String> headers = ['1점', '2점', '3점', '리바운드', '어시스트', '파울'];
  List<String> quarters = ['1Q', '2Q', '3Q', '4Q', 'EX'];

  get getGameDoc => _gameDoc;

  ///24.02.06 게임기록이 record컬렉션에서 game컬렉션-게임문서-record 컬렉션 기록 추가 돼서 추가 삭제 배치

  Future<void> deleteGame() async {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    await _gameDoc.reference.collection('record').get().then((value) {
      for (QueryDocumentSnapshot snapshot in value.docs) {
        ///게임컬렉션에서도 삭제
        writeBatch.delete(recordInstance.doc(snapshot.id));
        ///플레이어의 레코드 컬렉션에서도 삭제
        String playerId = snapshot['playerID'];
        if (playerId.isNotEmpty) {
          DocumentReference playerDocRecordDoc = FirebaseFirestore.instance
              .collection('player')
              .doc(playerId)
              .collection('record')
              .doc(snapshot.id);
          writeBatch.delete(playerDocRecordDoc);
        }

        writeBatch.delete(snapshot.reference);
      }
    });
    await _gameDoc.reference.collection('homeTeam').get().then((value) {
      for (QueryDocumentSnapshot snapshot in value.docs) {
        writeBatch.delete(snapshot.reference);
      }
    });
    await _gameDoc.reference.collection('awayTeam').get().then((value) {
      for (QueryDocumentSnapshot snapshot in value.docs) {
        writeBatch.delete(snapshot.reference);
      }
    });
    List<QueryDocumentSnapshot> records = await getGameRecord();
    for (QueryDocumentSnapshot record in records) {
      writeBatch.delete(record.reference);
    }

    await writeBatch.commit().then((value) {
      _gameDoc.reference.delete().then((value) => print('게임 기록 삭제 완료'));
    });
  }

  Future<void> setGame(QueryDocumentSnapshot gameDoc) async {
    _gameDoc = gameDoc;
    await setGamePlayers();
    await recordDecode().whenComplete(() => print('게임 세팅 완료'));
  }

  ///게임에 뛴 선수들 불러와서 세팅
  Future<void> setGamePlayers() async {
    QuerySnapshot home = await _gameDoc.reference.collection('homeTeam').get();
    QuerySnapshot away = await _gameDoc.reference.collection('awayTeam').get();
    homePlayers.addAll(home.docs);
    awayPlayers.addAll(away.docs);
  }

  ///쿼터별 점수 총합
  Map<String, int> calcQuarterPointTotal(Map<String, Map<String, int>> record) {
    Map<String, int> result = {};
    for (String quarter in quarters) {
      int point_1 = record[quarter]!['1점']!;
      int point_2 = record[quarter]!['2점']! * 2;
      int point_3 = record[quarter]!['3점']! * 3;
      result[quarter] = point_1 + point_2 + point_3;
    }

    return result;
  }

  ///선수의 쿼터별 기록을 받아서 헤더별 총합을 리턴해줌 {1점 : 1, 리바운드 : 2...}
  Map<String, int> calcHeaderTotal(
      Map<String, Map<String, int>> record, List<String> headers) {
    Map<String, int> total = {};
    for (var header in headers) {
      total[header] = 0;
    }
    record.forEach((quarter, typeMap) {
      for (var header in headers) {
        total.update(header, (value) => value + typeMap[header]!);
      }
    });
    return total;
  }

  ///record컬렉션에서 game id가 같은 기록 전체를 불러오기
  ///24.02.06 게임기록이 record 컬렉션에서 game레코드-게임문서-record컬렉션 기록으로 변경됨.
  ///기록 누적에 따라 파이어베이스 읽기 금액 증가 우려해서 변경함
  Future<List<QueryDocumentSnapshot>> getGameRecord() async {
    // QuerySnapshot querySnapshot =
    //     await recordInstance.where('gameId', isEqualTo: _gameDoc.id).get();
    QuerySnapshot querySnapshot =
        await _gameDoc.reference.collection('record').get();
    return querySnapshot.docs;
  }

  ///게임 전체 기록에서 홈, 어웨이팀 의 선수번호-쿼터-헤더의 형태로 설정 {플레이어id : {1쿼터 : {1점:1, 3점:0...},2쿼터 : {1점:1, 3점:0...}}}
  Future<void> recordDecode() async {
    List<QueryDocumentSnapshot> allRecord = await getGameRecord();
    Map<String, Map<String, Map<String, int>>> homeDecode = {};
    Map<String, Map<String, Map<String, int>>> awayDecode = {};
    eachTeamRecords[_gameDoc['homeTeamId']] = makeFrame(teamHeaders);
    eachTeamRecords[_gameDoc['awayTeamId']] = makeFrame(teamHeaders);

    ///홈 플레이어 전체 레코드 기본틀
    for (var player in homePlayers) {
      homeDecode[player.id] = makeFrame(headers);
    }

    ///어웨이 플레이어 전체 레코드 기본틀
    for (var player in awayPlayers) {
      awayDecode[player.id] = makeFrame(headers);
    }
    List<String> homeIds = homePlayers.map((e) => e.id).toList();
    List<String> awayIds = awayPlayers.map((e) => e.id).toList();
    for (var record in allRecord) {
      eachTeamRecords[record['playerTeamId']]?[record['quarter']]
          ?.update(record['recordType'], (value) => value + 1);
      if (homeIds.contains(record['playerID'])) {
        homeDecode[record['playerID']]?[record['quarter']]
            ?.update(record['recordType'], (int value) => value + 1);
      }
      if (awayIds.contains(record['playerID'])) {
        awayDecode[record['playerID']]?[record['quarter']]
            ?.update(record['recordType'], (int value) => value + 1);
      }
    }
    homePlayerRecords = homeDecode;
    awayPlayerRecords = awayDecode;
  }

  /// 쿼터별로 기록 나눈 기본틀{quarter:{recordType : 1점... }}
  Map<String, Map<String, int>> makeFrame(List headers) {
    Map<String, Map<String, int>> result = {};
    for (var quarter in quarters) {
      Map<String, int> quarterRecord = {};
      for (var header in headers) {
        quarterRecord[header] = 0;
      }
      result[quarter] = quarterRecord;
    }
    return result;
  }
}
