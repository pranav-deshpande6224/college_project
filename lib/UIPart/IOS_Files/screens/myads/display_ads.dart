import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:college_project/UIPart/Providers/home_ads.dart';
import 'package:college_project/UIPart/Providers/show_ads.dart';
import 'package:college_project/UIPart/Providers/show_sold_ads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayAds extends ConsumerStatefulWidget {
  final int index;
  const DisplayAds({required this.index, super.key});

  @override
  ConsumerState<DisplayAds> createState() => _DisplayAdsState();
}

class _DisplayAdsState extends ConsumerState<DisplayAds> {
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  void markAsSold(Item item) async {
    final firestore = handler.fireStore;
    late BuildContext markAsSoldContext;
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        markAsSoldContext = ctx;
        return const Center(
          child: CupertinoActivityIndicator(
            radius: 15,
            color: CupertinoColors.black,
          ),
        );
      },
    );
    try {
      await firestore.runTransaction((_) async {
        // Backend Deletion
        final path = firestore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MyActiveAds')
            .doc(item.id)
            .path;
        print(path);
        DocumentReference refToMatch = FirebaseFirestore.instance.doc(path);
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('AllAds')
                .where('adReference', isEqualTo: refToMatch)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          await firestore
              .collection('AllAds')
              .doc(querySnapshot.docs[0].id)
              .delete();
        }

        QuerySnapshot<Map<String, dynamic>> categoryDoc = await firestore
            .collection('Category')
            .doc(item.categoryName)
            .collection('Subcategories')
            .doc(item.subCategoryName)
            .collection('Ads')
            .where('adReference', isEqualTo: refToMatch)
            .get();
        if (categoryDoc.docs.isNotEmpty) {
          await firestore
              .collection('Category')
              .doc(item.categoryName)
              .collection('Subcategories')
              .doc(item.subCategoryName)
              .collection('Ads')
              .doc(categoryDoc.docs[0].id)
              .delete();
        }
        await firestore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MyActiveAds')
            .doc(item.id)
            .delete();
        // Add details to the soldAds Collection
        await firestore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MySoldAds')
            .add(item.toJson());
      }).then((val) {
        // UI Deletion
        // deletion from the Active Ads done
        ref.read(showActiveAdsProvider.notifier).deleteActiveAd(item);
        ref.read(showHomeAdsProvider.notifier).deleteAd(item);
        // TODO :  Deletion from the category
        if (markAsSoldContext.mounted) {
          Navigator.of(markAsSoldContext).pop();
        }
      });
    } catch (e) {
      if (markAsSoldContext.mounted || context.mounted) {
        //TODO show Alert
        Navigator.of(markAsSoldContext).pop();
        showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog();
          },
        );
      }
    }
  }

  Widget showSpinner() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
            radius: 15,
          ),
          SizedBox(
            height: 10,
          ),
          Text('Loading...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index == 0) {
      final itemList = ref.watch(showActiveAdsProvider);
      return itemList.when(
        data: (data) {
          return CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () =>
                    ref.read(showActiveAdsProvider.notifier).refreshActiveAds(),
              ),
              data.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No Active Ads of Yours!',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = data[index];
                          return AdCard(
                            cardIndex: index,
                            ad: item,
                            adSold: markAsSold,
                            isSold: false,
                          );
                        },
                        childCount: data.length,
                      ),
                    ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(error.toString()),
          );
        },
        loading: showSpinner,
      );
    } else {
      // Need to show the Sold Ads
      final soldItemList = ref.watch(showSoldAdsProvider);
      return soldItemList.when(
        data: (data) {
          return CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () =>
                    ref.read(showSoldAdsProvider.notifier).refreshSoldAds(),
              ),
              data.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No Sold Ads Found!',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = data[index];
                          return AdCard(
                            cardIndex: index,
                            ad: item,
                            adSold: null,
                            isSold: true,
                          );
                        },
                        childCount: data.length,
                      ),
                    ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(error.toString()),
          );
        },
        loading: showSpinner,
      );
    }
  }
}
