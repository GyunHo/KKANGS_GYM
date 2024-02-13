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
          '${teamDoc['name']} 팀',
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
                      trailing: authController.isLogin() ?? false
                          ? IconButton(
                              onPressed: () async {
                                await teamAndPlayerController
                                    .deletedPlayer(players[count])
                                    .then((value) {
                                  setState(() {
                                    players.removeAt(count);
                                  });
                                });
                              },
                              icon: Icon(Icons.delete_forever),
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
}
