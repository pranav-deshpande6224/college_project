import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Inbox',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: Center(
        child:
            CupertinoButton(child: Text(" chatting screen "), onPressed: () {}),
      ),
    );
  }
}
