import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/repository/ad_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ShowAds extends StateNotifier<AsyncValue<List<Item>>> {
  final AdRepository repository;
  ShowAds(this.repository) : super(const AsyncLoading()){
    _fetchAds();
  }

  Future<void> _fetchAds() async {
    try {
      final items = await repository.fetchItems();
      state = AsyncData(items);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // void deleteAd(Item item) async {
  //   try {
  //     AuthHandler handler = AuthHandler.authHandlerInstance;
  //     final fireStore = handler.fireStore;
  //     await fireStore
  //         .collection('users')
  //         .doc(handler.user!.uid)
  //         .collection('MyActiveAds')
  //         .doc(item.id)
  //         .delete();
  //     await fireStore
  //         .collection('users')
  //         .doc(handler.user!.uid)
  //         .collection('MySoldAds')
  //         .doc(item.id)
  //         .set(item.toJson());

  //     state = state.where((element) => element != item).toList();
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}


final showAdsProvider = StateNotifierProvider<ShowAds, AsyncValue<List<Item>>>((ref) {
  final repository = ref.watch(adRepositoryProvider);
  return ShowAds(repository);
});

