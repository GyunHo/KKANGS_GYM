import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ggangs_gym/screen/main_page/screens/game/game_screen.dart';
import 'package:ggangs_gym/screen/main_page/screens/home/home_screen.dart';
import 'package:ggangs_gym/screen/main_page/screens/notification/notification_screen.dart';
import 'package:ggangs_gym/screen/main_page/screens/player/player_screen.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> widgets = [
    const HomeScreen(),
    const GameScreen(),
    const PlayerScreen(),
    const NotificationScreen()
  ];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(color: Theme.of(context).colorScheme.primary),
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white10,
              Colors.white10,
              Colors.black12,
              Colors.black12,
              Colors.black12,
              Colors.black12,
            ],
          )),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: true,
            currentIndex: _selected,
            elevation: 0,
            onTap: (selected) {
              setState(() {
                _selected = selected;
              });
            },
            selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedItemColor:
                Theme.of(context).colorScheme.onPrimaryContainer,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "Home",
                  backgroundColor: Colors.transparent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.newspaper),
                  label: "Game",
                  backgroundColor: Colors.transparent),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_3_fill),
                  label: "Player",
                  backgroundColor: Colors.transparent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  label: "Notification",
                  backgroundColor: Colors.transparent),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(outPadding),
              child: widgets.elementAt(_selected),
            ),
          ),
        )
      ],
    );
  }
}
