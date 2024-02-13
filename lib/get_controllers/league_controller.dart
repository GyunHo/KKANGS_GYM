import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ggangs_gym/models/league_model.dart';

class LeagueController extends GetxController {
  CollectionReference get leagueInstance =>
      FirebaseFirestore.instance.collection('league');

  CollectionReference get gameInstance =>
      FirebaseFirestore.instance.collection('game');

  List<QueryDocumentSnapshot> leagueList = [];
  late QueryDocumentSnapshot selectedLeague;

  Future<void> addLeague(String leagueName) async {
    League league = League(name: leagueName);
    try {
      await leagueInstance.add(league.toJson()).then((value) {
        Get.back();
        Get.snackbar('리그추가', '리그 추가 완료', duration: const Duration(seconds: 1));
      });
    } catch (e) {
      Get.back();
      Get.snackbar('오류', e.toString());
    }
  }

  Future<void> toBin(QueryDocumentSnapshot target) async {
    QuerySnapshot games = await getGameList(target);
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    DocumentReference binDoc =
        FirebaseFirestore.instance.collection('bin').doc(target.reference.id);
    Map<String, dynamic> data = target.data() as Map<String, dynamic>;
    data['deleteFrom'] = target.reference.parent.id;
    writeBatch.set(binDoc, data);
    for (var element in games.docs) {
      writeBatch.delete(element.reference);
    }

    await writeBatch.commit().then((_) => print('휴지통 이동 완료'));
  }

  Future<void> deletedLeague(QueryDocumentSnapshot document) async {
    await document.reference.delete().then((value) => toBin(document));
  }

  Future<QuerySnapshot> getLeagues() async {
    QuerySnapshot league = await leagueInstance.get();
    leagueList = league.docs;

    print('총 리그 수 ${leagueList.length}');
    return league;
  }

  Future<QuerySnapshot> getGameList(QueryDocumentSnapshot snapshot) async {
    QuerySnapshot game = await gameInstance
        .where('leagueId', isEqualTo: snapshot.reference.id)
        .orderBy('time', descending: true)
        .get();
    return game;
  }
}
