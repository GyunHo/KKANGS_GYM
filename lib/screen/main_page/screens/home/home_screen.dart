import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/auth_controller.dart';
import 'package:ggangs_gym/get_controllers/league_controller.dart';
import 'package:ggangs_gym/get_controllers/team_player_controller.dart';
import 'package:ggangs_gym/screen/login_page/login_page.dart';
import 'package:ggangs_gym/screen/main_page/circular_border_avatar.dart';
import 'package:ggangs_gym/screen/main_page/my_container.dart';

const outPadding = 24.0;

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(TeamAndPlayerController());
    Get.put(LeagueController());
    AuthController authController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.sports_basketball,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 32,
            ),
            Expanded(child: Container()),
            TextButton(
                onPressed: () {
                  authController.isLogin()??false
                      ? authController.logout()
                      : Get.to(() => const LoginPage());
                },
                child: Text(
                  authController.isLogin()??false ? '로그아웃' : '로그인',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ))
          ],
        ),
        const SizedBox(
          height: outPadding,
        ),
        Text(
          "헤이! 깡's GYM 입니다.",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text(
              '현재 세종점 이에요.',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
            Icon(Icons.change_circle_outlined,
                color: Theme.of(context).colorScheme.shadow)
          ],
        ),
        const SizedBox(
          height: outPadding,
        ),
        const _TopCard(),
        const SizedBox(
          height: outPadding,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${DateTime.now().month}월 게임 기록',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const _ActionBtn()
          ],
        ),
        const SizedBox(
          height: outPadding,
        ),
        Expanded(
          child: Row(
            children: [
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: MyContainer(
                      pad: 16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                            '랭킹 개발중',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: outPadding,
                  ),
                  Flexible(
                    child: MyContainer(
                      pad: 16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                            '개발중',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(
                width: outPadding,
              ),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: MyContainer(
                      pad: 16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                            '개발대기',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: outPadding,
                  ),
                  Flexible(
                    child: MyContainer(
                      pad: 16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                            '기능대기',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 16)
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.tertiary,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withAlpha(130),
              blurRadius: 8.0, // soften the shadow
              spreadRadius: 4.0, //extend the shadow
              offset: const Offset(
                8.0, // Move to right 10  horizontally
                8.0, // Move to bottom 10 Vertically
              ),
            ),
            BoxShadow(
              color: Colors.white.withAlpha(130),
              blurRadius: 8.0, // soften the shadow
              spreadRadius: 4.0, //extend the shadow
            ),
          ]),
      child: Icon(
        Icons.calendar_today_rounded,
        color: Theme.of(context).colorScheme.onTertiary,
        size: 16,
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyContainer(
      pad: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '배너 기능 개발 대기',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          Text(
            '개발중',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 32,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  width: 32,
                  top: 0,
                  bottom: 0,
                  child: CircularBorderAvatar(
                    'https://randomuser.me/api/portraits/women/68.jpg',
                    borderColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Positioned(
                  left: 22,
                  width: 32,
                  top: 0,
                  bottom: 0,
                  child: CircularBorderAvatar(
                    'https://randomuser.me/api/portraits/women/90.jpg',
                    borderColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Text(
                    'now',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
