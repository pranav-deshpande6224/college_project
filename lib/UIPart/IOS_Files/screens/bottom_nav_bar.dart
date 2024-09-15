import 'package:college_project/Home/IOS_FILES/screens/home.dart';
import 'package:college_project/UIPart/IOS_Files/screens/profile/profile.dart';
import 'package:flutter/cupertino.dart';

import 'chats/chats.dart';
import 'myads/my_ads.dart';
import 'sell/sell.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
            activeColor:
                CupertinoColors.systemIndigo, // Text color for active tab
            inactiveColor: CupertinoColors.systemGrey,
            items: const [
              BottomNavigationBarItem(
                activeIcon: Icon(
                  CupertinoIcons.house_fill,
                  color: CupertinoColors.systemIndigo,
                ),
                icon: Icon(
                  CupertinoIcons.home,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(CupertinoIcons.chat_bubble_fill,
                    color: CupertinoColors.systemIndigo),
                icon: Icon(CupertinoIcons.chat_bubble),
                label: 'chats',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(CupertinoIcons.add_circled_solid,
                    color: CupertinoColors.systemIndigo),
                icon: Icon(
                  CupertinoIcons.add_circled,
                ),
                label: 'Sell',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(CupertinoIcons.heart_fill,
                    color: CupertinoColors.systemIndigo),
                icon: Icon(CupertinoIcons.heart),
                label: 'My ADS',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(CupertinoIcons.person_fill,
                    color: CupertinoColors.systemIndigo),
                icon: Icon(CupertinoIcons.person),
                label: 'account',
              ),
            ]),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (context) => const Home(),
              );
            case 1:
              return CupertinoTabView(
                builder: (context) => const Chats(),
              );
            case 2:
              return CupertinoTabView(
                builder: (context) => const Sell(),
              );
            case 3:
              return CupertinoTabView(
                builder: (context) => const MyAds(),
              );
            case 4:
              return CupertinoTabView(
                builder: (context) => const Profile(),
              );
            default:
              return CupertinoTabView(
                builder: (context) => const Home(),
              );
          }
        },
      ),
    );
  }
}
