import 'package:college_project/UIPart/IOS_Files/model/category.dart';
import 'package:college_project/UIPart/IOS_Files/screens/home/product_detail_screen.dart';
import 'package:college_project/UIPart/Providers/home_ads.dart';
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
  Widget build(BuildContext context) {
    final homeAds = ref.watch(showHomeAdsProvider);
    return homeAds.when(
      data: (data) {
        print('My Data length is ${data.length}');
        return CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () =>
                  ref.read(showHomeAdsProvider.notifier).refreshHomeAds(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: CupertinoSearchTextField(
                  placeholder: 'Find Mobiles, Monitor and more...',
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: Text(
                'Browse Categories',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: AspectRatio(
                aspectRatio: 3.5,
                child: SizedBox(
                  child: GestureDetector(
                    onTap: () {},
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryList.length,
                      itemBuilder: (ctx, index) {
                        return Row(
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Text(
                'Fresh Recomendations',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverGrid(
              delegate: SliverChildBuilderDelegate(childCount: data.length,
                  (ctx, index) {
                final ad = data[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (ctx) {
                          return ProductDetailScreen(
                            item: ad,
                            yourAd: false,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 9,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  child: Image.asset(
                                    'assets/images/placeholder.jpg',
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: ClipRRect(
                                    child: Image.network(
                                      ad.images[0],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
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
                                  height: 5,
                                ),
                                Text(
                                  ad.adTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                ad.postedBy,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //TODO Need to Handle Error case also
              Text(error.toString())
            ],
          ),
        );
      },
      loading: () {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(
                radius: 15,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Loading...',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
