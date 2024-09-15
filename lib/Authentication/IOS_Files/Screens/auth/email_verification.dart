import 'dart:async';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../UIPart/IOS_Files/screens/bottom_nav_bar.dart';

class EmailVerification extends StatefulWidget {
  final String email;
  const EmailVerification({required this.email, super.key});
  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  late AuthHandler handler;
  late Timer _timer;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    sendEmailLink();
    timerForVerify();
    super.initState();
  }

  void sendEmailLink() {
    handler.sendLinkToEmail();
  }

  void resendEmailLink() {
    _timer.cancel();
    sendEmailLink();
    timerForVerify();
  }

  void timerForVerify() {
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        handler.firebaseAuth.currentUser!.reload();
        final user = handler.firebaseAuth.currentUser;
        if (user!.emailVerified) {
          handler.user = handler.firebaseAuth.currentUser;
          _timer.cancel();
          final pref = await SharedPreferences.getInstance();
          await pref.setString('uid', handler.user!.uid);
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(
                builder: (context) => const BottomNavBar(),
              ),
              (Route<dynamic> route) => false,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Constants.screenBgColor,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const CircleAvatar(
                          backgroundColor: Constants.white,
                          child: Icon(
                            CupertinoIcons.back,
                            size: 30,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                      const Spacer()
                    ],
                  ),
                  Image.asset(
                    height: 100,
                    width: 100,
                    'assets/images/email.png',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'An Email link has been sent to the mail id',
                    style: GoogleFonts.roboto(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FittedBox(
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widget.email,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Link is for verification of your Email',
                    style: GoogleFonts.roboto(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () {
                        resendEmailLink();
                      },
                      child: Text(
                        'Resend Email',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
