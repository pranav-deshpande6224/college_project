import 'package:college_project/Authentication/IOS_Files/Screens/auth/login_ios.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  void moveToLogin() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (ctx) => const LoginIos()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(245, 190, 190, 200),
        child: Center(
          child: CupertinoButton(
            child: const Text('Logout'),
            onPressed: () async {
              await handler.firebaseAuth.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              moveToLogin();
            },
          ),
        ),
      ),
    );
  }
}
