import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ej_selector/ej_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/auth_controller.dart';
import 'package:ggangs_gym/get_controllers/team_player_controller.dart';
import 'package:ggangs_gym/models/player_model.dart';
import 'package:ggangs_gym/screen/main_page/screens/player/team_detail.dart';
import 'package:marquee/marquee.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TeamAndPlayerController teamAndPlayerController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            "Team & Player",
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
                        await addTeamDialog(context, colorScheme, textTheme)
                            .whenComplete(() {
                          setState(() {});
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          children: [
                            Icon(Icons.group_add,
                                color: colorScheme.onPrimaryContainer),
                            Text(
                              '팀 추가',
                              style: textTheme.labelMedium!.copyWith(
                                  color: colorScheme.onPrimaryContainer),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
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
                        await addPlayerDialog(context).whenComplete(() {
                          setState(() {});
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          children: [
                            Icon(Icons.person_add_alt_1,
                                color: colorScheme.onPrimaryContainer),
                            Text(
                              '선수 추가',
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
        Expanded(
          child: FutureBuilder(
              future: teamAndPlayerController.getTeams(),
              builder: (context, snapshot) {
                if (snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<QueryDocumentSnapshot> teamQueryDate =
                      snapshot.data?.docs ?? [];
                  return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemCount: teamQueryDate.length,
                      itemBuilder: (BuildContext ctx, int count) {
                        String teamName = teamQueryDate[count]['name'];
                        return InkWell(
                          onTap: () async {
                            QueryDocumentSnapshot teamDoc =
                                teamQueryDate[count];
                            await teamAndPlayerController
                                .getTeamCrew(teamDoc)
                                .then((QuerySnapshot queryData) async {
                              await Get.to(() => TeamDetail(
                                  teamDoc: teamDoc,
                                  players: queryData.docs))?.then((value) {
                                setState(() {});
                              });
                            });
                          },
                          onLongPress: () {
                            if (authController.isLogin() ?? false) {
                              Get.dialog(AlertDialog(
                                content: Text('정말 삭제 하시겠습니까',
                                    style: TextStyle(color: Colors.white)),
                                actions: [
                                  TextSelectionToolbarTextButton(
                                    child: Text(
                                      '취소',
                                    ),
                                    padding: EdgeInsets.all(1),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                  TextSelectionToolbarTextButton(
                                    child: Text('확인'),
                                    padding: EdgeInsets.all(1),
                                    onPressed: () async {
                                      await teamAndPlayerController
                                          .deletedTeam(teamQueryDate[count])
                                          .whenComplete(() {
                                        setState(() {});
                                      });
                                    },
                                  )
                                ],
                              ));
                            }
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
                                      child: teamName.length > 6
                                          ? Marquee(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              blankSpace: 30,
                                              pauseAfterRound:
                                                  const Duration(seconds: 1),
                                              text: teamName,
                                              style: textTheme.bodyMedium!
                                                  .copyWith(
                                                      color: colorScheme
                                                          .onPrimaryContainer),
                                            )
                                          : Text(
                                              teamName,
                                              style: textTheme.bodyMedium!
                                                  .copyWith(
                                                      color: colorScheme
                                                          .onPrimaryContainer),
                                            ),
                                    ),
                                  ),
                                  Flexible(
                                    child: FutureBuilder(
                                        future: teamQueryDate[count]
                                            .reference
                                            .collection('crew')
                                            .get(),
                                        builder: (context, crewSnapshot) {
                                          if (crewSnapshot.hasError ||
                                              crewSnapshot.connectionState ==
                                                  ConnectionState.waiting ||
                                              crewSnapshot.connectionState ==
                                                  ConnectionState.active) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else {
                                            return Text(
                                              '${crewSnapshot.data!.docs.length}명',
                                              style: textTheme.bodyLarge!
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
}

Future<void> addTeamDialog(
    BuildContext context, ColorScheme colorScheme, TextTheme textTheme) async {
  TeamAndPlayerController teamAndPlayerController = Get.find();
  TextEditingController teamNameTextController = TextEditingController();
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.onPrimaryContainer,
          actions: [
            ElevatedButton(
                onPressed: () {
                  if (teamNameTextController.text.isNotEmpty) {
                    teamAndPlayerController
                        .addTeam(teamNameTextController.text)
                        .whenComplete(() => Get.back(result: true));
                  } else {
                    Get.snackbar('오류', '팀 이름을 입력하세요',
                        duration: Duration(milliseconds: 1000));
                  }
                },
                child: const Text('추가')),
            ElevatedButton(
                onPressed: () {
                  Get.back(result: false);
                },
                child: const Text('취소'))
          ],
          title: Text('팀 추가', style: textTheme.bodyLarge),
          content: TextFormField(
            controller: teamNameTextController,
            decoration: const InputDecoration(hintText: "팀 이름 입력"),
          ),
        );
      });
}

Future<void> addPlayerDialog(BuildContext context) async {
  int number = 10;
  TextTheme textTheme = context.textTheme;
  ColorScheme colorScheme = context.theme.colorScheme;
  TeamAndPlayerController teamAndPlayerController = Get.find();

  String? selectedTeamId = '';

  List<TextEditingController> nameControllers = List.generate(number, (index) {
    return TextEditingController(text: '');
  });
  List<TextEditingController> numberControllers =
      List.generate(number, (index) {
    return TextEditingController(text: '');
  });
  List<Row> rows = List.generate(
      number,
      (index) =>
          buildTextInput(nameControllers[index], numberControllers[index]));

  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.onPrimaryContainer,
          actions: [
            ElevatedButton(
                onPressed: () async {
                  List<Player> players = [];
                  for (int i = 0; i < number; i++) {
                    bool teamValid = selectedTeamId?.isNotEmpty ?? false;
                    String name = nameControllers[i].text.toString().trim();
                    String number = numberControllers[i].text.toString().trim();

                    if (name.isNotEmpty && number.isNotEmpty && teamValid) {
                      players.add(Player(
                          teamID: selectedTeamId!,
                          number: number,
                          name: name,
                          img: ''));
                    }
                  }
                  if (players.isEmpty) {
                    Get.snackbar('등록 오류', '팀 선택 및 이름, 등번호 확인',
                        duration: const Duration(milliseconds: 1000));
                  } else {
                    await teamAndPlayerController
                        .addPlayer(players)
                        .then((value) => Get.back());
                  }
                },
                child: const Text('추가')),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('취소'))
          ],
          title: Text('선수 추가', style: textTheme.bodyLarge),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EJSelectorButton<QueryDocumentSnapshot>(
                  onChange: (QueryDocumentSnapshot val) {
                    selectedTeamId = val.id;
                  },
                  useValue: false,
                  hint: const Text(
                    '팀 선택',
                    style: TextStyle(fontSize: 16, color: Colors.white54),
                  ),
                  buttonBuilder: (child, value) => Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
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
                  items: teamAndPlayerController.teamList
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
                SingleChildScrollView(
                  child: Column(
                    children: rows,
                  ),
                )
              ],
            ),
          ),
        );
      });
}

Row buildTextInput(TextEditingController nameController,
    TextEditingController numberController) {
  return Row(
    children: [
      Flexible(
        child: TextFormField(
          controller: nameController,
          autovalidateMode: AutovalidateMode.always,
          decoration: const InputDecoration(hintText: "선수 이름"),
          validator: (e) {
            if (e?.isEmpty ?? true) {
              return '이름은 필수 입니다.';
            }

            return null;
          },
        ),
      ),
      Flexible(
        child: TextFormField(
          autovalidateMode: AutovalidateMode.always,
          validator: (e) {
            if (e?.isEmpty ?? true) {
              return '등 번호는 필수 입니다.';
            }

            return null;
          },
          controller: numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "등 번호"),
        ),
      ),
    ],
  );
}
