import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Home/Providers/ads_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAds extends StatefulWidget {
  const MyAds({super.key});

  @override
  State<MyAds> createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
  bool isActiveAdLoading = false;
  bool isSoldAdLoading = false;
  bool isFavouriteAdLoading = false;
  late AuthHandler handler;

  void getActiveAdsData() async {
    try {
      if (handler.user != null) {
        QuerySnapshot<Map<String, dynamic>> data = await handler.fireStore
            .collection('users')
            .doc(handler.user!.uid)
            .collection('MyActiveAds')
            .orderBy('createdAt', descending: true)
            .get();
        for (final doc in data.docs) {
          print(doc.data());
        }
      } else {
        // Navigate to Login screen
      }
    } catch (e) {
      print(e);
    }
  }

  Widget getData(int index) {
    if (index == 0) {
      return ListView.builder(
        itemCount: 2,
        itemBuilder: (ctx, index) {
          return Column(
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(),
                  ),
                  child: Column(
                    children: [
                      const Expanded(
                        flex: 7,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Text('Image'),
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Text('Text and Price'),
                            )
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        color: CupertinoColors.black,
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: CupertinoColors.systemIndigo,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Mark as Sold',
                                          style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          width: 1,
                                          color: CupertinoColors.systemIndigo,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Edit Product',
                                          style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          );
        },
      );
    } else if (index == 1) {
      return const Center(
        child: Text('Sold Ads'),
      );
    } else {
      return const Center(
        child: Text('Favourite Ads'),
      );
    }
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    getActiveAdsData();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Consumer(
                builder: (ctx, ref, child) {
                  final index = ref.watch(adsIndexProvider);
                  return Row(
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
                                  ? CupertinoColors.systemTeal
                                  : null,
                              border: Border.all(width: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                'Active Ads',
                                style: GoogleFonts.roboto(
                                  fontWeight:
                                      index == 0 ? FontWeight.bold : null,
                                  color:
                                      index == 0 ? CupertinoColors.white : null,
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
                                  ? CupertinoColors.systemTeal
                                  : null,
                              border: Border.all(width: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                'Sold Ads',
                                style: GoogleFonts.roboto(
                                  fontWeight:
                                      index == 1 ? FontWeight.bold : null,
                                  color:
                                      index == 1 ? CupertinoColors.white : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (index != 2) {
                              ref.read(adsIndexProvider.notifier).setIndex(2);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: index == 2
                                  ? CupertinoColors.systemTeal
                                  : null,
                              border: Border.all(width: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                'Favourite Ads',
                                style: GoogleFonts.roboto(
                                  fontWeight:
                                      index == 2 ? FontWeight.bold : null,
                                  color:
                                      index == 2 ? CupertinoColors.white : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            Consumer(
              builder: (ctx, ref, child) {
                final index = ref.watch(adsIndexProvider);
                return Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: getData(index),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
