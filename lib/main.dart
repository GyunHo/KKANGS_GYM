import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggangs_gym/firebase_options.dart';

import 'package:ggangs_gym/screen/main_page/main_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'get_controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => Get.put(AuthController()));

  runApp(const KkangsGym());
}

 const seedColor = Color(0xff2e3192);


class KkangsGym extends StatelessWidget {
  const KkangsGym({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
          colorSchemeSeed: seedColor,
          brightness: Brightness.dark,
          textTheme:
              GoogleFonts.notoSansNKoTextTheme(Theme.of(context).textTheme)),
      home: const MainPage(),
    );
  }
}
