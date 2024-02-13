import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ej_selector/ej_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/auth_controller.dart';
import 'package:ggangs_gym/get_controllers/league_controller.dart';
import 'package:ggangs_gym/screen/main_page/screens/game/league_detail_screen.dart';
import 'game_record/recorde_setting_screen.dart';
import 'package:marquee/marquee.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    LeagueController leagueController = Get.put(LeagueController());
    AuthController authController = Get.find();

    addLeagueDialog() async {
      TextEditingController leagueNameTextController = TextEditingController();
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: colorScheme.onPrimaryContainer,
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (leagueNameTextController.text.isNotEmpty) {
                        leagueController
                            .addLeague(leagueNameTextController.text);
                      } else {
                        Get.snackbar('오류', '리그명을 입력하세요',
                            duration: Duration(milliseconds: 1000));
                      }
                    },
                    child: const Text('추가')),
                ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('취소'))
              ],
              title: Text('리그 추가', style: textTheme.bodyLarge),
              content: TextFormField(
                controller: leagueNameTextController,
                decoration: const InputDecoration(hintText: "리그 이름 입력"),
              ),
            );
          });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            "League & Game",
            style: textTheme.headlineMedium!.copyWith(
                color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        authController.isLogin() ?? false
            ? Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(8.0),
                          shadowColor:
                              MaterialStateProperty.all(colorScheme.shadow),
                          backgroundColor: MaterialStateProperty.all(
                              colorScheme.primaryContainer),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)))),
                      onPressed: () async {
                        await addLeagueDialog().then((value) {
                          setState(() {});
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          children: [
                            Icon(Icons.stadium_outlined,
                                color: colorScheme.onPrimaryContainer),
                            Text(
                              '리그 추가',
                              style: textTheme.labelMedium!.copyWith(
                                  color: colorScheme.onPrimaryContainer),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(8.0),
                          shadowColor:
                              MaterialStateProperty.all(colorScheme.shadow),
                          backgroundColor: MaterialStateProperty.all(
                              colorScheme.primaryContainer),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)))),
                      onPressed: () async {
                        await Get.dialog(addGameDialog(textTheme, colorScheme))
                            .then((value) {
                          setState(() {});
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          children: [
                            Icon(Icons.edit_calendar_sharp,
                                color: colorScheme.onPrimaryContainer),
                            Text(
                              '경기 기록기',
                              style: textTheme.labelMedium!.copyWith(
                                  color: colorScheme.onPrimaryContainer),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(),
        Divider(
          height: 36,
          color: colorScheme.outlineVariant,
        ),
        Flexible(
          child: FutureBuilder<QuerySnapshot>(
              future: leagueController.getLeagues(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<QueryDocumentSnapshot> leagueQueryData =
                      snapshot.data?.docs ?? [];
                  return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemCount: leagueQueryData.length,
                      itemBuilder: (BuildContext ctx, int count) {
                        return InkWell(
                          onLongPress: () {
                            if (authController.isLogin() ?? false) {
                              Get.dialog(AlertDialog(
                                content: const Text('정말 삭제 하시겠습니까',
                                    style: TextStyle(color: Colors.white)),
                                actions: [
                                  TextSelectionToolbarTextButton(
                                    padding: EdgeInsets.all(1),
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text(
                                      '취소',
                                    ),
                                  ),
                                  TextSelectionToolbarTextButton(
                                    padding: EdgeInsets.all(1),
                                    onPressed: () {
                                      leagueController
                                          .deletedLeague(leagueQueryData[count])
                                          .then((value) {
                                        Get.back();
                                      }).whenComplete(() => setState(() {}));
                                    },
                                    child: const Text('확인'),
                                  )
                                ],
                              ));
                            }
                          },
                          splashColor: colorScheme.onPrimaryContainer,
                          onTap: () async {
                            leagueController.selectedLeague =
                                leagueQueryData[count];
                            await Get.to(
                              () => const LeagueDetail(),
                            )?.then((value) {
                              setState(() {});
                            });
                          },
                          child: Card(
                            elevation: 16.0,
                            color: colorScheme.primaryContainer,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Marquee(

                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        blankSpace: 20,
                                        pauseAfterRound: const Duration(seconds: 1),

                                        text: leagueQueryData[count]['name'] ??
                                            '알수없음'.toString(),
                                            style: textTheme.bodyMedium!.copyWith(
                                                color:
                                                    colorScheme.onPrimaryContainer),


                                      ),
                                    ),
                                  ),

                                  Flexible(
                                    child: FutureBuilder<QuerySnapshot?>(
                                        future: leagueController.getGameList(
                                            leagueQueryData[count]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                                  ConnectionState.waiting ||
                                              snapshot.connectionState ==
                                                  ConnectionState.active) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else {
                                            return Text(
                                              '${snapshot.data?.docs.length}경기',
                                              style: textTheme.bodyMedium!
                                                  .copyWith(
                                                      color: colorScheme
                                                          .onPrimaryContainer),
                                            );
                                          }
                                        }),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }
              }),
        )
      ],
    );
  }

  AlertDialog addGameDialog(TextTheme textTheme, ColorScheme colorScheme) {
    LeagueController leagueController = Get.find();
    QueryDocumentSnapshot? selectedLeague;
    return AlertDialog(
      backgroundColor: colorScheme.primary,
      actions: [
        ElevatedButton(
            onPressed: () {
              if (selectedLeague != null) {
                Get.off(() => RecordSettingScreen(),
                    arguments: [selectedLeague]);
              } else {
                Get.snackbar('확인', '기록할 리그를 선택 하세요.',
                    duration: const Duration(seconds: 1));
                {}
              }
            },
            child: Text('확인')),
        ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('취소')),
      ],
      content: EJSelectorButton<QueryDocumentSnapshot>(
        useValue: false,
        onChange: (QueryDocumentSnapshot league) {
          selectedLeague = league;
        },
        hint: const Text(
          '리그 선택',
          style: TextStyle(fontSize: 16, color: Colors.white54),
        ),
        buttonBuilder: (child, value) => Container(
          alignment: Alignment.center,
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.primaryContainer),
          child: value != null
              ? Text(
                  value['name'],
                  style: TextStyle(fontSize: 24, color: Colors.white),
                )
              : child,
        ),
        selectedWidgetBuilder: (valueOfSelected) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8)),
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(8),
            child: Text(
              valueOfSelected['name'],
              style: textTheme.headlineLarge,
            ),
          );
        },
        items: leagueController.leagueList
            .map(
              (item) => EJSelectorItem(
                value: item,
                widget: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(8)),
                  width: double.infinity,
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(4),
                  child: Text(
                    item['name'],
                    style: textTheme.headlineSmall,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
