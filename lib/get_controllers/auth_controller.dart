import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:ggangs_gym/screen/main_page/main_page.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Rxn<User?> _user = Rxn();

  bool isLogin() {
    if (_user.value != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void onReady() {
    _user = Rxn<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, (User? recentUser) => _movePage(recentUser));
  }

  ///로그인 기능이 필요할 때 사용.
  _movePage(User? user) {
    if (user == null) {
      Get.offAll(() => const MainPage());
    } else {
      Get.offAll(() => const MainPage());
    }
    return;
  }

  Future<void> resistUser(String email, String password) async {
    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((UserCredential userCredential) =>
              Get.snackbar('가입완료', userCredential.user?.email ?? 'Unknown'));
    } catch (e) {
      Get.snackbar('오류', e.toString());
      log('resistUser 오류,${e.toString()}');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      Get.snackbar('로그인 오류', e.toString());
      log('login 오류, ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}
