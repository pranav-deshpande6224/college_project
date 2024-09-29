import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/repository/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeAds extends StateNotifier<AsyncValue<List<Item>>> {
  final HomeRepository repository;
  HomeAds(this.repository) : super(const AsyncLoading()) {
    _fetchHomeAds();
  }

  Future<void> _fetchHomeAds() async {
    try {
      final items = await repository.fetchHomeAds();
      state = AsyncData(items);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
  Future<void> refreshHomeAds() async {
    await _fetchHomeAds();
  }

  Future<void> deleteAd(Item ad) async {
    state = AsyncData(
      state.value!.where((item) => item.id != ad.id).toList(),
    );
  }
}

final showHomeAdsProvider =
    StateNotifierProvider<HomeAds, AsyncValue<List<Item>>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeAds(repository);
});