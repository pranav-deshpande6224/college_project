import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/show_sold_ads.dart';
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
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    soldAdScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    soldAdScrollController.addListener(() {
      double maxScroll = soldAdScrollController.position.maxScrollExtent;
      double currentScroll = soldAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(soldAdsProvider.notifier).fetchNextBatch();
      }
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'MY SOLD ADS',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          controller: soldAdScrollController,
          slivers: [
            SoldItemsList(),
            NoMoreSoldItems(),
            OnGoingBottomSoldWidget()
          ],
        ),
      ),
    );
  }
}

class SoldItemsList extends ConsumerWidget {
  const SoldItemsList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(soldAdsProvider);
    return state.when(
      data: (items) {
        return items.isEmpty
            ? SliverToBoxAdapter(
                child: Text('No ADS of Your'),
              )
            : ItemListBuilder(
                items: items,
              );
      },
      loading: () {
        return SliverFillRemaining(
          hasScrollBody: false,
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
      error: (Object? e, StackTrace? stk) {
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

class ItemListBuilder extends StatelessWidget {
  final List<Item> items;
  const ItemListBuilder({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final soldItem = items[index];
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: AdCard(
              cardIndex: index,
              ad: soldItem,
              isSold: true,
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

class NoMoreSoldItems extends ConsumerWidget {
  const NoMoreSoldItems({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(soldAdsProvider);
    return SliverToBoxAdapter(
      child: state.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          data: (items) {
            final nomoreItems = ref.read(soldAdsProvider.notifier).noMoreAds;
            return nomoreItems
                ? Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "No More ADS Found!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
    );
  }
}

class OnGoingBottomSoldWidget extends StatelessWidget {
  const OnGoingBottomSoldWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(40),
      sliver: SliverToBoxAdapter(
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(soldAdsProvider);
            final noMoreAds = ref.read(soldAdsProvider.notifier).noMoreAds;
            return state.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              onGoingLoading: (items) => noMoreAds
                  ? const SizedBox.shrink()
                  : const Center(
                      child: CupertinoActivityIndicator(),
                    ),
              onGoingError: (items, e, stk) => Center(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.alarm),
                    SizedBox(
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
        ),
      ),
    );
  }
}
