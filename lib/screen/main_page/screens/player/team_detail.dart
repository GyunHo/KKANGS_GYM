import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/auth_controller.dart';
import 'package:ggangs_gym/get_controllers/team_player_controller.dart';

class TeamDetail extends StatefulWidget {
  final QueryDocumentSnapshot teamDoc;
  final List<QueryDocumentSnapshot> players;

  const TeamDetail({super.key, required this.teamDoc, required this.players});

  @override
  State<TeamDetail> createState() => _TeamDetailState();
}

class _TeamDetailState extends State<TeamDetail> {
  @override
  Widget build(BuildContext context) {
    QueryDocumentSnapshot teamDoc = widget.teamDoc;
    List<QueryDocumentSnapshot> players = widget.players;
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AuthController authController = Get.find();
    TeamAndPlayerController teamAndPlayerController = Get.find();
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: Text(
          '${teamDoc['name']}',
          style: textTheme.titleLarge!.copyWith(
              color: colorScheme.onBackground, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 8,
          ),
          Divider(
            height: 12,
            color: colorScheme.outlineVariant,
          ),
          Flexible(
              child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (BuildContext ctx, int count) {
                    return Card(
                        child: ListTile(
                      trailing: authController.isLogin()
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      buildEditPlayer();
                                    },
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                  onPressed: () async {
                                    Get.defaultDialog(
                                      title: '선수 삭제 경고',
                                      titleStyle:
                                          const TextStyle(color: Colors.red),
                                      textCancel: '취소',
                                      content: const Text('누적기록이 전부 삭제됩니다.',
                                          style: TextStyle(color: Colors.red)),
                                      onConfirm: () async {
                                        Get.back();
                                        await teamAndPlayerController
                                            .deletedPlayer(players[count])
                                            .then((value) {
                                          setState(() {
                                            players.removeAt(count);
                                          });
                                        });
                                      },
                                      textConfirm: "삭제",
                                    );
                                  },
                                  icon: const Icon(Icons.delete_forever),
                                ),
                              ],
                            )
                          : null,
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이름 : ${players[count]['playerName']}',
                            ),
                            Text(
                              '번호 : ${players[count]['uniformNumber']}',
                            )
                          ],
                        ),
                      ),
                    ));
                  }))
        ],
      ),
    );
  }

  Future<dynamic> buildEditPlayer() {
    TextEditingController name = TextEditingController();
    TextEditingController number = TextEditingController();
    return Get.defaultDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(hintText: "이름"),
            ),
            TextField(
              controller: number,
              decoration: const InputDecoration(hintText: '번호'),
            ),
          ],
        ),
      ),
      title: "선수 수정",
      backgroundColor: Colors.green.withOpacity(0.6),
      titleStyle: TextStyle(color: Colors.white),
      textConfirm: "수정",
      textCancel: "취소",
      onConfirm: () {
        Get.back();
      },
    );
  }
}
