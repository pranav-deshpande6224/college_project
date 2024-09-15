import 'package:flutter/cupertino.dart';

import '../../../../constants/constants.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Constants.screenBgColor,
        child: const Center(
          child: Text('Chats Screen'),
        ),
      ),
    );
  }
}
