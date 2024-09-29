import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/repository/ad_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowActiveAds extends StateNotifier<AsyncValue<List<Item>>> {
  final AdRepository repository;
  ShowActiveAds(this.repository) : super(const AsyncLoading()) {
    _fetchActiveAds();
  }

  Future<void> _fetchActiveAds() async {
    try {
      final items = await repository.fetchActiveAds();
      state = AsyncData(items);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refreshActiveAds() async {
    await _fetchActiveAds();
  }

  Future<void> deleteActiveAd(Item ad) async {
    state = AsyncData(
      state.value!.where((item) => item != ad).toList(),
    );
  }
}

final showActiveAdsProvider =
    StateNotifierProvider<ShowActiveAds, AsyncValue<List<Item>>>((ref) {
  final repository = ref.watch(adRepositoryProvider);
  return ShowActiveAds(repository);
});
