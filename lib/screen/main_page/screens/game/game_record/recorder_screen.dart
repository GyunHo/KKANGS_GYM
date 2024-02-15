import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/record_controller.dart';
import 'package:ggangs_gym/models/record_model.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  RecordController? recordController;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    recordController = Get.find<RecordController>();
    recordController?.quarter ?? 1;
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<RecordController>(force: true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await recordController!.addScoreToGame().then((value) {
                Get.back(result: true);
              });
              // showDialog(
              //     context: context,
              //     builder: (context) {
              //       return AlertDialog(
              //         actions: [
              //           ElevatedButton(
              //               onPressed: () {
              //                 Get.back();
              //               },
              //               child: const Text('취소')),
              //           ElevatedButton(
              //               onPressed: () {
              //                 Get.offAll(() => const MainPage());
              //               },
              //               child: const Text('확인'))
              //         ],
              //         content: const Text(
              //           '저장 하지 않고 나갑니다',
              //           style: TextStyle(color: Colors.white),
              //         ),
              //       );
              //     });
            },
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await recordController!.addScoreToGame().then((value) {
                    Get.back(result: true);
                  });
                },
                icon: Icon(Icons.save))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: recordController!.recordStream(),
            builder: (streamContext, snapshot) {
              if (snapshot.hasError ||
                  snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.none) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                List<QueryDocumentSnapshot> recordList =
                    snapshot.data?.docs ?? [];
                List<QueryDocumentSnapshot> homeRecord = recordController!
                    .getTeamRecords(
                        recordList, recordController!.homeTeamDoc.id);
                List<QueryDocumentSnapshot> awayRecord = recordController!
                    .getTeamRecords(
                        recordList, recordController!.awayTeamDoc.id);
                Map<String, int> homeFoul =
                    recordController!.calcEachQuarterFoul(homeRecord);
                Map<String, int> awayFoul =
                    recordController!.calcEachQuarterFoul(awayRecord);
                String homePoint = recordController!.calcPoint(homeRecord);
                String awayPoint = recordController!.calcPoint(awayRecord);
                recordController!.homeScore = homePoint;
                recordController!.awayScore = awayPoint;
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 6,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'HOME : ${recordController?.homeTeamDoc['name']}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white70),
                              ),
                              Flexible(
                                child: GridView.builder(
                                  itemCount:
                                      recordController!.homeTeamPlayer.length +
                                          1,
                                  physics: BouncingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5),
                                  itemBuilder: (ctx, count) {
                                    if (recordController!
                                                .homeTeamPlayer.length +
                                            1 ==
                                        count + 1) {
                                      return Card(
                                        color: Colors.red.withOpacity(0.1),
                                        child: IconButton(
                                          icon: const Icon(Icons.add),
                                          color: Colors.white,
                                          onPressed: () async {
                                            await buildInGamePlayerAddDialog(
                                                    context, 'home')
                                                .then((value) {
                                              if (value ?? false) {
                                                setState(() {});
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    } else {
                                      Recording recording = Recording(
                                          playerid: recordController!
                                              .homeTeamPlayer[count].id,
                                          playerteamid: recordController!
                                              .homeTeamPlayer[count]['teamId'],
                                          gameid: recordController!.gameId!,
                                          leagueid: recordController!.leagueId!,
                                          recordtype: '',
                                          qt: recordController!
                                              .quarterToString());
                                      return buildFocusedMenuHolder(
                                          streamContext,
                                          recording,
                                          recordController!
                                              .homeTeamPlayer[count],
                                          recordList);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 5,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      child: Text('HOME'),
                                      decoration:
                                          BoxDecoration(color: Colors.red),
                                      alignment: Alignment.center,
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: buildHistory(homeRecord,
                                          recordController!.homeTeamPlayer),
                                    ),
                                    Flexible(
                                        flex: 2,
                                        child: InkWell(
                                            onTap: () {
                                              Recording recording = Recording(
                                                  playerid: '',
                                                  playerteamid:
                                                      recordController!
                                                          .homeTeamDoc.id,
                                                  gameid:
                                                      recordController!.gameId!,
                                                  leagueid: recordController!
                                                      .leagueId!,
                                                  recordtype: '작전타임',
                                                  qt: recordController!
                                                      .quarterToString());
                                              recordController!
                                                  .recording(recording);
                                            },
                                            child: buildTimeout(
                                                'home',
                                                recordController!
                                                    .calcEachQuarterTimeout(
                                                        homeRecord))))
                                  ],
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 4,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Flexible(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [1, 2, 3, 4, 5].map((q) {
                                              String quarter =
                                                  q == 5 ? "EX" : '${q}Q';

                                              return Flexible(
                                                child: InkWell(
                                                  onTap: () {
                                                    recordController!.quarter =
                                                        q;
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              Colors.redAccent),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: recordController!
                                                                  .quarter ==
                                                              q
                                                          ? Colors.white
                                                          : Colors.white12,
                                                    ),
                                                    padding: EdgeInsets.all(4),
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: Text(
                                                      quarter,
                                                      style: TextStyle(
                                                          color: recordController!
                                                                      .quarter ==
                                                                  q
                                                              ? Colors.black
                                                              : Colors.white54),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList()),
                                      ),
                                      Flexible(
                                          child: Text(
                                        '$homePoint : $awayPoint',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          color: Colors.white,
                                        ),
                                      )),
                                      Flexible(
                                          child: Column(
                                        children: [
                                          Text(
                                            '${recordController?.quarterToString()} 팀 파울',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.redAccent),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              ///홈팀파울
                                              Text(
                                                '${homeFoul[recordController?.quarterToString()] ?? 0}',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),

                                              ///어웨이팀 파울
                                              Text(
                                                '${awayFoul[recordController?.quarterToString()] ?? 0}',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              )
                                            ],
                                          )
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      child: Text('AWAY'),
                                      decoration: BoxDecoration(
                                          color: Colors.blueAccent),
                                      alignment: Alignment.center,
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: buildHistory(awayRecord,
                                          recordController!.awayTeamPlayer),
                                    ),
                                    Flexible(
                                        flex: 2,
                                        child: InkWell(
                                            onTap: () {
                                              Recording recording = Recording(
                                                  playerid: '',
                                                  playerteamid:
                                                      recordController!
                                                          .awayTeamDoc.id,
                                                  gameid:
                                                      recordController!.gameId!,
                                                  leagueid: recordController!
                                                      .leagueId!,
                                                  recordtype: '작전타임',
                                                  qt: recordController!
                                                      .quarterToString());
                                              recordController!
                                                  .recording(recording);
                                            },
                                            child: buildTimeout(
                                                'away',
                                                recordController!
                                                    .calcEachQuarterTimeout(
                                                        awayRecord))))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'AWAY : ${recordController?.awayTeamDoc['name']}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white70),
                              ),
                              Flexible(
                                child: GridView.builder(
                                  itemCount:
                                      recordController!.awayTeamPlayer.length +
                                          1,
                                  physics: BouncingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5),
                                  itemBuilder: (ctx, count) {
                                    if (recordController!
                                                .awayTeamPlayer.length +
                                            1 ==
                                        count + 1) {
                                      return Card(
                                        color: Colors.blue.withOpacity(0.1),
                                        child: IconButton(
                                          icon: Icon(Icons.add),
                                          color: Colors.white,
                                          onPressed: () async {
                                            await buildInGamePlayerAddDialog(
                                                    context, 'away')
                                                .then((value) {
                                              if (value ?? false) {
                                                setState(() {});
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    } else {
                                      Recording recording = Recording(
                                          playerid: recordController!
                                              .awayTeamPlayer[count].id,
                                          playerteamid: recordController!
                                              .awayTeamPlayer[count]['teamId'],
                                          gameid: recordController!.gameId!,
                                          leagueid: recordController!.leagueId!,
                                          recordtype: '',
                                          qt: recordController!
                                              .quarterToString());
                                      return buildFocusedMenuHolder(
                                          streamContext,
                                          recording,
                                          recordController!
                                              .awayTeamPlayer[count],
                                          recordList);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  Future buildInGamePlayerAddDialog(
      BuildContext context, String witchTeam) async {
    List<QueryDocumentSnapshot> remainingPlayer =
        await recordController!.getRemainingPlayer(witchTeam);
    if (!mounted) return;

    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                child: remainingPlayer.isEmpty
                    ? const Center(
                        child: Text(
                          '추가 할수 있는 팀원 없음',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: remainingPlayer.length,
                        itemBuilder: (ctx, count) {
                          QueryDocumentSnapshot player = remainingPlayer[count];
                          return Card(
                            color: Colors.white.withOpacity(0.7),
                            child: ListTile(
                              onTap: () {
                                recordController!
                                    .playingGameAddPlayer(player, witchTeam);
                                Get.back(result: true);
                              },
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '이름 : ${player['playerName']}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    '번호: ${player['uniformNumber']}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
              ),
            ));
  }

  Container buildTimeout(String witchTeam, Map<String, int> data) {
    int one = data['1Q'] ?? 0;
    int two = data['2Q'] ?? 0;
    int three = data['3Q'] ?? 0;
    int four = data['4Q'] ?? 0;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: witchTeam == 'home'
              ? Colors.red.withOpacity(0.7)
              : Colors.blueAccent.withOpacity(0.9)),
      child: Column(
        children: [
          const Text(
            '작전타임',
            style: TextStyle(fontSize: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white),
                    child: Column(
                      children: [
                        const Text(
                          '전반',
                          style: TextStyle(fontSize: 10),
                          overflow: TextOverflow.fade,
                        ),
                        Text(
                          '${one + two}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ),
              Flexible(
                child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white),
                    child: Column(
                      children: [
                        const Text(
                          '후반',
                          style: TextStyle(fontSize: 10),
                          overflow: TextOverflow.fade,
                        ),
                        Text(
                          '${three + four}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  Container buildHistory(List<QueryDocumentSnapshot<Object?>> records,
      List<QueryDocumentSnapshot> teamPlayer) {
    return Container(
      child: ListView.builder(
          itemExtent: 36,
          itemCount: records.length,
          itemBuilder: (BuildContext context, int count) {
            String recordType = records[count]['recordType'];
            String playerId = records[count]['playerID'];
            String uniformNumber = '';
            for (QueryDocumentSnapshot player in teamPlayer) {
              if (player.id == playerId) {
                uniformNumber = '${player['uniformNumber']}번';
              }
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4), color: Colors.white),
              child: Row(
                children: [
                  Text(
                    '$uniformNumber $recordType',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.fade,
                  ),
                  Flexible(
                      child: IconButton(
                          iconSize: 12,
                          onPressed: () async {
                            final canVibrate = await Haptics.canVibrate();
                            if (canVibrate) {
                              await Haptics.vibrate(HapticsType.medium);
                            }
                            recordController?.deleteRecord(records[count]);
                          },
                          icon: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.red,
                          )))
                ],
              ),
            );
          }),
    );
  }

  FocusedMenuHolder buildFocusedMenuHolder(
      BuildContext context,
      Recording recording,
      QueryDocumentSnapshot player,
      List<QueryDocumentSnapshot> recordList) {
    List fouls = recordList.where((rec) {
      if (rec['playerID'] == player.id && rec['recordType'] == '파울') {
        return true;
      } else {
        return false;
      }
    }).toList();
    return FocusedMenuHolder(
      menuWidth: MediaQuery.of(context).size.width * 0.3,
      blurSize: 5.0,
      menuBoxDecoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      // duration: Duration(milliseconds: 100),
      animateMenuItems: true,
      blurBackgroundColor: Colors.black12.withOpacity(0.6),
      openWithTap: true,
      menuItems: <FocusedMenuItem>[
        FocusedMenuItem(
            title: Text("1점"),
            trailingIcon: Icon(Icons.open_in_new),
            onPressed: () {
              recording.recordType = '1점';
              recordController!.recording(recording);
            }),
        FocusedMenuItem(
            title: Text("2점"),
            trailingIcon: Icon(Icons.open_in_new),
            onPressed: () {
              recording.recordType = '2점';
              recordController!.recording(recording);
            }),
        FocusedMenuItem(
            title: Text("3점"),
            trailingIcon: Icon(Icons.open_in_new),
            onPressed: () {
              recording.recordType = '3점';
              recordController!.recording(recording);
            }),
        FocusedMenuItem(
            title: Text("리바운드"),
            trailingIcon: Icon(Icons.share),
            onPressed: () {
              recording.recordType = '리바운드';
              recordController!.recording(recording);
            }),
        FocusedMenuItem(
            title: Text("파울"),
            trailingIcon: Icon(Icons.favorite_border),
            onPressed: () {
              recording.recordType = '파울';
              recordController!.recording(recording);
            }),
        FocusedMenuItem(
            title: Text("어시스트"),
            trailingIcon: Icon(Icons.favorite_border),
            onPressed: () {
              recording.recordType = '어시스트';
              recordController!.recording(recording);
            }),
      ],
      onPressed: () {},
      child: Card(
        color: Colors.white.withOpacity(0.8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(player['uniformNumber']),
            Text(player['playerName']),
            Text(
              '파울:${fouls.length}',
              style: TextStyle(
                  fontSize: 12,
                  color: fouls.length > 4 ? Colors.red : Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
