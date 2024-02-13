import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ggangs_gym/models/player_model.dart';
import 'package:ggangs_gym/models/team_model.dart';

class TeamAndPlayerController extends GetxController {
  CollectionReference get teamInstance =>
      FirebaseFirestore.instance.collection('team');

  CollectionReference get playerInstance =>
      FirebaseFirestore.instance.collection('player');
  List<QueryDocumentSnapshot> teamList = [];

  ///24.02.06 플레이어문서-record 컬렉션 추가에 따라 플레이어 삭제시 record컬렉션내의 문서도 삭제 배치 추가
  Future<void> deletedPlayer(QueryDocumentSnapshot playerDoc) async {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    QuerySnapshot querySnapshot =
        await playerDoc.reference.collection('record').get();
    for (QueryDocumentSnapshot record in querySnapshot.docs) {
      writeBatch.delete(record.reference);
    }

    DocumentSnapshot crewDocFromTeam = await teamInstance
        .doc(playerDoc['teamId'])
        .collection('crew')
        .doc(playerDoc.id)
        .get();
    writeBatch.delete(crewDocFromTeam.reference);
    writeBatch.delete(playerDoc.reference);
    await writeBatch.commit().then((value) => print('플레이어 삭제 완료'));
  }

  Future<void> addPlayer(List<Player> players) async {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();

    try {
      for (Player player in players) {
        Map<String, dynamic> data = player.toJson();

        DocumentReference playerDoc = playerInstance.doc();
        DocumentReference teamCrewDoc = teamInstance
            .doc(player.teamUID)
            .collection('crew')
            .doc(playerDoc.id);

        writeBatch.set(playerDoc, data);
        writeBatch.set(teamCrewDoc, data);
      }
      writeBatch.commit().whenComplete(() => Get.back(result: true));
    } catch (e) {
      Get.back(result: false);
      Get.snackbar('오류', e.toString());
    }
  }

  Future<void> toBin(QueryDocumentSnapshot target) async {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    DocumentReference binDoc =
        FirebaseFirestore.instance.collection('bin').doc(target.reference.id);
    Map<String, dynamic> data = target.data() as Map<String, dynamic>;
    data['deleteFrom'] = target.reference.parent.id;

    writeBatch.set(binDoc, data);
    await writeBatch.commit().then((_) => print('휴지통 이동 완료'));
  }

  Future<void> deletedTeam(QueryDocumentSnapshot document) async {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    try {
      toBin(document);
      QuerySnapshot querySnapshot =
          await document.reference.collection('crew').get();
      for (QueryDocumentSnapshot snapshot in querySnapshot.docs) {
        writeBatch.delete(snapshot.reference);
      }
      writeBatch.delete(document.reference);
      await writeBatch.commit().whenComplete(() {
        Get.back();
      });
    } catch (e) {
      Get.snackbar('에러', '팀 삭제 에러', duration: Duration(seconds: 1));
    }
  }

  Future<void> addTeam(String teamName) async {
    Team team = Team(name: teamName);
    try {
      await teamInstance.add(team.toJson()).then((value) {
        Get.back();
        Get.snackbar('팀 추가', '팀 추가 완료', duration: const Duration(seconds: 1));
      });
    } catch (e) {
      Get.back();
      Get.snackbar('오류', e.toString());
    }
  }

  Future<QuerySnapshot> getTeams() async {
    QuerySnapshot team = await teamInstance.get();
    teamList = team.docs;

    print('총 팀 수 ${teamList.length}');

    return team;
  }

  Future<QuerySnapshot> getTeamCrew(QueryDocumentSnapshot teamDoc) async {
    QuerySnapshot crews =
        await playerInstance.where('teamId', isEqualTo: teamDoc.id).get();

    return crews;
  }
}
