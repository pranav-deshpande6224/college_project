import 'dart:io';

import 'package:college_project/Authentication/Screens/android.dart';
import 'package:college_project/Authentication/IOS_Files/Screens/ios.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:college_project/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final isUserLoggedIn = await checkUserLoggedIn();
  runApp(
    ProviderScope(
      child: MyApp(isUserLoggedIn: isUserLoggedIn),
    ),
  );
}

Future<bool> checkUserLoggedIn() async {
  final pref = await SharedPreferences.getInstance();
  final uid = pref.getString('uid') ?? '';
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    await pref.clear();
    return false;
  } else {
    if (user.uid == uid) {
      if(user.emailVerified) {
        return true;
      } else {
        await FirebaseAuth.instance.signOut();
        await pref.clear();
        return false;
      }
    } else {
      await pref.clear();
      await FirebaseAuth.instance.signOut();
      return false;
    }
  }
}

class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;
  const MyApp({required this.isUserLoggedIn, super.key});
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Ios(isUserLoggedIn: isUserLoggedIn);
    }
    if (Platform.isAndroid) {
      return const Android();
    }
    return const Android();
  }
}
