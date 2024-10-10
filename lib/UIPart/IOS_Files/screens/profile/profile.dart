import 'package:college_project/Authentication/IOS_Files/Screens/auth/login_ios.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/category.dart';
import 'package:college_project/UIPart/IOS_Files/screens/myads/my_sold_ads.dart';
import 'package:college_project/UIPart/IOS_Files/screens/profile/about.dart';
import 'package:college_project/UIPart/IOS_Files/screens/profile/policies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  List<ProfileCategory> profileList = const [
    ProfileCategory(
        icon: CupertinoIcons.check_mark_circled, title: 'My Sold Ads'),
    ProfileCategory(icon: CupertinoIcons.person, title: 'About'),
    ProfileCategory(icon: CupertinoIcons.share, title: 'Share'),
    ProfileCategory(icon: CupertinoIcons.book, title: 'Policies'),
    ProfileCategory(icon: CupertinoIcons.square_arrow_right, title: 'Logout')
  ];
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

  Future<void> executeSignOut(BuildContext signOutContext) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      await handler.firebaseAuth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      handler.newUser.user = null;

      if (!signOutContext.mounted) return;
      Navigator.pop(signOutContext);
      moveToLogin();
    } catch (e) {
      Navigator.pop(signOutContext);
      if (!context.mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
              'Alert',
              style: GoogleFonts.roboto(),
            ),
            content: Text(
              e.toString(),
              style: GoogleFonts.roboto(),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Okay',
                  style: GoogleFonts.roboto(),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  spinner() {
    late BuildContext signOutContext;
    showCupertinoDialog(
        context: context,
        builder: (ctx) {
          signOutContext = ctx;
          executeSignOut(signOutContext);
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(
                  radius: 15,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Loading...',
                  style: GoogleFonts.roboto(),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'My Account',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.person,
                          color: CupertinoColors.black,
                          size: 35,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          handler.newUser.user?.displayName ?? '',
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: profileList.length,
                    itemBuilder: (ctx, index) {
                      final obj = profileList[index];
                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (ctx) => MySoldAds(),
                              ),
                            );
                          } else if (index == 1) {
                            Navigator.of(context, rootNavigator: true)
                                .push(CupertinoPageRoute(builder: (ctx) {
                              return About();
                            }));
                          } else if (index == 2) {
                          } else if (index == 3) {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (ctx) => const Policies(),
                              ),
                            );
                          } else {
                            showCupertinoDialog(
                              context: context,
                              builder: (ctx) {
                                return CupertinoAlertDialog(
                                  title: Text('Alert',
                                      style: GoogleFonts.roboto()),
                                  content: Text(
                                    'Are you sure want to Logout',
                                    style: GoogleFonts.roboto(),
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Text(
                                        'No',
                                        style: GoogleFonts.roboto(),
                                      ),
                                    ),
                                    CupertinoDialogAction(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        spinner();
                                      },
                                      child: Text(
                                        'Yes',
                                        style: GoogleFonts.roboto(
                                          color: CupertinoColors.systemRed,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Column(
                          children: [
                            CupertinoListTile(
                              leading: Icon(
                                obj.icon,
                                size: 30,
                              ),
                              trailing: const Icon(
                                CupertinoIcons.right_chevron,
                                color: CupertinoColors.activeBlue,
                              ),
                              title: Text(
                                obj.title,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              decoration: BoxDecoration(
                                border: Border.all(),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),

                  // SizedBox(
                  //   height: 50,
                  //   width: double.infinity,
                  //   child: CupertinoButton(
                  //     color: CupertinoColors.activeBlue,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         const Icon(
                  //           CupertinoIcons.pencil,
                  //           size: 24,
                  //         ),
                  //         const SizedBox(
                  //           width: 5,
                  //         ),
                  //         Text(
                  //           'Edit Profile',
                  //           style: GoogleFonts.roboto(
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     onPressed: () async {
                  //       await Navigator.of(context, rootNavigator: true)
                  //           .push(CupertinoPageRoute(builder: (ctx) {
                  //         return const ProfileDetailScreen();
                  //       }));
                  //       setState(() {});
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
