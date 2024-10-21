import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/Screens/auth/login_ios.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/internet_provider.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/show_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class MyAds extends ConsumerStatefulWidget {
  const MyAds({super.key});
  @override
  ConsumerState<MyAds> createState() => _MyAdsState();
}

class _MyAdsState extends ConsumerState<MyAds> {
  late AuthHandler handler;
  final ScrollController activeAdScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    handler = AuthHandler.authHandlerInstance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(showActiveAdsProvider.notifier).fetchInitialItems();
    });
    activeAdScrollController.addListener(() {
      double maxScroll = activeAdScrollController.position.maxScrollExtent;
      double currentScroll = activeAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(showActiveAdsProvider.notifier).fetchMoreItems();
      }
    });
  }

  @override
  void dispose() {
    activeAdScrollController.dispose();
    super.dispose();
  }

  void sellTheItem(Item item) async {
    if (handler.newUser.user != null) {
      final firestore = handler.fireStore;
      late BuildContext sellContext;
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (context.mounted) {
        if (!hasInternet) {
          showCupertinoDialog(
              context: context,
              builder: (ctx) {
                return CupertinoAlertDialog(
                  title: const Text('No Internet Connection'),
                  content: const Text(
                      'Please check your internet connection and try again.'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              });
        } else {
          try {
            showCupertinoDialog(
                context: context,
                builder: (ctx) {
                  sellContext = ctx;
                  return Center(
                    child: CupertinoActivityIndicator(
                      radius: 15,
                      color: CupertinoColors.black,
                    ),
                  );
                });
            await firestore.runTransaction((transaction) async {
              DocumentReference<Map<String, dynamic>> ref = firestore
                  .collection('users')
                  .doc(handler.newUser.user!.uid)
                  .collection('MyActiveAds')
                  .doc(item.id);

              DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
              DocumentReference<Map<String, dynamic>> docRef =
                  snapshot.reference;
              Query<Map<String, dynamic>> allAdsQuery = firestore
                  .collection('AllAds')
                  .where('adReference', isEqualTo: docRef);
              QuerySnapshot<Map<String, dynamic>> querySnapshot =
                  await allAdsQuery.get();
              Query<Map<String, dynamic>> categoryAdsQuery = firestore
                  .collection('Category')
                  .doc(item.categoryName)
                  .collection('Subcategories')
                  .doc(item.subCategoryName)
                  .collection('Ads')
                  .where('adReference', isEqualTo: docRef);
              QuerySnapshot<Map<String, dynamic>> categoryQuerySnapshot =
                  await categoryAdsQuery.get();
              // firestore
              //     .collection('users')
              //     .doc(handler.newUser.user!.uid)
              //     .collection('MySoldAds')
              //     .doc()
              //     .set(item.toJson());
              await querySnapshot.docs.first.reference.delete();
              await categoryQuerySnapshot.docs.first.reference.delete();
              item = item.copyWith(isAvailable: false);
              await docRef.update(item.toJson());
            });
            ref.read(showActiveAdsProvider.notifier).deleteItem(item);
            Navigator.of(sellContext).pop();
          } catch (e) {
            if (sellContext.mounted) {
              Navigator.of(sellContext).pop();
            }
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
                });
          }
        }
      } else {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (ctx) => const LoginIos()),
            (Route<dynamic> route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'My Active Ads',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
        child: connectivityState.when(
          data: (connectivityResult) {
            if (connectivityResult == ConnectivityResult.none) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.wifi_slash,
                      color: CupertinoColors.activeBlue,
                      size: 40,
                    ),
                    Text(
                      'No Internet Connection',
                      style: GoogleFonts.roboto(),
                    ),
                    CupertinoButton(
                        child: Text(
                          'Retry',
                          style: GoogleFonts.roboto(),
                        ),
                        onPressed: () async {
                          final x = ref.refresh(connectivityProvider);
                          final y = ref.refresh(internetCheckerProvider);
                          debugPrint(x.toString());
                          debugPrint(y.toString());
                          await ref
                              .read(showActiveAdsProvider.notifier)
                              .refreshItems();
                        })
                  ],
                ),
              );
            } else {
              return internetState.when(
                data: (hasInternet) {
                  if (!hasInternet) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.wifi_slash,
                            color: CupertinoColors.activeBlue,
                            size: 40,
                          ),
                          Text(
                            'No Internet Connection',
                            style: GoogleFonts.roboto(),
                          ),
                          CupertinoButton(
                              child: Text(
                                'Retry',
                                style: GoogleFonts.roboto(),
                              ),
                              onPressed: () {
                                print('retry in internet checker');
                                final x = ref.refresh(connectivityProvider);
                                final y = ref.refresh(internetCheckerProvider);
                                debugPrint(x.toString());
                                debugPrint(y.toString());
                                ref
                                    .read(showActiveAdsProvider.notifier)
                                    .refreshItems();
                              })
                        ],
                      ),
                    );
                  } else {
                    final itemState = ref.watch(showActiveAdsProvider);
                    return itemState.when(
                      data: (adState) {
                        if (adState.items.isEmpty) {
                          return CustomScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            controller: activeAdScrollController,
                            slivers: [
                              CupertinoSliverRefreshControl(
                                onRefresh: () async {
                                  await ref
                                      .read(showActiveAdsProvider.notifier)
                                      .refreshItems();
                                },
                              ),
                              SliverFillRemaining(
                                child: Center(
                                    child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/emoji.png',
                                      height: 100,
                                      width: 100,
                                    ),
                                    Text(
                                      'No Active Ads',
                                      style: GoogleFonts.roboto(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                              ),
                            ],
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: CustomScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            controller: activeAdScrollController,
                            slivers: [
                              CupertinoSliverRefreshControl(
                                onRefresh: () async {
                                  await ref
                                      .read(showActiveAdsProvider.notifier)
                                      .refreshItems();
                                },
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (ctx, index) {
                                    final item = adState.items[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // Navigator.of(context,
                                        //         rootNavigator: true)
                                        //     .push(
                                        //   CupertinoPageRoute(
                                        //     builder: (ctx) =>
                                        //         ProductDetailScreen(
                                        //       item: item,
                                        //       yourAd: true,
                                        //     ),
                                        //   ),
                                        // );
                                      },
                                      child: AdCard(
                                        cardIndex: index,
                                        ad: item,
                                        adSold: sellTheItem,
                                        isSold: false,
                                      ),
                                    );
                                  },
                                  childCount: adState.items.length,
                                ),
                              ),
                              if (adState.isLoadingMore)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CupertinoActivityIndicator(
                                            radius: 15,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Fetching Content...',
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      error: (error, stack) =>
                          Center(child: Text('Error: $error')),
                      loading: () {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CupertinoActivityIndicator(
                                radius: 15,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Loading...',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
                error: (error, _) => Center(child: Text('Error: $error')),
                loading: () => Center(child: CupertinoActivityIndicator()),
              );
            }
          },
          error: (error, _) => Center(child: Text('Error: $error')),
          loading: () => Center(child: CupertinoActivityIndicator()),
        ),
      ),
    );
  }
}
