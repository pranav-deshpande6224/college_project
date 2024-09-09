import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/Screens/auth/email_verification.dart';
import 'package:college_project/Authentication/Providers/spinner.dart';
import 'package:college_project/Home/IOS_Files/screens/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHandler {
  static AuthHandler authHandlerInstance = AuthHandler();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  User? user;

  showErrorDialog(BuildContext context, String title, String content) {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text(
                title,
                style: GoogleFonts.roboto(),
              ),
              content: Text(
                content,
                style: GoogleFonts.roboto(),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    'Okay',
                    style: GoogleFonts.roboto(),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            );
          });
    } else if (Platform.isAndroid) {}
  }

  Future<void> signUp(String email, String password, BuildContext context,
      WidgetRef ref) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      ref.read(spinnerProvider.notifier).isDoneLoading();
      if (e.code == 'weak-password') {
        if (!context.mounted) return;
        showErrorDialog(context, 'Alert', 'The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        if (!context.mounted) return;
        showErrorDialog(context, 'Alert', 'Email already in use');
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorDialog(context, 'Alert', e.toString());
    }
  }

  Future<void> signIn(String email, String password, BuildContext context,
      WidgetRef ref) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        if (!context.mounted) return;
        ref.read(loginSpinner.notifier).isDoneLoading();
        showErrorDialog(context, 'Alert', 'No user found for that email');
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        if (!context.mounted) return;
        ref.read(loginSpinner.notifier).isDoneLoading();
        showErrorDialog(context, 'Alert',
            "You might not have an account, or your password could be wrong.");
      } else if (e.code == 'too-many-requests') {
        if (!context.mounted) return;
        ref.read(loginSpinner.notifier).isDoneLoading();
        showErrorDialog(context, 'Alert',
            "You have entered wrong password too many times. Please try again later.");
      }
    }
  }

  Future<void> googleSignIn(WidgetRef ref, BuildContext context) async {
    try {
      ref.read(googleSignInSpinner.notifier).isLoading();
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await firebaseAuth.signInWithCredential(credential);
        user = firebaseAuth.currentUser;
        if (user != null) {
          final isUserExists = await checkUserExistOrNot(user!.email!);
          if (isUserExists) {
            ref.read(googleSignInSpinner.notifier).isDoneLoading();
          } else {
            await storeSignUpData(user!.email!, user!.displayName!, "");
            ref.read(googleSignInSpinner.notifier).isDoneLoading();
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('uid', user!.uid);
          if (context.mounted) {
            moveToHome(context);
          }
        }
      } else {
        ref.read(googleSignInSpinner.notifier).isDoneLoading();
      }
    } on FirebaseAuthException catch (e) {
      ref.read(googleSignInSpinner.notifier).isDoneLoading();
      if (!context.mounted) return;
      showErrorDialog(context, 'Alert', e.toString());
    }
  }

  void moveToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (context) => const BottomNavBar(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void moveToEmailVerification(String email, BuildContext context) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (ctx) => EmailVerification(
        email: email,
      ),
    ));
  }

  Future<void> storeSignUpData(
      String email, String firstName, String lastName) async {
    if (user != null) {
      await fireStore.collection('users').doc(user!.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      });
    }
  }

  void sendLinkToEmail() {
    if (user != null) {
      user!.sendEmailVerification();
    }
  }

  Future<bool> checkUserExistOrNot(String email) async {
    QuerySnapshot querySnapshot = await fireStore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> forgetPassword(
      String email, BuildContext context, WidgetRef ref) async {
    final isEmailExists = await checkUserExistOrNot(email);
    if (!isEmailExists) {
      if (!context.mounted) return;
      ref.read(submitSpinner.notifier).isDoneLoading();
      showErrorDialog(context, 'Alert',
          'No user found for that email, if you are new user, please sign up.');
    } else {
      try {
        await firebaseAuth.sendPasswordResetEmail(email: email);
        ref.read(submitSpinner.notifier).isDoneLoading();
        if (!context.mounted) return;
        showAlert(context, email);
      } on FirebaseAuthException catch (e) {
        if (!context.mounted) return;
        ref.read(submitSpinner.notifier).isDoneLoading();
        showErrorDialog(
          context,
          'Alert',
          e.toString(),
        );
      }
    }
  }

  void showAlert(BuildContext context, String email) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Alert',
          style: GoogleFonts.roboto(),
        ),
        content: Text(
          'Reset Password link has been sent to your Email: $email',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
