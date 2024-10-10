import 'package:carousel_slider/carousel_slider.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  final Item item;
  final bool yourAd;
  const ProductDetailScreen(
      {required this.item, required this.yourAd, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  Widget getExtraDetails() {
    if (widget.item.brand != '') {
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
            widget.item.brand,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    if (widget.item.tabletType != '') {
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
            widget.item.tabletType,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    if (widget.item.chargerType != '') {
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
            widget.item.chargerType,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Product Details',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CarouselSlider(
                          items: widget.item.images.map((e) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemBackground,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.photo,
                                        size: 30,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    left: 0,
                                    bottom: 0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, bottom: 8),
                                        child: Image.network(
                                          e,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          options: CarouselOptions(
                            disableCenter: true,
                            autoPlay: true,
                            enableInfiniteScroll: false,
                          ),
                        ),
                      ),
                      Text(
                        '₹ ${widget.item.price.toInt()}',
                        style: GoogleFonts.roboto(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.item.adTitle,
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
                        widget.item.adDescription,
                        style: GoogleFonts.roboto(fontSize: 22),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      getExtraDetails(),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            widget.yourAd ? 'You' : widget.item.postedBy,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            widget.item.createdAt,
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
            widget.yourAd
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
                          child: Text(
                            'Chat Now',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
