import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/repository/ad_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowSoldAds extends StateNotifier<AsyncValue<List<Item>>> {
  final AdRepository repository;
  ShowSoldAds(this.repository) : super(const AsyncLoading()) {
    _fetchSoldAds();
  }

  Future<void> _fetchSoldAds() async {
    try {
      final items = await repository.fetchSoldAds();
      state = AsyncData(items);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refreshSoldAds() async {
    await _fetchSoldAds();
  }

  Future<void> deleteSoldAd(Item ad) async {
    state = AsyncData(
      state.value!.where((item) => item != ad).toList(),
    );
  }
}

final showSoldAdsProvider =
    StateNotifierProvider<ShowSoldAds, AsyncValue<List<Item>>>((ref) {
  final repository = ref.watch(adRepositoryProvider);
  return ShowSoldAds(repository);
});
