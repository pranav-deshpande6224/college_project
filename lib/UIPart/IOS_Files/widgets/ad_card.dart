import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/Providers/show_sold_ads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
    try {
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            anotherContext = ctx;
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          });
      await fireStore.runTransaction((_) async {
        fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MySoldAds')
            .doc(ad.id)
            .delete();
      }).then((value) {
        ref.read(showSoldAdsProvider.notifier).deleteSoldAd(ad);
        if (anotherContext.mounted) {
          Navigator.of(anotherContext).pop();
        }
      });
    } catch (e) {
      //TODO:  Show the error message to the USer
      print(e.toString());
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
                      // adSold(ad);
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
                                      style: GoogleFonts.roboto(
                                          color:
                                              CupertinoColors.destructiveRed),
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text('Yes',
                                        style: GoogleFonts.roboto()),
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
                              'Mark as Sold',
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
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print('Edit Product');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: CupertinoColors.black,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.pencil,
                              color: CupertinoColors.black,
                              size: 25,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Edit Product',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
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
                        child: ClipRRect(
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                    'assets/images/placeholder.jpg'),
                              ),
                              Positioned(
                                top: 5,
                                left: 5,
                                right: 5,
                                child: ClipRRect(
                                  child: Image.network(
                                    ad.images[0],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            ],
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
