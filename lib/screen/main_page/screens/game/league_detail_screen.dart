import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/game_query_controller.dart';
import 'package:ggangs_gym/get_controllers/league_controller.dart';
import 'package:ggangs_gym/screen/main_page/screens/game/game_detail_screen.dart';

class LeagueDetail extends StatefulWidget {
  const LeagueDetail({super.key});

  @override
  State<LeagueDetail> createState() => _LeagueDetailState();
}

class _LeagueDetailState extends State<LeagueDetail> {
  @override
  Widget build(BuildContext context) {
    LeagueController leagueController = Get.find<LeagueController>();

    ColorScheme colorScheme = Theme
        .of(context)
        .colorScheme;
    TextTheme textTheme = Theme
        .of(context)
        .textTheme;
    QueryDocumentSnapshot leagueDoc = leagueController.selectedLeague;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        title: SingleChildScrollView(
          child: Text(
            "${leagueController.selectedLeague['name']}",
            style: textTheme.titleLarge!.copyWith(
                color: colorScheme.onBackground, fontWeight: FontWeight.bold),
          ),
        ),
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
            child: FutureBuilder<QuerySnapshot>(
                future: leagueController.getGameList(leagueDoc),
                builder: (context, snapshot) {
                  if (snapshot.hasError ||
                      snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (BuildContext context, int count) {
                        String? id = snapshot.data?.docs[count].id;
                        String homeName =
                        snapshot.data?.docs[count]['homeTeamName'];
                        String awayName =
                        snapshot.data?.docs[count]['awayTeamName'];
                        String homeScore =
                        snapshot.data?.docs[count]['homeScore'];
                        String awayScore =
                        snapshot.data?.docs[count]['awayScore'];
                        Timestamp time = snapshot.data?.docs[count]['time'];
                        DateTime date = time.toDate();

                        return InkWell(
                          onTap: () async {
                          showDialog(context: context,
                                useSafeArea:false ,
                                builder: (c) =>
                                    Center(child: CircularProgressIndicator(),));
                            GameQuery gameQuery =
                            Get.put(GameQuery(), permanent: true);
                            await gameQuery
                                .setGame(snapshot.data!.docs[count])
                                .whenComplete(() async {
                              await Get.to(() => const GameDetail())
                                  ?.then((result) {
                                if (result ?? false) {
                                  Get.back();
                                }
                              });
                            });
                          if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            margin: EdgeInsets.all(8),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: SizedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "경기날짜 : ${date.year}년 ${date
                                              .month}월 ${date.day}일",
                                          style: TextStyle(
                                              color: colorScheme
                                                  .onPrimaryContainer),
                                        ),
                                        Text(
                                          "홈팀 : $homeName",
                                          style: TextStyle(
                                              color:
                                              Colors.blue.withOpacity(0.7)),
                                        ),
                                        Text(
                                          "어웨이팀 : $awayName",
                                          style: TextStyle(
                                              color:
                                              Colors.red.withOpacity(0.7)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: SizedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '$homeScore',
                                              style: TextStyle(fontSize: 24),
                                            ),
                                            decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.7)),
                                          ),
                                        ),
                                        Flexible(
                                            flex: 2,
                                            child: SizedBox(
                                              child: Text(
                                                ':',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )),
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '$awayScore',
                                              style: TextStyle(fontSize: 24),
                                            ),
                                            decoration: BoxDecoration(
                                                color: Colors.red
                                                    .withOpacity(0.7)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
          )
        ],
      ),
    );
  }
}
