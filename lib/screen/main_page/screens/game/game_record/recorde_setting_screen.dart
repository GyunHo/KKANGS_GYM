import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ej_selector/ej_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/record_controller.dart';
import 'package:ggangs_gym/get_controllers/team_player_controller.dart';
import 'package:ggangs_gym/models/game_model.dart';
import 'package:ggangs_gym/screen/main_page/screens/game/game_record/recorder_screen.dart';

class RecordSettingScreen extends StatefulWidget {
  const RecordSettingScreen({super.key});

  @override
  State<RecordSettingScreen> createState() => _RecordSettingScreenState();
}

class _RecordSettingScreenState extends State<RecordSettingScreen> {
  List<QueryDocumentSnapshot> teams = [];
  QueryDocumentSnapshot league = Get.arguments[0];
  List<QueryDocumentSnapshot> homeTeamPlayer = [];
  List<QueryDocumentSnapshot> awayTeamPlayer = [];
  List<QueryDocumentSnapshot> selectHomeTeamPlayer = [];
  List<QueryDocumentSnapshot> selectAwayTeamPlayer = [];
  QueryDocumentSnapshot? homeTeam;
  QueryDocumentSnapshot? awayTeam;

  TeamAndPlayerController teamAndPlayerController = Get.find();

  bool _containTeams(QueryDocumentSnapshot snapshot) {
    String homeId = homeTeam?.id ?? '';
    String awayId = awayTeam?.id ?? '';
    String id = snapshot.id;
    if (id == homeId || id == awayId) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    teamAndPlayerController.getTeams().then((value) {
      setState(() {
        teams.addAll(value.docs);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    TeamAndPlayerController teamAndPlayerController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${league['name'] ?? 'un Known'} 리그',
          style: textTheme.headlineLarge!
              .copyWith(color: colorScheme.onPrimaryContainer),
        ),
        centerTitle: true,
      ),
      backgroundColor: colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'HOME TEAM',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium!
                          .copyWith(color: Colors.white),
                    ),
                    EJSelectorButton<QueryDocumentSnapshot>(
                      onChange: (e) async {
                        await teamAndPlayerController
                            .getTeamCrew(e)
                            .then((value) {
                          // homeTeamPlayer = value.docs;
                          selectHomeTeamPlayer = value.docs;
                          homeTeamPlayer.clear();
                          if (homeTeam != null) {
                            teams.removeWhere((element) => element.id == e.id);
                            teams.add(homeTeam!);
                          } else {
                            teams.removeWhere((element) => element.id == e.id);
                          }
                          homeTeam = e;

                          setState(() {});
                        });
                      },
                      useValue: false,
                      hint: Text(
                        '홈팀 선택',
                        style: textTheme.headlineSmall,
                      ),
                      buttonBuilder: (child, value) => Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue.withOpacity(0.9),
                        ),
                        child: value != null
                            ? Text(
                                value['name'],
                                style: textTheme.headlineSmall,
                              )
                            : child,
                      ),
                      selectedWidgetBuilder: (valueOfSelected) => Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8)),
                        width: double.infinity,
                        child: Text(valueOfSelected['name'],
                            style: textTheme.headlineSmall),
                      ),
                      items: teams
                          .map(
                            (item) => EJSelectorItem(
                              value: item,
                              widget: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white54,
                                    borderRadius: BorderRadius.circular(8)),
                                width: double.infinity,
                                child: Text(
                                  item['name'],
                                  style: textTheme.headlineSmall,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: GridView.builder(
                              itemCount: selectHomeTeamPlayer.length + 1,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4),
                              itemBuilder: (cntx, count) {
                                if (count == selectHomeTeamPlayer.length) {
                                  return EJSelectorButton<
                                      QueryDocumentSnapshot>(
                                    onChange: (player) {
                                      homeTeamPlayer.removeWhere(
                                          (element) => element.id == player.id);
                                      selectHomeTeamPlayer.add(player);

                                      setState(() {});
                                    },
                                    buttonBuilder: (child, value) => Card(
                                      color: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            '추가',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    items: homeTeamPlayer
                                        .map(
                                          (item) => EJSelectorItem(
                                            value: item,
                                            widget: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 16),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 32),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    '${item['uniformNumber']}번',
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    item['playerName'],
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                } else {
                                  return InkWell(
                                    onTap: () {
                                      homeTeamPlayer
                                          .add(selectHomeTeamPlayer[count]);
                                      selectHomeTeamPlayer.removeWhere(
                                          (element) =>
                                              element.id ==
                                              selectHomeTeamPlayer[count].id);

                                      setState(() {});
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.blue, width: 3),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            selectHomeTeamPlayer[count]
                                                ['uniformNumber'],
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            selectHomeTeamPlayer[count]
                                                ['playerName'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              })),
                    )
                  ],
                ),
              ),
            ),
            Divider(height: 30),
            Flexible(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'AWAY TEAM',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium!
                          .copyWith(color: Colors.white),
                    ),
                    EJSelectorButton<QueryDocumentSnapshot>(
                      onChange: (e) async {
                        await teamAndPlayerController
                            .getTeamCrew(e)
                            .then((value) {
                          // awayTeamPlayer = value.docs;
                          selectAwayTeamPlayer = value.docs;
                          awayTeamPlayer.clear();
                          if (awayTeam != null) {
                            teams.removeWhere((element) => element.id == e.id);
                            teams.add(awayTeam!);
                          }else {
                            teams.removeWhere((element) => element.id == e.id);
                          }
                          awayTeam = e;
                          setState(() {});
                        });
                      },
                      useValue: false,
                      hint: Text(
                        '어웨이팀 선택',
                        style: textTheme.headlineSmall,
                      ),
                      buttonBuilder: (child, value) => Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.red.withOpacity(0.9),
                        ),
                        child: value != null
                            ? Text(
                                value['name'],
                                style: textTheme.headlineSmall,
                              )
                            : child,
                      ),
                      selectedWidgetBuilder: (valueOfSelected) => Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8)),
                        width: double.infinity,
                        child: Text(valueOfSelected['name'],
                            style: textTheme.headlineSmall),
                      ),
                      items: teams
                          .map(
                            (item) => EJSelectorItem(
                              value: item,
                              widget: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white54,
                                    borderRadius: BorderRadius.circular(8)),
                                width: double.infinity,
                                child: Text(
                                  item['name'],
                                  style: textTheme.headlineSmall,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: GridView.builder(
                              itemCount: selectAwayTeamPlayer.length + 1,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4),
                              itemBuilder: (cntx, count) {
                                if (count == selectAwayTeamPlayer.length) {
                                  return EJSelectorButton<
                                      QueryDocumentSnapshot>(
                                    onChange: (player) {
                                      awayTeamPlayer.removeWhere(
                                          (element) => element.id == player.id);
                                      selectAwayTeamPlayer.add(player);

                                      setState(() {});
                                    },
                                    buttonBuilder: (child, value) => Card(
                                      color: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            '추가',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    items: awayTeamPlayer
                                        .map(
                                          (item) => EJSelectorItem(
                                            value: item,
                                            widget: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 16),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 32),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    '${item['uniformNumber']}번',
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    item['playerName'],
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                } else {
                                  return InkWell(
                                    onTap: () {
                                      awayTeamPlayer
                                          .add(selectAwayTeamPlayer[count]);
                                      selectAwayTeamPlayer.removeWhere(
                                          (element) =>
                                              element.id ==
                                              selectAwayTeamPlayer[count].id);

                                      setState(() {});
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.red, width: 3),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            selectAwayTeamPlayer[count]
                                                ['uniformNumber'],
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            selectAwayTeamPlayer[count]
                                                ['playerName'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              })),
                    )
                  ],
                ),
              ),
            ),
            Divider(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.black),
              onPressed: () async {
                RecordController recordController =
                    Get.put(RecordController(), permanent: true);

                if (selectHomeTeamPlayer.isNotEmpty &
                    selectAwayTeamPlayer.isNotEmpty) {
                  Game game = Game(
                      leagueId: league.id,
                      homeTeam: homeTeam!,
                      awayTeam: awayTeam!,
                      homePlayer: selectHomeTeamPlayer,
                      awayPlayer: selectAwayTeamPlayer);

                  await recordController
                      .addGame(game)
                      .then((value) => recordController.addPlayerToGame())
                      .whenComplete(() {
                    Get.off(() => const RecorderScreen());
                  });
                } else {
                  Get.snackbar('선수 구성', '팀 및 선수 구성 완료 해주세요.',
                      duration: Duration(seconds: 1));
                }
              },
              child: selectHomeTeamPlayer.isNotEmpty &
                      selectAwayTeamPlayer.isNotEmpty
                  ? const Text(
                      '경기 시작',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    )
                  : const Text(
                      '선수 구성 먼저 하세요',
                      style: TextStyle(fontSize: 24),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
