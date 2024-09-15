import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdsList extends StateNotifier<List<Item>> {
  AdsList() : super([]);
  void setAds(List<Item> ads) {
    state = ads;
  }
}

final adsListProvider = StateNotifierProvider<AdsList, List<Item>>((_) {
  return AdsList();
});
