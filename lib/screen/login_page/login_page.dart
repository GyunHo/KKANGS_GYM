import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/get_controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: colorScheme.background,

      appBar: AppBar(title: Text('관리자 로그인',style: TextStyle(color: colorScheme.primary),),centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                      hintText: "이메일",
                      prefixIcon: Icon(Icons.email),
                      hintStyle: TextStyle(color: colorScheme.primary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                      hintText: "비밀번호",
                      prefixIcon: Icon(Icons.key),
                      hintStyle: TextStyle(color: colorScheme.primary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )),
                  onPressed: () async {
                    await authController.login(emailController.text.trim(),
                        passwordController.text.trim());
                  },
                  child: Text(
                    '로그인',
                    style: textTheme.titleMedium!
                        .copyWith(color: colorScheme.primary),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
