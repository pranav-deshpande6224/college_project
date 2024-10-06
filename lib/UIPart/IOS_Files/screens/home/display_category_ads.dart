import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/screens/home/product_detail_screen.dart';
import 'package:college_project/UIPart/IOS_Files/screens/myads/my_sold_ads.dart';
import 'package:college_project/UIPart/Providers/category_provider.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/category_ads_pagination.dart';
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
  final categoryAdScrollController = ScrollController();
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    categoryAdScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    categoryAdScrollController.addListener(() {
      double maxScroll = categoryAdScrollController.position.maxScrollExtent;
      double currentScroll = categoryAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(showCategoryAdsProvider.notifier).fetchNextBatch();
      }
    });
    return SafeArea(
      child: CustomScrollView(
        controller: categoryAdScrollController,
        slivers: [
          ItemsList(
            handler: handler,
            category: widget.categoryName,
            subCategory: widget.subCategoryName,
          ),
          NoMoreItems(),
          OnGoingBottomWidget(),
        ],
      ),
    );
  }
}

class ItemsList extends ConsumerWidget {
  final String category;
  final String subCategory;
  final AuthHandler handler;
  const ItemsList(
      {required this.handler,
      required this.category,
      required this.subCategory,
      super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
        .read(categoryAndSubCatProvider.notifier)
        .setCategoryAndSubCategory(category, subCategory);
    final state = ref.watch(showCategoryAdsProvider);
    return state.when(
      data: (data) {
        return data.isEmpty
            ? Text('No Ads Found')
            : ItemsListBuilder(
                items: data,
                handler: handler,
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

class ItemsListBuilder extends StatelessWidget {
  final AuthHandler handler;
  final List<Item> items;
  const ItemsListBuilder(
      {super.key, required this.items, required this.handler});
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final catAd = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (ctx) {
                    return ProductDetailScreen(
                      item: catAd,
                      yourAd: catAd.userid == handler.newUser.user!.uid,
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
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 15,
                              bottom: 8,
                            ),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/placeholder.jpg',
                                ),
                                Positioned(
                                  child: Image.network(
                                    catAd.images[0],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹ ${catAd.price}',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  catAd.adTitle,
                                  style: GoogleFonts.roboto(),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  catAd.postedBy,
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  catAd.createdAt,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w500,
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
    );
  }
}

class NoMoreItems extends ConsumerWidget {
  const NoMoreItems({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(showCategoryAdsProvider);
    return SliverToBoxAdapter(
      child: state.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          data: (items) {
            final noMoreItems =
                ref.read(showCategoryAdsProvider.notifier).noMoreAds;
            return noMoreItems
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "No More Items Found!",
                      textAlign: TextAlign.center,
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
        child: Consumer(builder: (context, ref, child) {
          final state = ref.watch(showCategoryAdsProvider);
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



// FutureBuilder<List<Item>>(
//       future: ads,
//       builder: (ctx, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const CupertinoActivityIndicator(
//                   radius: 15,
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   'Loading...',
//                   style: GoogleFonts.roboto(),
//                 )
//               ],
//             ),
//           );
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text(snapshot.error.toString()));
//         }
//         final items = snapshot.data!;
//         return CustomScrollView(
//           slivers: [
//             CupertinoSliverRefreshControl(onRefresh: () async {
//               getCategoryAds();
//             }),
//             SliverPadding(
//               padding: const EdgeInsets.all(10.0),
//               sliver: SliverList.builder(
//                 itemCount: items.length,
//                 itemBuilder: (ctx, index) {
//                   final catAd = items[index];
//                   return 
//                 },
//               ),
//             )
//           ],
//         );
//       },
//     );
