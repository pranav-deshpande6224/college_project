import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/Models/new_user.dart';
import 'package:college_project/Authentication/IOS_Files/Screens/auth/email_verification.dart';
import 'package:college_project/UIPart/IOS_Files/screens/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHandler {
  static AuthHandler authHandlerInstance = AuthHandler();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  //User? user;
  NewUser newUser = NewUser();

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
      BuildContext signUpContext, String fName) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      newUser.user = userCredential.user;
      newUser.user!.updateDisplayName(fName);
      if (!context.mounted) return;
      await storeSignUpData(context, email, fName);
      if (!context.mounted) return;
      Navigator.pop(signUpContext);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (ctx) => EmailVerification(
            email: email,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (!context.mounted) return;
        Navigator.pop(signUpContext);
        showErrorDialog(context, 'Alert', 'The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        if (!context.mounted) return;
        Navigator.pop(signUpContext);
        showErrorDialog(context, 'Alert', 'Email already in use');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(signUpContext);
      showErrorDialog(context, 'Alert', e.toString());
    }
  }

  Future<void> signIn(String email, String password, BuildContext context,
      BuildContext loginContext) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      newUser.user = firebaseAuth.currentUser;
      if (newUser.user!.emailVerified) {
        final pref = await SharedPreferences.getInstance();
        await pref.setString('uid', newUser.user!.uid);
        if (!context.mounted) return;
        Navigator.of(loginContext).pop();
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (context) => const BottomNavBar(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!context.mounted) return;
        Navigator.of(loginContext).pop();
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (ctx) => EmailVerification(
              email: email,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        if (!context.mounted) return;
        Navigator.of(loginContext).pop();
        showErrorDialog(context, 'Alert',
            "You might not have an account, or your password could be wrong.");
      } else if (e.code == 'too-many-requests') {
        if (!context.mounted) return;
        Navigator.of(loginContext).pop();
        showErrorDialog(context, 'Alert',
            "You have entered wrong password too many times. Please try again later.");
      } else {
        showErrorDialog(context, 'Alert', e.toString());
      }
    }
  }

  Future<void> googleSignIn(WidgetRef ref, BuildContext context,
      BuildContext googleSignInContext) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await firebaseAuth.signInWithCredential(credential);
        newUser.user = firebaseAuth.currentUser;
        if (newUser.user != null) {
          final isUserExists = await checkUserExistOrNot(newUser.user!.email!);
          if (!isUserExists) {
            if (!context.mounted) return;
            await storeSignUpData(
                context, newUser.user!.email!, newUser.user!.displayName!);
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('uid', newUser.user!.uid);
          if (context.mounted) {
            Navigator.of(googleSignInContext).pop();
            moveToHome(context);
          }
        }
      } else {
        if (!googleSignInContext.mounted) return;
        Navigator.of(googleSignInContext).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Navigator.of(googleSignInContext).pop();
      showErrorDialog(context, 'Alert', e.toString());
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(googleSignInContext).pop();
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
      BuildContext context, String email, String firstName) async {
    if (newUser.user != null) {
      try {
        await fireStore.collection('users').doc(newUser.user!.uid).set({
          'email': email,
          'firstName': firstName,
        });
      } catch (e) {
        if (!context.mounted) return;
        showErrorDialog(context, 'Alert', e.toString());
      }
    }
  }

  void sendLinkToEmail() {
    if (newUser.user != null) {
      newUser.user!.sendEmailVerification();
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

  Future<void> forgetPassword(String email, BuildContext context,
      BuildContext foregetPasswordContext) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      Navigator.of(foregetPasswordContext).pop();
      showAlert(context, email);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Navigator.of(foregetPasswordContext).pop();
      showErrorDialog(
        context,
        'Alert',
        e.toString(),
      );
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
