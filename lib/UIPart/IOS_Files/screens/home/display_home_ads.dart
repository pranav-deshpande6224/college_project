import 'package:cached_network_image/cached_network_image.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/category.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/screens/home/product_detail_screen.dart';
import 'package:college_project/UIPart/IOS_Files/screens/sell/detail_screen.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/home_ads.dart';
import 'package:college_project/constants/constants.dart';
import 'package:flutter/Cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayHomeAds extends ConsumerStatefulWidget {
  const DisplayHomeAds({super.key});
  @override
  ConsumerState<DisplayHomeAds> createState() => _DisplayHomeAdsState();
}

class _DisplayHomeAdsState extends ConsumerState<DisplayHomeAds> {
  late AuthHandler handler;
  final ScrollController homeAdScrollController = ScrollController();
  final List<SellCategory> categoryList = const [
    SellCategory(
        icon: CupertinoIcons.phone,
        categoryTitle: Constants.mobileandTab,
        subCategory: [
          Constants.mobilePhone,
          Constants.tablet,
          Constants.earphoneHeadPhoneSpeakers,
          Constants.smartWatches,
          Constants.mobileChargerLaptopCharger
        ]),
    SellCategory(
        icon: CupertinoIcons.device_laptop,
        categoryTitle: Constants.latopandmonitor,
        subCategory: [
          Constants.laptop,
          Constants.monitor,
          Constants.laptopAccessories
        ]),
    SellCategory(
      icon: CupertinoIcons.car,
      categoryTitle: Constants.cycleandAccessory,
      subCategory: [Constants.cycle, Constants.cycleAccesory],
    ),
    SellCategory(
        icon: CupertinoIcons.building_2_fill,
        categoryTitle: Constants.hostelAccesories,
        subCategory: [
          Constants.whiteBoard,
          Constants.bedPillowCushions,
          Constants.backPack,
          Constants.bottle,
          Constants.trolley,
          Constants.wheelChair,
          Constants.curtain
        ]),
    SellCategory(
      icon: CupertinoIcons.book,
      categoryTitle: Constants.booksandSports,
      subCategory: [
        Constants.booksSubCat,
        Constants.gym,
        Constants.musical,
        Constants.sportsEquipment
      ],
    ),
    SellCategory(
        icon: CupertinoIcons.tv,
        categoryTitle: Constants.electronicandAppliances,
        subCategory: [
          Constants.calculator,
          Constants.hddSSD,
          Constants.router,
          Constants.tripod,
          Constants.ironBox,
          Constants.camera
        ]),
    SellCategory(
      icon: CupertinoIcons.person_crop_circle,
      categoryTitle: Constants.fashion,
      subCategory: [
        Constants.mensFashion,
        Constants.womensFashion,
      ],
    ),
  ];

  @override
  void dispose() {
    homeAdScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    homeAdScrollController.addListener(() {
      double maxScroll = homeAdScrollController.position.maxScrollExtent;
      double currentScroll = homeAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(showHomeAdsProvider.notifier).fetchNextBatch();
      }
    });
    return CustomScrollView(
      controller: homeAdScrollController,
      slivers: [
        HomeItemsList(
          handler: handler,
          categoryList: categoryList,
          controller: homeAdScrollController,
        ),
        OnGoingBottomHomeWidget(),
      ],
    );
  }
}

class HomeItemsList extends ConsumerWidget {
  final AuthHandler handler;
  final List<SellCategory> categoryList;
  final ScrollController controller;
  const HomeItemsList(
      {required this.controller,
      required this.handler,
      required this.categoryList,
      super.key});
  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(showHomeAdsProvider);
    return state.when(data: (items) {
      return SliverToBoxAdapter(
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 50,
              child: CupertinoSearchTextField(
                placeholder: 'Find Mobiles, Monitor and more...',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Browse Categories',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            AspectRatio(
              aspectRatio: 3.5,
              child: SizedBox(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryList.length,
                  itemBuilder: (ctx, index) {
                    final category = categoryList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(
                            builder: (ctx) => DetailScreen(
                              categoryName: category.categoryTitle,
                              subCategoryList: category.subCategory,
                              isPostingData: false,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            height: double.infinity,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Icon(
                                    categoryList[index].icon,
                                    size: 50,
                                    color: CupertinoColors.activeBlue,
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    categoryList[index].categoryTitle,
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(
              'Fresh Recomendations',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            HomeItemsListBuilder(
              handler: handler,
              items: items,
            ),
          ],
        ),
      );
    }, loading: () {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(
                radius: 15,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Loading...',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }, error: (e, stk) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            'Something Went Wrong!',
            style: GoogleFonts.roboto(),
          ),
        ),
      );
    }, onGoingLoading: (items) {
      return SliverToBoxAdapter(
        child: HomeItemsListBuilder(
          handler: handler,
          items: items,
        ),
      );
    }, onGoingError: (items, e, stk) {
      return SliverToBoxAdapter(
        child: HomeItemsListBuilder(
          handler: handler,
          items: items,
        ),
      );
    });
  }
}

class HomeItemsListBuilder extends StatelessWidget {
  final List<Item> items;
  final AuthHandler handler;
  const HomeItemsListBuilder(
      {required this.handler, required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final ad = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (ctx) {
                  return ProductDetailScreen(
                    item: ad,
                    yourAd: ad.userid == handler.newUser.user!.uid,
                  );
                },
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: CachedNetworkImage(
                      imageUrl: ad.images[0],
                      errorWidget: (context, url, error) {
                        return const Icon(
                          CupertinoIcons.photo_on_rectangle,
                          size: 50,
                        );
                      },
                      placeholder: (context, url) {
                        return Image.asset('assets/images/placeholder.jpg');
                      },
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '₹ ${ad.price.toInt()}',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          ad.adTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(),
                        ),
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          ad.postedBy,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}

class OnGoingBottomHomeWidget extends StatelessWidget {
  const OnGoingBottomHomeWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(40),
      sliver: SliverToBoxAdapter(
        child: Consumer(builder: (context, ref, child) {
          final state = ref.watch(showHomeAdsProvider);
          return state.maybeWhen(
            orElse: () => const SizedBox.shrink(),
            onGoingLoading: (items) =>
                const Center(child: CupertinoActivityIndicator()),
            onGoingError: (items, e, stk) => Center(
              child: Text(
                "Something Went Wrong!",
              ),
            ),
          );
        }),
      ),
    );
  }
}


// class DisplayHomeAds extends ConsumerStatefulWidget {
//   const DisplayHomeAds({super.key});

//   @override
//   ConsumerState<DisplayHomeAds> createState() => _DisplayHomeAdsState();
// }

// class _DisplayHomeAdsState extends ConsumerState<DisplayHomeAds> {

//   @override
//   Widget build(BuildContext context) {

//     final state = ref.watch(showHomeAdsProvider);
//     return state.when(
//       data: (items) {
//         return CustomScrollView(
//           controller: homeAdScrollController,
//           slivers: items.isEmpty
//               ? [

//                 ]
//               : [
//                   
//                   // HomeItemsListBuilder(
//                   //   items: items,
//                   //   handler: handler,
//                   // ),
//                   NoMoreHomeItems(),
//                   OnGoingBottomHomeWidget()
//                 ],
//         );
//       },
//       loading: () {
//         return Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CupertinoActivityIndicator(
//                 radius: 15,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 "Loading...",
//                 style: GoogleFonts.roboto(
//                   color: CupertinoColors.black,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//       error: (Object? e, StackTrace? stk) {
//         return SliverToBoxAdapter(
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(CupertinoIcons.alarm),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   "Something Went Wrong!",
//                   style: GoogleFonts.roboto(
//                     color: CupertinoColors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       onGoingLoading: (List<Item> items) {
//         return SliverToBoxAdapter();
//         // HomeItemsListBuilder(
//         //   items: items,
//         //   handler: handler,
//         // );
//       },
//       onGoingError: (List<Item> items, Object? e, StackTrace? stk) {
//         return SliverToBoxAdapter();
//         //  HomeItemsListBuilder(
//         //   items: items,
//         //   handler: handler,
//         // );
//       },
//     );
//   }
// }

// // class HomeItemsListBuilder extends StatelessWidget {
// //   final List<Item> items;
// //   final AuthHandler handler;
// //   const HomeItemsListBuilder({
// //     required this.items,
// //     required this.handler,
// //     super.key,
// //   });
// //   @override
// //   Widget build(BuildContext context) {
// //     return
// //   }
// // }

// class NoMoreHomeItems extends ConsumerWidget {
//   const NoMoreHomeItems({super.key});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(showHomeAdsProvider);
//     return SliverToBoxAdapter(
//       child: state.maybeWhen(
//           orElse: () => const SizedBox.shrink(),
//           data: (items) {
//             final nomoreItems =
//                 ref.read(showHomeAdsProvider.notifier).noMoreAds;
//             return nomoreItems
//                 ? Padding(
//                     padding: EdgeInsets.only(bottom: 20),
//                     child: Text(
//                       "No More ADS Found!",
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.roboto(
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   )
//                 : const SizedBox.shrink();
//           }),
//     );
//   }
// }

// class OnGoingBottomHomeWidget extends StatelessWidget {
//   const OnGoingBottomHomeWidget({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return SliverToBoxAdapter(
//       child: Consumer(
//         builder: (context, ref, child) {
//           final state = ref.watch(showHomeAdsProvider);
//           final noMoreAds = ref.read(showHomeAdsProvider.notifier).noMoreAds;
//           return state.maybeWhen(
//             orElse: () => const SizedBox.shrink(),
//             onGoingLoading: (items) => noMoreAds
//                 ? const SizedBox.shrink()
//                 : const Center(
//                     child: CupertinoActivityIndicator(),
//                   ),
//             onGoingError: (items, e, stk) => Center(
//               child: Column(
//                 children: [
//                   Icon(CupertinoIcons.alarm),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     "Something Went Wrong!",
//                     style: GoogleFonts.roboto(
//                       color: CupertinoColors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ############################################

// // homeAds.when(
// //       data: (data) {
// //         return CustomScrollView(
// //           slivers: [
// //             NotificationListener(
// //               onNotification: (ScrollNotification scrollInfo) {
// //                 if (scrollInfo.metrics.pixels ==
// //                         scrollInfo.metrics.maxScrollExtent &&
// //                     homeAdsNotifier.hasMoreHomeAds) {
// //                   homeAdsNotifier.loadMoreHomeAds();
// //                 }
// //                 return false;
// //               },
// //               child: SliverGrid.builder(
// //                 itemCount: data.length + 1,
// //                 itemBuilder: (ctx, index) {
// //                   if (index == data.length) {
// //                     if (homeAdsNotifier.hasMoreHomeAds) {
// //                       homeAdsNotifier.loadMoreHomeAds();
// //                       return Container(
// //                         width: double.infinity,
// //                         color: CupertinoColors.activeGreen,
// //                         child: const Center(
// //                           child: CupertinoActivityIndicator(),
// //                         ),
// //                       );
// //                     } else {
// //                       return const SizedBox();
// //                     }
// //                   }

// //                 },
// //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                   crossAxisCount: 2,
// //                   childAspectRatio: 3 / 4,
// //                   crossAxisSpacing: 10,
// //                   mainAxisSpacing: 10,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //       error: (error, stackTrace) {
// //         return Center(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               //TODO Need to Handle Error case also
// //               Text(error.toString())
// //             ],
// //           ),
// //         );
// //       },
// //       loading: () {
// //         return Center(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               const CupertinoActivityIndicator(
// //                 radius: 15,
// //               ),
// //               const SizedBox(
// //                 height: 5,
// //               ),
// //               Text(
// //                 'Loading...',
// //                 style: GoogleFonts.roboto(
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               )
// //             ],
// //           ),
// //         );
// //       },
// //     );
