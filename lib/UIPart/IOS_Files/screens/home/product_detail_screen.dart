import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/internet_provider.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/screens/chats/chatting_screen.dart';
import 'package:college_project/UIPart/IOS_Files/screens/home/image_detail_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final DocumentReference<Map<String, dynamic>> documentReference;
  const ProductDetailScreen({
    required this.documentReference,
    super.key,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  String getDate(Timestamp timeStamp) {
    DateTime dateTime = timeStamp.toDate();
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Widget getExtraDetails(Item item) {
    if (item.brand != '') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Brand',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.activeBlue,
            ),
          ),
          Text(
            item.brand,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    if (item.tabletType != '') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tablet',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.activeBlue,
            ),
          ),
          Text(
            item.tabletType,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    if (item.chargerType != '') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charger',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.activeBlue,
            ),
          ),
          Text(
            item.chargerType,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Product Details',
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
                        // To Do Something
                      },
                    )
                  ],
                ),
              );
            } else {
              return internetState.when(
                data: (bool internet) {
                  if (!internet) {
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
                              // To Do Something
                            },
                          )
                        ],
                      ),
                    );
                  } else {
                    return StreamBuilder(
                      stream: widget.documentReference.snapshots(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Loading...',
                                  style: GoogleFonts.roboto(),
                                )
                              ],
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Something went wrong"),
                          );
                        }
                        Timestamp? timeStamp =
                            snapshot.data!.data()!['createdAt'];
                        timeStamp ??= Timestamp.fromMicrosecondsSinceEpoch(
                            DateTime.now().millisecondsSinceEpoch);
                        final item = Item.fromJson(
                          snapshot.data!.data()!,
                          snapshot.data!.id,
                          snapshot.data!,
                          snapshot.data!.reference,
                        );
                        return Column(
                          children: [
                            Expanded(
                              flex: 9,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, left: 8, right: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              fullscreenDialog: true,
                                              builder: (ctx) =>
                                                  ImageDetailScreen(
                                                imageUrl: item.images,
                                              ),
                                            ),
                                          );
                                        },
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: CarouselSlider(
                                            items: item.images.map(
                                              (e) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: CupertinoColors
                                                          .systemBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                        color: CupertinoColors
                                                            .systemGrey,
                                                      ),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: e,
                                                      fit: BoxFit.contain,
                                                      placeholder:
                                                          (context, url) {
                                                        return const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .photo,
                                                            size: 30,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                          ),
                                                        );
                                                      },
                                                      errorWidget: (context,
                                                          url, error) {
                                                        return const Center(
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .photo,
                                                            size: 30,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).toList(),
                                            options: CarouselOptions(
                                              disableCenter: true,
                                              autoPlay: true,
                                              enableInfiniteScroll: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₹ ${item.price.toInt()}',
                                        style: GoogleFonts.roboto(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        item.adTitle,
                                        style: GoogleFonts.roboto(
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Description',
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: CupertinoColors.activeBlue,
                                        ),
                                      ),
                                      Text(
                                        item.adDescription,
                                        style: GoogleFonts.roboto(fontSize: 22),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      getExtraDetails(item),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Posted By',
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: CupertinoColors.activeBlue,
                                            ),
                                          ),
                                          Text(
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            handler.newUser.user!.uid ==
                                                    item.userid
                                                ? 'You'
                                                : item.postedBy,
                                            style: GoogleFonts.roboto(
                                              fontSize: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Posted At',
                                            style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: CupertinoColors.activeBlue,
                                            ),
                                          ),
                                          Text(
                                            getDate(item.timestamp),
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            handler.newUser.user!.uid == item.userid
                                ? const SizedBox()
                                : Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child: CupertinoButton(
                                          color: CupertinoColors.activeBlue,
                                          onPressed: item.isAvailable
                                              ? () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .push(
                                                    CupertinoPageRoute(
                                                      builder: (ctx) =>
                                                          ChattingScreen(
                                                        item: item,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              : null,
                                          child: Text(
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              color: item.isAvailable
                                                  ? CupertinoColors.white
                                                  : CupertinoColors.black,
                                            ),
                                            item.isAvailable
                                                ? 'Chat Now'
                                                : "SOLD OUT",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        );
                      },
                    );
                  }
                },
                error: (error, _) => Center(
                  child: Text('Error: $error'),
                ),
                loading: () => Center(
                  child: CupertinoActivityIndicator(),
                ),
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
