import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CategoryAdsState {
  final List<Item> items;
  final bool isLoadingMore;

  CategoryAdsState({
    required this.items,
    this.isLoadingMore = false,
  });
  CategoryAdsState copyWith({
    String? category,
    String? subCategory,
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return CategoryAdsState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowCategoryAds extends StateNotifier<AsyncValue<CategoryAdsState>> {
  ShowCategoryAds() : super(const AsyncValue.loading());
  final int _itemsPerPage = 5;
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _hasMoreCategory = true;
  bool _isLoadingCategory = false;
  AuthHandler handler = AuthHandler.authHandlerInstance;
  Future<void> fetchInitialItems(String category, String subCategory) async {
    if (_isLoadingCategory) return;
    _isLoadingCategory = true;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        Query<Map<String, dynamic>> query = fireStore
            .collection('Category')
            .doc(category)
            .collection('Subcategories')
            .doc(subCategory)
            .collection('Ads')
            .orderBy('createdAt', descending: true)
            .limit(_itemsPerPage);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        List<Item> items = [];
        for (final doc in querySnapshot.docs) {
          DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
          DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
          Timestamp timeStamp = doc.data()['createdAt'];
          final dateString =
              DateFormat('dd--MM--yy').format(timeStamp.toDate());
          final item =
              Item.fromJson(dataDoc.data()!, dataDoc.id, dateString, doc);
          items.add(item);
        }
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        _hasMoreCategory = querySnapshot.docs.length == _itemsPerPage;
        state = AsyncValue.data(CategoryAdsState(
          items: items,
        ));
      } catch (error, stack) {
        state = AsyncValue.error(error, stack);
      } finally {
        _isLoadingCategory = false;
      }
    } else {
      // TODO Handle the case when the user is not authenticated
      return;
    }
  }
 void deleteItem(Item item){
    state = AsyncValue.data(state.asData!.value.copyWith(items: state.asData!.value.items.where((element) {
      return element.id != item.id;
    }).toList()));
  } 
  Future<void> refreshItems(String category, String subCategory) async {
    if (_isLoadingCategory) return; // Prevent multiple simultaneous requests
    _lastDocument = null;
    _hasMoreCategory = true;
    await fetchInitialItems(category, subCategory);
  }

  void resetState(){
    _hasMoreCategory = true;
    _isLoadingCategory = false;
    _lastDocument = null;
    state = AsyncValue.loading();
  }
  
  Future<void> fetchMoreItems( String category, String subCategory) async {
    if (_isLoadingCategory ||
        !_hasMoreCategory ||
        state.asData?.value.isLoadingMore == true) {
      return;
    }
    state = AsyncValue.data(state.asData!.value.copyWith(isLoadingMore: true));
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        await Future.delayed(Duration(seconds: 1));
        Query<Map<String, dynamic>> query = fireStore
            .collection('Category')
            .doc(category)
            .collection('Subcategories')
            .doc(subCategory)
            .collection('Ads')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(_itemsPerPage);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        List<Item> moreHomeItems =
            await Future.wait(querySnapshot.docs.map((doc) async {
          DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
          DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
          Timestamp timeStamp = doc.data()['createdAt'];
          final dateString =
              DateFormat('dd--MM--yy').format(timeStamp.toDate());
          return Item.fromJson(dataDoc.data()!, dataDoc.id, dateString, doc);
        }).toList());
        if (moreHomeItems.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        _hasMoreCategory = moreHomeItems.length == _itemsPerPage;
        state = AsyncValue.data(
          state.asData!.value.copyWith(
            items: [...state.asData!.value.items, ...moreHomeItems],
            isLoadingMore: false,
          ),
        );
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
      }
    } else {
      // TODO Navigate to login screen
    }
  }
}

final showCatAdsProvider =
    StateNotifierProvider<ShowCategoryAds, AsyncValue<CategoryAdsState>>((ref) {
  return ShowCategoryAds();
});






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
