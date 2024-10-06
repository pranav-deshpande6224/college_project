import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/screens/home/product_detail_screen.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/show_ads.dart';
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
  final ScrollController activeAdScrollController = ScrollController();
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    activeAdScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    activeAdScrollController.addListener(() {
      double maxScroll = activeAdScrollController.position.maxScrollExtent;
      double currentScroll = activeAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(showActiveAdsProvider.notifier).fetchNextBatch();
      }
    });
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'MY POSTED ADS',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
          child: CustomScrollView(
        controller: activeAdScrollController,
        slivers: [ItemsList(), NoMoreItems(), OnGoingBottomWidget()],
      )),
    );
  }
}

class ItemsList extends ConsumerWidget {
  const ItemsList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(showActiveAdsProvider);
    return state.when(
      data: (items) {
        return items.isEmpty
            ? SliverToBoxAdapter(
                child: Text('No ADS of Your'),
              )
            : ItemListBuilder(
                items: items,
              );
      },
      error: (e, stk) {
        return SliverToBoxAdapter(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.alarm),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Something Went Wrong!",
                  style: GoogleFonts.roboto(
                    color: CupertinoColors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        return SliverToBoxAdapter(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(
                  radius: 15,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Loading...",
                  style: GoogleFonts.roboto(
                    color: CupertinoColors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onGoingLoading: (List<Item> items) {
        return ItemListBuilder(
          items: items,
        );
      },
      onGoingError: (List<Item> items, Object? e, StackTrace? stk) {
        return ItemListBuilder(
          items: items,
        );
      },
    );
  }
}

class ItemListBuilder extends StatelessWidget {
  final List<Item> items;
  const ItemListBuilder({required this.items, super.key});
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (ctx) => ProductDetailScreen(
                    item: item,
                    yourAd: true,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: AdCard(
                cardIndex: index,
                ad: item,
                // adSold: markAsSold,
                isSold: false,
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

class NoMoreItems extends ConsumerWidget {
  const NoMoreItems({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(showActiveAdsProvider);
    return SliverToBoxAdapter(
      child: state.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          data: (items) {
            final nomoreItems =
                ref.read(showActiveAdsProvider.notifier).noMoreAds;
            return nomoreItems
                ? Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "No More ADS Found!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
    );
  }
}

class OnGoingBottomWidget extends StatelessWidget {
  const OnGoingBottomWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(40),
      sliver: SliverToBoxAdapter(
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(showActiveAdsProvider);
            final noMoreAds =
                ref.read(showActiveAdsProvider.notifier).noMoreAds;
            return state.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              onGoingLoading: (items) => noMoreAds
                  ? const SizedBox.shrink()
                  : const Center(
                      child: CupertinoActivityIndicator(),
                    ),
              onGoingError: (items, e, stk) => Center(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.alarm),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Something Went Wrong!",
                      style: GoogleFonts.roboto(
                        color: CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



// Consumer(
//           builder: (context, ref, child) {
//             final index = ref.watch(adsIndexProvider);
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                     flex: 1,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               if (index != 0) {
//                                 ref.read(adsIndexProvider.notifier).setIndex(0);
//                               }
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: index == 0
//                                     ? CupertinoColors.activeBlue
//                                     : null,
//                                 border: Border.all(width: 0.2),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'Active Ads',
//                                   style: GoogleFonts.roboto(
//                                     fontWeight:
//                                         index == 0 ? FontWeight.bold : null,
//                                     color: index == 0
//                                         ? CupertinoColors.white
//                                         : null,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               if (index != 1) {
//                                 ref.read(adsIndexProvider.notifier).setIndex(1);
//                               }
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: index == 1
//                                     ? CupertinoColors.activeBlue
//                                     : null,
//                                 border: Border.all(width: 0.2),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'Sold Ads',
//                                   style: GoogleFonts.roboto(
//                                     fontWeight:
//                                         index == 1 ? FontWeight.bold : null,
//                                     color: index == 1
//                                         ? CupertinoColors.white
//                                         : null,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )),
//                 Expanded(
//                   flex: 9,
//                   child: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: DisplayAds(index: index),
//                   ),
//                 )
//               ],
//             );
//           },
//         ),