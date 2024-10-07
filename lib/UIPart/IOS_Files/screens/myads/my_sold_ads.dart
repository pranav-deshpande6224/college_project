import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/show_sold_ads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MySoldAds extends ConsumerStatefulWidget {
  const MySoldAds({super.key});
  @override
  ConsumerState<MySoldAds> createState() => _MySoldAdsState();
}

class _MySoldAdsState extends ConsumerState<MySoldAds> {
  late AuthHandler handler;
  final ScrollController soldAdScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    handler = AuthHandler.authHandlerInstance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(showSoldAdsProvider.notifier).fetchInitialItems();
    });
    soldAdScrollController.addListener(() {
      double maxScroll = soldAdScrollController.position.maxScrollExtent;
      double currentScroll = soldAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(showSoldAdsProvider.notifier).fetchMoreItems();
      }
    });
  }

  @override
  void dispose() {
    soldAdScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soldItemState = ref.watch(showSoldAdsProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        leading: IconButton(
            onPressed: () {
              ref.read(showSoldAdsProvider.notifier).resetState();
              Navigator.of(context).pop();
            },
            icon: Icon(
              CupertinoIcons.left_chevron,
              size: 28,
            )),
        middle: Text(
          'MY SOLD ADS',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
        child: soldItemState.when(
          data: (soldAdState) {
            if (soldAdState.items.isEmpty) {
              return CustomScrollView(
                controller: soldAdScrollController,
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      ref.read(showSoldAdsProvider.notifier).refreshItems();
                    },
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Text('No Sold Ads'),
                      ),
                    ),
                  )
                ],
              );
            }
            return CustomScrollView(
              controller: soldAdScrollController,
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    ref.read(showSoldAdsProvider.notifier).refreshItems();
                  },
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, index) {
                    final item = soldAdState.items[index];
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: AdCard(
                        cardIndex: index,
                        ad: item,
                        // adSold: markAsSold,
                        isSold: true,
                      ),
                    );
                  }, childCount: soldAdState.items.length),
                ),
                if (soldAdState.isLoadingMore)
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
          },
          error: (error, stack) => Center(child: Text('Error: $error')),
          loading: () {
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
          },
        ),
      ),
    );
  }
}
