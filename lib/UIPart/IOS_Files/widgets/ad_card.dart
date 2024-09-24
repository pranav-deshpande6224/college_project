import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AdCard extends StatelessWidget {
  final Item ad;
  final bool isSold;
  final void Function(Item item) adSold;
  const AdCard(
      {required this.ad,
      required this.adSold,
      required this.isSold,
      super.key});

  Widget getWidget(BuildContext context) {
    if (isSold) {
      return Expanded(
        flex: 4,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 0.5),
              ),
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        flex: 4,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // adSold(ad);
                      showCupertinoDialog(
                          context: context,
                          builder: (ctx) {
                            return CupertinoAlertDialog(
                                title: Text(
                                  'Alert',
                                  style: GoogleFonts.roboto(),
                                ),
                                content: Text(
                                  'Is this Item Sold?',
                                  style: GoogleFonts.roboto(),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text(
                                      'No',
                                      style: GoogleFonts.roboto(
                                          color:
                                              CupertinoColors.destructiveRed),
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text('yes',
                                        style: GoogleFonts.roboto()),
                                    onPressed: () {
                                      adSold(ad);
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ]);
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: CupertinoColors.activeBlue,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.check_mark_circled,
                              size: 25,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Mark as Sold',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print('Edit Product');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: CupertinoColors.black,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.pencil,
                              color: CupertinoColors.black,
                              size: 25,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Edit Product',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 0.5),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                    'assets/images/placeholder.jpg'),
                              ),
                              Positioned(
                                top: 5,
                                left: 5,
                                right: 5,
                                child: ClipRRect(
                                  child: Image.network(
                                    ad.images[0],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Container(
                          decoration: const BoxDecoration(),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  ad.adTitle,
                                  style: GoogleFonts.roboto(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '₹ ${ad.price.toInt()}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                getWidget(context),
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
