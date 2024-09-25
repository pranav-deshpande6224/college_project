import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:college_project/UIPart/Providers/show_ads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisplayAds extends ConsumerStatefulWidget {
  final int index;
  const DisplayAds({required this.index, super.key});

  @override
  ConsumerState<DisplayAds> createState() => _DisplayAdsState();
}

class _DisplayAdsState extends ConsumerState<DisplayAds> {
  void itemSold(Item item) async {
    // try {
    //   // First remove from the Active Ads
    //   // Add that item to the sold Ads
    //   // Remove that item at the front end
    //   ref.read(showAdsProvider.notifier).deleteAd(item);
    // } catch (e) {
    //   print(e.toString());
    // }
  }

  Widget showSpinner() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(),
          SizedBox(
            height: 10,
          ),
          Text('Loading...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemList = ref.watch(showAdsProvider);
    return itemList.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return AdCard(
                ad: data[index],
                adSold: itemSold,
                isSold: false,
              );
            },
          );
        },
        error: (error,stackTrace){
          return Center(
            child: Text(error.toString()),
          );
        },
        loading: showSpinner);
  }
}
