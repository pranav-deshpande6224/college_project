import 'package:flutter/cupertino.dart';

import '../../../constants/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Constants.screenBgColor,
        child: const Center(
          child: Text('Home Screen'),
        ),
      ),
    );
  }
}
