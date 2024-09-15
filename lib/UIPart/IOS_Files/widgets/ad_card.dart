import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdCard extends StatelessWidget {
  final Item ad;
  const AdCard({required this.ad, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.8,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.2), // Shadow color with opacity
                  spreadRadius: 1, // Spread radius (expands the shadow)
                  blurRadius: 10, // Blur radius (makes the shadow softer)
                  offset:
                      const Offset(0, 5), // Offset (horizontal: 0, vertical: 5)
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    width: 80,
                                    height: 80,
                                    'assets/images/placeholder.jpg',
                                  ),
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Image.network(
                                      ad.images[0],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: double.infinity,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                ad.adTitle,
                                style: GoogleFonts.roboto(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              '₹ ${ad.price.toInt()}',
                              style: GoogleFonts.roboto(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.black,
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, bottom: 8, top: 5),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: CupertinoColors.activeBlue,
                                ),
                                child: Center(
                                  child: Text(
                                    'Mark as Sold',
                                    style: GoogleFonts.roboto(
                                      color: CupertinoColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    'Edit Product',
                                    style: GoogleFonts.roboto(
                                      color: CupertinoColors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
