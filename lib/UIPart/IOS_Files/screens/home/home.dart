import 'package:college_project/UIPart/IOS_Files/screens/home/display_home_ads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  // late AuthHandler handler;
  // late Future<List<Item>> ads;

  @override
  void initState() {
    //handler = AuthHandler.authHandlerInstance;
    // ads = getAllData();
    super.initState();
  }

  // Future<List<Item>> getAllData() async {
  //   List<Item> allItems = [];
  //   try {
  //     final fbCloudFireStore = handler.fireStore;
  //     QuerySnapshot<Map<String, dynamic>> data = await fbCloudFireStore
  //         .collection('AllAds')
  //         .orderBy('createdAt', descending: true)
  //         .limit(10)
  //         .get();
  //     for (final doc in data.docs) {
  //       DocumentReference adRef = doc['adReference'];
  //       DocumentSnapshot originalAdSnapshot = await adRef.get();
  //       if (originalAdSnapshot.exists) {
  //         Map<String, dynamic> snaphsot =
  //             originalAdSnapshot.data() as Map<String, dynamic>;
  //         Timestamp createdAt = originalAdSnapshot.get('createdAt');
  //         String formattedDate =
  //             DateFormat('dd/MM/yyyy').format(createdAt.toDate());
  //         final adData =
  //             Item.fromJson(snaphsot, originalAdSnapshot.id, formattedDate);
  //         allItems.add(adData);
  //       }
  //     }
  //     return allItems;
  //   } catch (e) {
  //     throw e.toString();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'IIT Jodhpur',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: DisplayHomeAds(),
        ),
      ),
    );
  }
}



 // FutureBuilder(
          //   future: ads,
          //   builder: (ctx, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Center(
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             const CupertinoActivityIndicator(
          //               radius: 15,
          //             ),
          //             const SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               'Loading...',
          //               style: GoogleFonts.roboto(
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ],
          //         ),
          //       );
          //     }
          //     if (snapshot.hasError) {
          //       return Text('${snapshot.error}');
          //     }

          //     return SingleChildScrollView(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           const SizedBox(
          //             height: 50,
          //             child: CupertinoSearchTextField(
          //               placeholder: 'Find Mobiles, Monitor and more...',
          //             ),
          //           ),
          //           const SizedBox(
          //             height: 10,
          //           ),
          //           Text(
          //             'Browse Categories',
          //             style: GoogleFonts.roboto(
          //               fontWeight: FontWeight.w600,
          //               fontSize: 20,
          //             ),
          //           ),
          //           const SizedBox(
          //             height: 10,
          //           ),
          //           AspectRatio(
          //             aspectRatio: 3.5,
          //             child: SizedBox(
          //               child: GestureDetector(
          //                 onTap: () {},
          //                 child: ListView.builder(
          //                   scrollDirection: Axis.horizontal,
          //                   itemCount: categoryList.length,
          //                   itemBuilder: (ctx, index) {
          //                     return Row(
          //                       children: [
          //                         SizedBox(
          //                             width: 120,
          //                             height: double.infinity,
          //                             child: Column(
          //                               children: [
          //                                 Expanded(
          //                                   flex: 6,
          //                                   child: Icon(
          //                                     categoryList[index].icon,
          //                                     size: 50,
          //                                     color: CupertinoColors.activeBlue,
          //                                   ),
          //                                 ),
          //                                 Expanded(
          //                                   flex: 4,
          //                                   child: Text(
          //                                     textAlign: TextAlign.center,
          //                                     categoryList[index].categoryTitle,
          //                                     style: GoogleFonts.roboto(
          //                                       fontWeight: FontWeight.w600,
          //                                       fontSize: 14,
          //                                     ),
          //                                   ),
          //                                 )
          //                               ],
          //                             )),
          //                         const SizedBox(
          //                           width: 10,
          //                         )
          //                       ],
          //                     );
          //                   },
          //                 ),
          //               ),
          //             ),
          //           ),
          //           const SizedBox(
          //             height: 5,
          //           ),
          //           Text(
          //             'Fresh Recomendations',
          //             style: GoogleFonts.roboto(
          //               fontWeight: FontWeight.w600,
          //               fontSize: 20,
          //             ),
          //           ),
          //           const SizedBox(
          //             height: 10,
          //           ),
          //           GridView.builder(
          //             shrinkWrap: true,
          //             physics: const NeverScrollableScrollPhysics(),
          //             gridDelegate:
          //                 const SliverGridDelegateWithFixedCrossAxisCount(
          //               crossAxisCount: 2,
          //               childAspectRatio: 3 / 4,
          //               crossAxisSpacing: 10,
          //               mainAxisSpacing: 10,
          //             ),
          //             itemCount: snapshot.data!.length,
          //             itemBuilder: (ctx, index) {
          //               final ad = snapshot.data![index];
          //               return GestureDetector(
          //                 onTap: () {
          //                   Navigator.of(context, rootNavigator: true).push(
          //                     CupertinoPageRoute(
          //                       builder: (ctx) {
          //                         return ProductDetailScreen(
          //                           item: ad,
          //                           yourAd: false,
          //                         );
          //                       },
          //                     ),
          //                   );
          //                 },
          //                 child: Container(
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(10),
          //                   ),
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(5.0),
          //                     child: Column(
          //                       children: [
          //                         Expanded(
          //                           flex: 9,
          //                           child: Stack(
          //                             children: [
          //                               ClipRRect(
          //                                 child: Image.asset(
          //                                   'assets/images/placeholder.jpg',
          //                                 ),
          //                               ),
          //                               Positioned(
          //                                 top: 0,
          //                                 left: 0,
          //                                 right: 0,
          //                                 bottom: 0,
          //                                 child: ClipRRect(
          //                                   child: Image.network(
          //                                     ad.images[0],
          //                                   ),
          //                                 ),
          //                               )
          //                             ],
          //                           ),
          //                         ),
          //                         Expanded(
          //                           flex: 4,
          //                           child: Column(
          //                             mainAxisAlignment: MainAxisAlignment.end,
          //                             children: [
          //                               Text(
          //                                 '₹ ${ad.price.toInt()}',
          //                                 style: GoogleFonts.roboto(
          //                                   fontWeight: FontWeight.w800,
          //                                   fontSize: 19,
          //                                 ),
          //                               ),
          //                               const SizedBox(
          //                                 height: 5,
          //                               ),
          //                               Text(
          //                                 ad.adTitle,
          //                                 maxLines: 1,
          //                                 overflow: TextOverflow.ellipsis,
          //                                 style: GoogleFonts.roboto(),
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                         Expanded(
          //                           flex: 2,
          //                           child: Padding(
          //                             padding: const EdgeInsets.only(top: 5),
          //                             child: Text(
          //                               maxLines: 1,
          //                               overflow: TextOverflow.ellipsis,
          //                               ad.postedBy,
          //                               style: GoogleFonts.roboto(
          //                                 fontWeight: FontWeight.w600,
          //                               ),
          //                             ),
          //                           ),
          //                         )
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               );
          //             },
          //           )
          //         ],
          //       ),
          //     );
          //   },
          // ),