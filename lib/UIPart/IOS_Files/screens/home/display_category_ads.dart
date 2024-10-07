import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:flutter/Cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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
    // ref
    //     .read(showCategoryAdsProvider.notifier)
    //     .setCategoryAndSubCategory(widget.categoryName, widget.subCategoryName);
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
     //   ref.read(showCategoryAdsProvider.notifier).fetchNextCategoryBatch();
      }
    });
    return SafeArea(
      child: CustomScrollView(
        controller: categoryAdScrollController,
        slivers: [
          // CategoryItemsList(
          //   handler: handler,
          //   category: widget.categoryName,
          //   subCategory: widget.subCategoryName,
          // ),
          // NoMoreCategoryItems(
          //   category: widget.categoryName,
          //   subCategory: widget.subCategoryName,
          // ),
          // OnGoingBottomWidgetCategory(
          //   category: widget.categoryName,
          //   subCategory: widget.subCategoryName,
          // ),
        ],
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
//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) {
//           print('getting data');
//           final catAd = items[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(
//                 CupertinoPageRoute(
//                   builder: (ctx) {
//                     return ProductDetailScreen(
//                       item: catAd,
//                       yourAd: catAd.userid == handler.newUser.user!.uid,
//                     );
//                   },
//                 ),
//               );
//             },
//             child: Column(
//               children: [
//                 AspectRatio(
//                   aspectRatio: 2.5,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       border: Border.all(
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 4,
//                           child: Padding(
//                             padding: const EdgeInsets.only(
//                               top: 8,
//                               left: 15,
//                               bottom: 8,
//                             ),
//                             child: Stack(
//                               children: [
//                                 Image.asset(
//                                   'assets/images/placeholder.jpg',
//                                 ),
//                                 Positioned(
//                                   child: Image.network(
//                                     catAd.images[0],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 6,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   '₹ ${catAd.price}',
//                                   style: GoogleFonts.roboto(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 22,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 4,
//                                 ),
//                                 Text(
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   catAd.adTitle,
//                                   style: GoogleFonts.roboto(),
//                                 ),
//                                 const SizedBox(
//                                   height: 4,
//                                 ),
//                                 Text(
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   catAd.postedBy,
//                                   style: GoogleFonts.roboto(
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(
//                                   height: 4,
//                                 ),
//                                 Text(
//                                   catAd.createdAt,
//                                   style: GoogleFonts.roboto(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
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
