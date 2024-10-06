import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/pagination_state.dart';
import 'package:college_project/UIPart/repository/ad_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowActiveAds<T> extends StateNotifier<PaginationState<T>> {
  final Future<List<T>> Function(DocumentSnapshot? lastDocument) fetchNextItems;
  final int itemsPerBatch;
  final List<T> _items = [];
  bool noMoreAds = false;
  DocumentSnapshot? lastDocumentSnapshot;
  Timer _timer = Timer(Duration(milliseconds: 0), () {});
  ShowActiveAds({required this.fetchNextItems, required this.itemsPerBatch})
      : super(const PaginationState.loading());

  void init() {
    if (_items.isEmpty) {
      fetchFirstBatch();
    }
  }

  void updateData(List<T> result, DocumentSnapshot? lastDocument) {
    noMoreAds = result.length < itemsPerBatch;
    lastDocumentSnapshot = lastDocument;
    if (result.isEmpty) {
      state = PaginationState.data(_items);
    } else {
      state = PaginationState.data(_items..addAll(result));
    }
  }

  Future<void> fetchFirstBatch() async {
    try {
      state = const PaginationState.loading();
      final List<T> result = await fetchNextItems(null);
      final DocumentSnapshot? lastDocument =
          result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
      updateData(result, lastDocument);
    } catch (e, stk) {
      state = PaginationState.error(e, stk);
      print("Error in fetchFirstBatch: $e");
    }
  }

  Future<void> fetchNextBatch() async {
    if (_timer.isActive && _items.isNotEmpty) return;
    _timer = Timer(const Duration(milliseconds: 1000), () {});
    if (noMoreAds) return;
    if (state == PaginationState<T>.onGoingLoading(_items)) return;
    state = PaginationState.onGoingLoading(_items);
    try {
      await Future.delayed(Duration(seconds: 1));
      final result = await fetchNextItems(lastDocumentSnapshot);
      final DocumentSnapshot? lastDocument =
          result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
      updateData(result, lastDocument);
    } catch (e, stk) {
      state = PaginationState.onGoingError(_items, e, stk);
      print("Error in fetchNextBatch: $e");
    }
  }

  // Future<void> deleteActiveAd(Item ad) async {
  //   state = AsyncData(
  //     state.value!.where((item) => item.id != ad.id).toList(),
  //   );
  // }
}

final activeAdRepositoryProvider = Provider<ActiveAdRepository>((ref) {
  return ActiveAdRepository();
});
final showActiveAdsProvider =
    StateNotifierProvider<ShowActiveAds<Item>, PaginationState<Item>>((ref) {
  return ShowActiveAds<Item>(
      itemsPerBatch: 5,
      fetchNextItems: (snapshot) {
        return ref.read(activeAdRepositoryProvider).fetchActiveAds(snapshot);
      })
    ..init();
});


