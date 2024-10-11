import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/Authentication/Providers/internet_provider.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/show_sold_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
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
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);

    final soldItemState = ref.watch(showSoldAdsProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'MY SOLD ADS',
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
                        final _ = ref.refresh(connectivityProvider);
                        final s = ref.refresh(internetCheckerProvider);
                        await ref
                            .read(showSoldAdsProvider.notifier)
                            .refreshItems();
                      })
                ],
              ),
            );
          } else {
            return internetState.when(
              data: (hasInternet) {
                if (!hasInternet) {
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
                              final _ = ref.refresh(connectivityProvider);
                              final s = ref.refresh(internetCheckerProvider);
                              await ref
                                  .read(showSoldAdsProvider.notifier)
                                  .refreshItems();
                            })
                      ],
                    ),
                  );
                } else {
                  return soldItemState.when(
                    data: (soldAdState) {
                      if (soldAdState.items.isEmpty) {
                        return CustomScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: soldAdScrollController,
                          slivers: [
                            CupertinoSliverRefreshControl(
                              onRefresh: () async {
                                ref
                                    .read(showSoldAdsProvider.notifier)
                                    .refreshItems();
                              },
                            ),
                            SliverFillRemaining(
                              child: Center(
                                child: Text('No Sold Ads'),
                              ),
                            ),
                          ],
                        );
                      }
                      return CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: soldAdScrollController,
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: () async {
                              ref
                                  .read(showSoldAdsProvider.notifier)
                                  .refreshItems();
                            },
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, index) {
                                final item = soldAdState.items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: AdCard(
                                    cardIndex: index,
                                    ad: item,
                                    adSold: null,
                                    isSold: true,
                                  ),
                                );
                              },
                              childCount: soldAdState.items.length,
                            ),
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
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
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
                  );
                }
              },
              error: (error, _) => Center(child: Text('Error: $error')),
              loading: () => Center(child: CupertinoActivityIndicator()),
            );
          }
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => Center(child: CupertinoActivityIndicator()),
      )),
    );
  }
}
