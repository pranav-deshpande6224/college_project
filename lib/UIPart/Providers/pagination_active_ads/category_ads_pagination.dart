import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/Providers/category_provider.dart';
import 'package:college_project/UIPart/Providers/pagination_active_ads/pagination_state.dart';
import 'package:college_project/UIPart/repository/category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryAdsPagination<T> extends StateNotifier<PaginationState<T>> {
  final Future<List<T>> Function(
          DocumentSnapshot? lastDocument, String category, String subCategory)
      fetchItems;
  final int itemsPerBatch;
  final List<T> _items = [];
  bool noMoreAds = false;
  DocumentSnapshot? lastDocumentSnapshot;
  final String category;
  final String subCategory;

  Timer _timer = Timer(Duration(milliseconds: 0), () {});
  CategoryAdsPagination({
    required this.category,
    required this.subCategory,
    required this.fetchItems,
    required this.itemsPerBatch,
  }) : super(const PaginationState.loading());
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
      final List<T> result = await fetchItems(null, category, subCategory);
      final DocumentSnapshot? lastDocument =
          result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
      
      updateData(result, lastDocument);
    } catch (e, stk) {
      state = PaginationState.error(e, stk);
     
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
      final result =
          await fetchItems(lastDocumentSnapshot, category, subCategory);
      final DocumentSnapshot? lastDocument =
          result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
      updateData(result, lastDocument);
    } catch (e, stk) {
      state = PaginationState.onGoingError(_items, e, stk);
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((_) {
  return CategoryRepository();
});

final showCategoryAdsProvider =
    StateNotifierProvider<CategoryAdsPagination<Item>, PaginationState<Item>>(
        (ref) {
  final obj = ref.read(categoryAndSubCatProvider);
  print(obj.category);
  print(obj.subCategory);
  return CategoryAdsPagination<Item>(
      fetchItems: (lastDocument, category, subCategory) {
        return ref
            .read(categoryRepositoryProvider)
            .getThatCategoryData(lastDocument, category, subCategory);
      },
      itemsPerBatch: 8,
      category: obj.category,
      subCategory: obj.subCategory)
    ..init();
});
