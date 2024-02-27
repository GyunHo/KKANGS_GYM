import 'dart:typed_data';
import 'package:ggangs_gym/get_controllers/auth_controller.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/game_query_controller.dart';
import 'package:ggangs_gym/get_controllers/record_controller.dart';
import 'package:ggangs_gym/screen/main_page/screens/game/game_record/recorder_screen.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/services.dart';

const TextStyle textStyle = TextStyle(color: Colors.white);
const TextStyle textStyleSubItems = TextStyle(color: Colors.grey);

class GameDetail extends StatefulWidget {
  const GameDetail({super.key});

  @override
  State<GameDetail> createState() => _GameDetailState();
}

class _GameDetailState extends State<GameDetail> {
  late GameQuery gameQuery;
  ScreenshotController screenshotController = ScreenshotController();
  bool showDetail = true;

  @override
  void initState() {
    super.initState();
    gameQuery = Get.find();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Get.delete<GameQuery>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double mainCellHeight = height * 0.1;
    double totalRowHeight = mainCellHeight * 0.6;

    List<Row> buildRows(Map<String, Map<String, Map<String, int>>> record,
        List<QueryDocumentSnapshot> players, String teamName, Color color) {
      List<String> subHead = [
        '1Q',
        '2Q',
        '3Q',
        '4Q',
        'EX',
      ];
      List<String> head = [
        '1Q',
        '2Q',
        '3Q',
        '4Q',
        'EX',
        '총득점',
        '리바운드',
        '어시스트',
        '파울'
      ];
      List<Row> rows = [];
      double cellWidth = showDetail
          ? width * 0.9 / (head.length + 1)
          : width * 0.9 / (head.length + 1 - subHead.length);

      ///헤더 생성
      List<Widget> headerRow = [
        _buildCell(teamName, cellWidth, mainCellHeight, color)
      ];

      headerRow.addAll(head.map((String header) {
        if (showDetail) {
          return _buildCell(subHead.contains(header) ? '$header득점' : header,
              cellWidth, mainCellHeight, color);
        } else {
          return subHead.contains(header)
              ? const SizedBox()
              : _buildCell(header, cellWidth, mainCellHeight, color);
        }
      }).toList());
      rows.add(Row(children: headerRow));

      ///각 선수별로..
      for (QueryDocumentSnapshot player in players) {
        /// 선수의 id로 record에서 선수기록 Map을 추출하고
        Map<String, Map<String, int>> playerRecords = record[player.id]!;

        ///선수 총합 계산
        Map<String, int> playerTotal =
            gameQuery.calcHeaderTotal(playerRecords, gameQuery.headers);

        int playerPointTotal = playerTotal['1점']! +
            playerTotal['2점']! * 2 +
            playerTotal['3점']! * 3;
        playerTotal['총득점'] = playerPointTotal;

        ///쿼터별 총 점수
        Map<String, int> playerQuarterPointTotal =
            gameQuery.calcQuarterPointTotal(playerRecords);

        ///선수 총합 로우 추가
        List<Widget> playerTotalRow = [
          _buildCell('${player['playerName']} / ${player['uniformNumber']}', cellWidth, totalRowHeight,
              Colors.white.withOpacity(0.8))
        ];

        playerTotalRow.addAll(head.map((String header) {
          if (showDetail) {
            return subHead.contains(header)
                ? _buildCell('${playerQuarterPointTotal[header]}', cellWidth,
                    totalRowHeight, Colors.white.withOpacity(0.8))
                : _buildCell('${playerTotal[header]}', cellWidth,
                    totalRowHeight, Colors.white.withOpacity(0.8));
          } else {
            return subHead.contains(header)
                ? const SizedBox()
                : _buildCell('${playerTotal[header]}', cellWidth,
                    totalRowHeight, Colors.white.withOpacity(0.8));
          }
        }).toList());
        rows.add(Row(children: playerTotalRow));
      }

      ///팀 전체 기록 로우
      Map<String, Map<String, int>> teamRecord = teamName == "홈"
          ? gameQuery.eachTeamRecords[gameQuery.getGameDoc['homeTeamId']]!
          : gameQuery.eachTeamRecords[gameQuery.getGameDoc['awayTeamId']]!;
      int timeOut_1 = teamRecord['1Q']!['작전타임']!;
      int timeOut_2 = teamRecord['2Q']!['작전타임']!;
      int timeOut_3 = teamRecord['3Q']!['작전타임']!;
      int timeOut_4 = teamRecord['4Q']!['작전타임']!;
      Map<String, int> teamTotal =
          gameQuery.calcHeaderTotal(teamRecord, gameQuery.teamHeaders);

      int teamPointTotal =
          teamTotal['1점']! + teamTotal['2점']! * 2 + teamTotal['3점']! * 3;
      teamTotal['총득점'] = teamPointTotal;
      Map<String, int> teamQuarterPointTotal =
          gameQuery.calcQuarterPointTotal(teamRecord);

      List<Widget> teamTotalRow = [
        _buildCell('팀 기록', cellWidth, mainCellHeight, Colors.white)
      ];
      teamTotalRow.addAll(head.map((String header) {
        if (showDetail) {
          return subHead.contains(header)
              ? _buildCell('${teamQuarterPointTotal[header]}', cellWidth,
                  mainCellHeight, Colors.white)
              : _buildCell('${teamTotal[header]}', cellWidth, mainCellHeight,
                  Colors.white);
        } else {
          return subHead.contains(header)
              ? const SizedBox()
              : _buildCell('${teamTotal[header]}', cellWidth, mainCellHeight,
                  Colors.white);
        }
      }).toList());
      rows.add(Row(
        children: teamTotalRow,
      ));
      rows.add(Row(children: [Text('작전타임 - 전반 ${timeOut_1+timeOut_2} / 후반 ${timeOut_3+timeOut_4}',style: TextStyle(color: color,fontSize: 16),)]));

      return rows;
    }

    List<Widget> rows = [];

    List<Row> homeRow = buildRows(gameQuery.homePlayerRecords,
        gameQuery.homePlayers, '홈', Colors.lightBlue);
    List<Row> awayRow = buildRows(gameQuery.awayPlayerRecords,
        gameQuery.awayPlayers, '어웨이', Colors.redAccent);
    rows.add(Text(
      '${gameQuery.getGameDoc['homeTeamName']}',
      style: const TextStyle(fontSize: 30, color: Colors.blue),
    ));

    rows.addAll(homeRow);
    rows.add(Text(
      '${gameQuery.getGameDoc['awayTeamName']}',
      style: const TextStyle(fontSize: 30, color: Colors.red),
    ));

    rows.addAll(awayRow);

    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    showDetail = !showDetail;
                  });
                },
                child: Text(showDetail ? "간단히" : '자세히')),
            TextButton(
                onPressed: () async {
                  await screenshotController
                      .capture(delay: const Duration(milliseconds: 10))
                      .then((Uint8List? image) async {
                    if (image != null) {
                      final result = await ImageGallerySaver.saveImage(image,
                          name: 'kkangs-gym-result${DateTime.now()}',
                          quality: 100);
                      if (result['isSuccess']) {
                        Get.snackbar('성공', '스크린샷 저장완료');
                      }
                    }
                  });
                },
                child: const Text('스샷')),
            authController.isLogin() ?? false
                ? TextButton(
                    onPressed: () async {
                      await Get.dialog(AlertDialog(
                        content: const Text('기록을 삭제 하시겠습니까?',
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: const Text('취소')),
                          TextButton(
                              onPressed: () async {
                                await gameQuery
                                    .deleteGame()
                                    .then((value) => Get.back(result: true));
                              },
                              child: const Text('확인'))
                        ],
                      )).then((value) {
                        if (value ?? false) {
                          Get.back(result: true);
                        }
                      });
                    },
                    child: const Text('삭제'),
                  )
                : const SizedBox(),
            authController.isLogin() ?? false
                ? TextButton(
                    onPressed: () async {
                      showDialog(context: context, builder: (c)=>Center(child: CircularProgressIndicator(),));
                      RecordController recordController =
                          Get.put(RecordController(), permanent: true);
                      await recordController
                          .loadGame(gameQuery.getGameDoc)
                          .then((value) async {
                        await Get.to(() => const RecorderScreen())
                            ?.then((value) {
                          Get.back(result: true);
                        });
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('수정'),
                  )
                : const SizedBox()
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Screenshot(
              controller: screenshotController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: rows,
              ),
            ),
          ),
        ));
  }

  Container _buildCell(
      String content, double width, double height, Color color) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        content,
        style: TextStyle(fontSize: 12),
      ),
      width: width,
      height: height,
      margin: EdgeInsets.all(1),
      color: color,
    );
  }
}
