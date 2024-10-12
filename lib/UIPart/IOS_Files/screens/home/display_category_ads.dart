import 'package:cached_network_image/cached_network_image.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/internet_provider.dart';
import 'package:college_project/UIPart/IOS_Files/screens/home/product_detail_screen.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/category_ads_pagination.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/Cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayCategoryAds extends ConsumerStatefulWidget {
  final String categoryName;
  final String subCategoryName;
  const DisplayCategoryAds(
      {required this.categoryName, required this.subCategoryName, super.key});

  @override
  ConsumerState<DisplayCategoryAds> createState() => _DisplayCategoryAdsState();
}

class _DisplayCategoryAdsState extends ConsumerState<DisplayCategoryAds> {
  late AuthHandler handler;
  final ScrollController categoryAdScrollController = ScrollController();
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(showCatAdsProvider.notifier).fetchInitialItems(
            widget.categoryName,
            widget.subCategoryName,
          );
    });
    categoryAdScrollController.addListener(() {
      double maxScroll = categoryAdScrollController.position.maxScrollExtent;
      double currentScroll = categoryAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref
            .read(showCatAdsProvider.notifier)
            .fetchMoreItems(widget.categoryName, widget.subCategoryName);
      }
    });
  }

  @override
  void dispose() {
    categoryAdScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(showCatAdsProvider.notifier).resetState();
      },
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
                            .read(showCatAdsProvider.notifier)
                            .refreshItems(
                                widget.categoryName, widget.subCategoryName);
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
                            onPressed: () async {
                              final x = ref.refresh(connectivityProvider);
                              final y = ref.refresh(internetCheckerProvider);
                              debugPrint(x.toString());
                              debugPrint(y.toString());
                              await ref
                                  .read(showCatAdsProvider.notifier)
                                  .refreshItems(widget.categoryName,
                                      widget.subCategoryName);
                            })
                      ],
                    ),
                  );
                } else {
                  final catItemState = ref.watch(showCatAdsProvider);
                  return catItemState.when(data: (CategoryAdsState data) {
                    return CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: categoryAdScrollController,
                      slivers: [
                        CupertinoSliverRefreshControl(),
                        data.items.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/emoji.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                      Text(
                                        'No Ads Found',
                                        style: GoogleFonts.roboto(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.all(8.0),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    childCount: data.items.length,
                                    (context, index) {
                                      final catAd = data.items[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (ctx) {
                                                return ProductDetailScreen(
                                                  item: catAd,
                                                  yourAd: catAd.userid ==
                                                      handler.newUser.user!.uid,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 2.5,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 8,
                                                            left: 15,
                                                            bottom: 8,
                                                          ),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                catAd.images[0],
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                (context, url) {
                                                              return const Center(
                                                                child: Icon(
                                                                  CupertinoIcons
                                                                      .photo,
                                                                  size: 30,
                                                                ),
                                                              );
                                                            },
                                                            errorWidget:
                                                                (context, url,
                                                                    error) {
                                                              return const Center(
                                                                child: Icon(
                                                                  CupertinoIcons
                                                                      .photo,
                                                                  size: 30,
                                                                ),
                                                              );
                                                            },
                                                          )),
                                                    ),
                                                    Expanded(
                                                      flex: 6,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '₹ ${catAd.price}',
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 22,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              catAd.adTitle,
                                                              style: GoogleFonts
                                                                  .roboto(),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              catAd.postedBy,
                                                              style: GoogleFonts.roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              catAd.createdAt,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            )
                                                          ],
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
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                        if (data.isLoadingMore)
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
                                    Text(
                                      'Fetching Content...',
                                      style: TextStyle(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }, loading: () {
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
                          const Text('Loading...')
                        ],
                      ),
                    );
                  }, error: (Object error, StackTrace stackTrace) {
                    return Center(child: Text('Error: $error'));
                  });
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
    );
  }
}

// class CategoryItemsList extends StatelessWidget {
//   final AuthHandler handler;
//   final String category;
//   final String subCategory;
//   const CategoryItemsList(
//       {required this.handler,
//       required this.category,
//       required this.subCategory,
//       super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (ctx, ref, child) {
//     //    final state = ref.watch(showCategoryAdsProvider);
//         print(state.toString());
//         return state.when(data: (items) {
//           return items.isEmpty
//               ? SliverToBoxAdapter(
//                   child: Text('No Ads'),
//                 )
//               : CategoryItemsListBuilder(
//                   handler: handler,
//                   items: items,
//                 );
//         }, loading: () {
//           print('Always loading');
//           return SliverFillRemaining(
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CupertinoActivityIndicator(
//                     radius: 15,
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     "Loading...",
//                     style: GoogleFonts.poppins(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }, error: (e, stk) {
//           return SliverToBoxAdapter(
//               child: Center(
//             child: Text('Something Went Wrong'),
//           ));
//         }, onGoingLoading: (items) {
//           return CategoryItemsListBuilder(items: items, handler: handler);
//         }, onGoingError: (items, e, stk) {
//           return CategoryItemsListBuilder(
//             items: items,
//             handler: handler,
//           );
//         });
//       },
//     );
//   }
// }

// class CategoryItemsListBuilder extends StatelessWidget {
//   final List<Item> items;
//   final AuthHandler handler;
//   const CategoryItemsListBuilder(
//       {required this.items, required this.handler, super.key});

//   @override
//   Widget build(BuildContext context) {
//     
//   }
// }

// class OnGoingBottomWidgetCategory extends StatelessWidget {
//   final String category;
//   final String subCategory;
//   const OnGoingBottomWidgetCategory(
//       {required this.category, required this.subCategory, super.key});
//   @override
//   Widget build(BuildContext context) {
//     return SliverToBoxAdapter(
//       child: Consumer(
//         builder: (context, ref, child) {
//           final state = ref.watch(showCategoryAdsProvider);
//           return state.maybeWhen(
//             orElse: () => const SizedBox.shrink(),
//             onGoingLoading: (items) {
//               return const Center(
//                 child: CupertinoActivityIndicator(),
//               );
//             },
//             onGoingError: (items, e, stk) {
//               return const Center(
//                 child: Text('Something Went Wrong'),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
