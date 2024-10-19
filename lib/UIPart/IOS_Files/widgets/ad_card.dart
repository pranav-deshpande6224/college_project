import 'package:cached_network_image/cached_network_image.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/show_sold_ads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class AdCard extends ConsumerWidget {
  final int cardIndex;
  final Item ad;
  final bool isSold;
  final void Function(Item item)? adSold;
  const AdCard(
      {required this.cardIndex,
      required this.ad,
      required this.adSold,
      required this.isSold,
      super.key});

  Future<void> deleteSoldAd(
      Item ad, WidgetRef ref, BuildContext context) async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    late BuildContext anotherContext;
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text(
                'No Internet',
                style: GoogleFonts.roboto(),
              ),
              content: Text(
                'Please check your internet connection and try again',
                style: GoogleFonts.roboto(),
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text(
                    'OK',
                    style: GoogleFonts.roboto(),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          });
      return;
    }
    try {
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            anotherContext = ctx;
            return const Center(
              child: CupertinoActivityIndicator(
                radius: 15,
                color: CupertinoColors.activeBlue,
              ),
            );
          });
      await fireStore.runTransaction((_) async {
        fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MySoldAds')
            .doc(ad.id)
            .delete();
      });
      ref.read(showSoldAdsProvider.notifier).deleteItem(ad);
      if (anotherContext.mounted) {
        Navigator.of(anotherContext).pop();
      }
    } catch (e) {
      if (anotherContext.mounted) {
        Navigator.of(anotherContext).pop();
      }
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
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Okay',
                    style: GoogleFonts.roboto(),
                  ))
            ],
          );
        },
      );
    }
  }

  Widget getWidget(BuildContext context, WidgetRef ref) {
    if (isSold) {
      return Expanded(
        flex: 4,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () async {
                await deleteSoldAd(ad, ref, context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    width: 1,
                    color: CupertinoColors.systemRed,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Delete this Ad',
                    style: GoogleFonts.roboto(
                      color: CupertinoColors.systemRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        flex: 4,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      //adSold(ad);
                      showCupertinoDialog(
                          context: context,
                          builder: (ctx) {
                            return CupertinoAlertDialog(
                                title: Text(
                                  'Alert',
                                  style: GoogleFonts.roboto(),
                                ),
                                content: Text(
                                  'Is this Item Sold?',
                                  style: GoogleFonts.roboto(),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text(
                                      'No',
                                      style: GoogleFonts.roboto(),
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text('Yes',
                                        style: GoogleFonts.roboto(
                                          color: CupertinoColors.destructiveRed,
                                        )),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      adSold!(ad);
                                    },
                                  ),
                                ]);
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: CupertinoColors.activeBlue,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.check_mark_circled,
                              size: 25,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Mark this Product as Sold',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Expanded(
                //   child: GestureDetector(
                //     onTap: () {
                //       Navigator.of(context, rootNavigator: true).push(
                //         CupertinoPageRoute(
                //           builder: (ctx) => ProductGetInfo(
                //             categoryName: ad.categoryName,
                //             subCategoryName: ad.subCategoryName,
                //             ad: ad,
                //             isEditAd: true,
                //           ),
                //         ),
                //       );
                //     },
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //           width: 2,
                //           color: CupertinoColors.black,
                //         ),
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       child: Center(
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             const Icon(
                //               CupertinoIcons.pencil,
                //               color: CupertinoColors.black,
                //               size: 25,
                //             ),
                //             const SizedBox(
                //               width: 8,
                //             ),
                //             Text(
                //               'Edit Product',
                //               style: GoogleFonts.roboto(
                //                 fontWeight: FontWeight.w500,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 0.5),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: CachedNetworkImage(
                            imageUrl: ad.images[0],
                            placeholder: (context, url) {
                              return ClipRRect(
                                child: Image.asset(
                                  'assets/images/placeholder.jpg',
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return const Center(
                                child:
                                    Icon(CupertinoIcons.exclamationmark_circle),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Container(
                          decoration: const BoxDecoration(),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  ad.adTitle,
                                  style: GoogleFonts.roboto(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '₹ ${ad.price.toInt()}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                getWidget(context, ref),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
