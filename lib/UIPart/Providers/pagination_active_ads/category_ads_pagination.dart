// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:college_project/UIPart/IOS_Files/model/item.dart';
// import 'package:college_project/UIPart/Providers/pagination_active_ads/pagination_state.dart';
// import 'package:college_project/UIPart/repository/category_repository.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class CategoryAdsPagination<T> extends StateNotifier<PaginationState<T>> {
//   final Future<List<T>> Function(
//           DocumentSnapshot? lastDocument, String category, String subCategory)
//       fetchItems;
//   final int itemsPerBatch;
//   final List<T> _items = [];
//   bool noMoreAds = false;
//   DocumentSnapshot? lastDocumentSnapshot;
//   String category = '';
//   String subCategory = '';

//   Timer _timer = Timer(Duration(milliseconds: 0), () {});
//   CategoryAdsPagination({
//     required this.fetchItems,
//     required this.itemsPerBatch,
//   }) : super(const PaginationState.loading());

//   void setCategoryAndSubCategory(String category, String subCategory) {
//     this.category = category;
//     this.subCategory = subCategory;
//   }

//   void init() {
//     if (_items.isEmpty && category.isNotEmpty && subCategory.isNotEmpty) {
//       fetchFirstCategoryBatch();
//     }
//   }

//   void updateData(List<T> result, DocumentSnapshot? lastDocument) {
//     noMoreAds = result.length < itemsPerBatch;
//     lastDocumentSnapshot = lastDocument;
//     if (result.isEmpty) {
//       state = PaginationState.data(_items);
//     } else {
//       print("State has changed");
//       state = PaginationState.data(_items..addAll(result));
//     }
//   }

//   Future<void> fetchFirstCategoryBatch() async {
//     print(category);
//     print(subCategory);
//     if (category.isEmpty || subCategory.isEmpty) return;
//     try {
//       state = const PaginationState.loading();
//       final List<T> result = await fetchItems(null, category, subCategory);
//       final DocumentSnapshot? lastDocument =
//           result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
//       updateData(result, lastDocument);
//     } catch (e, stk) {
//       state = PaginationState.error(e, stk);
//     }
//   }

//   Future<void> fetchNextCategoryBatch() async {
//     if (_timer.isActive && _items.isNotEmpty) return;
//     _timer = Timer(const Duration(milliseconds: 1000), () {});
//     if (noMoreAds) return;
//     if (state == PaginationState<T>.onGoingLoading(_items)) return;
//     state = PaginationState.onGoingLoading(_items);
//     try {
//       await Future.delayed(Duration(seconds: 1));
//       final result =
//           await fetchItems(lastDocumentSnapshot, category, subCategory);
//       final DocumentSnapshot? lastDocument =
//           result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
//       updateData(result, lastDocument);
//     } catch (e, stk) {
//       state = PaginationState.onGoingError(_items, e, stk);
//     }
//   }
// }

// final categoryRepositoryProvider = Provider<CategoryRepository>((_) {
//   return CategoryRepository();
// });

// final showCategoryAdsProvider =
//     StateNotifierProvider<CategoryAdsPagination<Item>, PaginationState<Item>>(
//         (ref) {
//   return CategoryAdsPagination<Item>(
//     fetchItems: (lastDocument, category, subCategory) {
//       final data = ref
//           .read(categoryRepositoryProvider)
//           .getThatCategoryData(lastDocument, category, subCategory);
//       print(data.toString());
//       return data;
//     },
//     itemsPerBatch: 5,
//   )..init();
// });
