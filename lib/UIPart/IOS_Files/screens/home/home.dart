import 'package:college_project/UIPart/IOS_Files/screens/home/display_home_ads.dart';
import 'package:college_project/UIPart/IOS_Files/screens/home/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'IIT Jodhpur',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 5,
                  bottom: 5,
                ),
                child: CupertinoSearchTextField(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(builder: (ctx)=>SearchScreen()));
                  },
                  placeholder: 'Find Mobiles, Monitor and more...',
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: DisplayHomeAds(),
            )
          ],
        ),
      ),
    );
  }
}
