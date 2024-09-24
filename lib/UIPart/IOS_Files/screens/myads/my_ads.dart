import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/screens/myads/display_ads.dart';
import 'package:college_project/UIPart/Providers/ads_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAds extends ConsumerStatefulWidget {
  const MyAds({super.key});

  @override
  ConsumerState<MyAds> createState() => _MyAdsState();
}

class _MyAdsState extends ConsumerState<MyAds> {
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'MY ADS',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final index = ref.watch(adsIndexProvider);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (index != 0) {
                                ref.read(adsIndexProvider.notifier).setIndex(0);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? CupertinoColors.activeBlue
                                    : null,
                                border: Border.all(width: 0.2),
                              ),
                              child: Center(
                                child: Text(
                                  'Active Ads',
                                  style: GoogleFonts.roboto(
                                    fontWeight:
                                        index == 0 ? FontWeight.bold : null,
                                    color: index == 0
                                        ? CupertinoColors.white
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (index != 1) {
                                ref.read(adsIndexProvider.notifier).setIndex(1);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: index == 1
                                    ? CupertinoColors.activeBlue
                                    : null,
                                border: Border.all(width: 0.2),
                              ),
                              child: Center(
                                child: Text(
                                  'Sold Ads',
                                  style: GoogleFonts.roboto(
                                    fontWeight:
                                        index == 1 ? FontWeight.bold : null,
                                    color: index == 1
                                        ? CupertinoColors.white
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: DisplayAds(index: index),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
