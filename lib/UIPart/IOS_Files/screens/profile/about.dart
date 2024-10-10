import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('About', style: GoogleFonts.roboto(),),
      ),
      child: const SafeArea(
        child: Text(
          'about',
        ),
      ),
    );
  }
}
