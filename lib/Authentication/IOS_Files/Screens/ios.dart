import 'package:college_project/Authentication/IOS_Files/Screens/auth/login_ios.dart';
import 'package:flutter/cupertino.dart';

import '../../../UIPart/IOS_Files/screens/bottom_nav_bar.dart';

class Ios extends StatelessWidget {
  final bool isUserLoggedIn;
  const Ios({required this.isUserLoggedIn, super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: isUserLoggedIn ? const BottomNavBar() : const LoginIos(),
    );
  }
}
