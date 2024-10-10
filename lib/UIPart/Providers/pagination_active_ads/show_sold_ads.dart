import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SoldAdState {
  final List<Item> items;
  final bool isLoadingMore;
  SoldAdState({
    required this.items,
    this.isLoadingMore = false,
  });
  SoldAdState copyWith({
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return SoldAdState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowSoldAds extends StateNotifier<AsyncValue<SoldAdState>> {
  ShowSoldAds() : super(AsyncValue.loading());
  DocumentSnapshot<Map<String, dynamic>>? _soldLastDocument;
  bool _hasMoreSold = true;
  bool _isLoadingSold = false;
  final int _itemsPerPage = 5;
  AuthHandler handler = AuthHandler.authHandlerInstance;
  Future<void> fetchInitialItems() async {
    if (_isLoadingSold) return;
    _isLoadingSold = true;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        Query<Map<String, dynamic>> query = fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MySoldAds')
            .orderBy('createdAt', descending: true)
            .limit(_itemsPerPage);

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        final docs = querySnapshot.docs.map<Item>((doc) {
          Timestamp timeStamp = doc.data()['createdAt'];
          final dateString =
              DateFormat('dd--MM--yy').format(timeStamp.toDate());
          return Item.fromJson(doc.data(), doc.id, dateString, doc);
        }).toList();

        if (querySnapshot.docs.isNotEmpty) {
          _soldLastDocument = querySnapshot.docs.last;
        }
        _hasMoreSold = querySnapshot.docs.length == _itemsPerPage;
        state = AsyncValue.data(SoldAdState(items: docs));
      } catch (error, stack) {
        state = AsyncValue.error(error, stack);
      } finally {
        _isLoadingSold = false;
      }
    } else {
      // TODO Handle the case when the user is not authenticated
      return;
    }
  }

  Future<void> refreshItems() async {
    if (_isLoadingSold) return; // Prevent multiple simultaneous requests
    _soldLastDocument = null;
    _hasMoreSold = true;
    await fetchInitialItems();
  }

void deleteItem(Item item){
  state = AsyncValue.data(state.asData!.value.copyWith(items: state.asData!.value.items.where((element) {
    return element.id != item.id;
  }).toList()));
}
  Future<void> fetchMoreItems() async {
    if (_isLoadingSold ||
        !_hasMoreSold ||
        state.asData?.value.isLoadingMore == true) {
      return;
    }
    state = AsyncValue.data(state.asData!.value.copyWith(isLoadingMore: true));
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        await Future.delayed(Duration(seconds: 1));
        Query<Map<String, dynamic>> query = fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MySoldAds')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_soldLastDocument!)
            .limit(_itemsPerPage);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        final newDocs = querySnapshot.docs.map<Item>((doc) {
          Timestamp timeStamp = doc.data()['createdAt'];
          final dateString =
              DateFormat('dd--MM--yy').format(timeStamp.toDate());
          return Item.fromJson(doc.data(), doc.id, dateString, doc);
        }).toList();
        if (newDocs.isNotEmpty) {
          _soldLastDocument = querySnapshot.docs.last;
        }

        _hasMoreSold = newDocs.length == _itemsPerPage;
        state = AsyncValue.data(
          state.asData!.value.copyWith(
            items: [...state.asData!.value.items, ...newDocs],
            isLoadingMore: false,
          ),
        );
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
      }
    } else {
      // TODO NAvigate to login screen
    }
  }
}

final showSoldAdsProvider =
    StateNotifierProvider<ShowSoldAds, AsyncValue<SoldAdState>>((ref) {
  return ShowSoldAds();
});
























// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:college_project/UIPart/IOS_Files/model/item.dart';
// import 'package:college_project/UIPart/Providers/pagination_active_ads/pagination_state.dart';
// import 'package:college_project/UIPart/repository/sold_ad_repository.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ShowSoldAds<T> extends StateNotifier<PaginationState<T>> {
//   final Future<List<T>> Function(DocumentSnapshot? lastDocument) fetchItems;
//   final int itemsPerBatch;
//   final List<T> _items = [];
//   bool noMoreAds = false;
//   DocumentSnapshot? lastDocumentSnapshot;
//   Timer _timer = Timer(Duration(milliseconds: 0), () {});
//   ShowSoldAds({required this.fetchItems, required this.itemsPerBatch})
//       : super(const PaginationState.loading());

//   void init() {
//     if (_items.isEmpty) {
//       fetchFirstBatch();
//     }
//   }

//   void updateData(List<T> result, DocumentSnapshot? lastDocument) {
//     noMoreAds = result.length < itemsPerBatch;
//     lastDocumentSnapshot = lastDocument;
//     if (result.isEmpty) {
//       state = PaginationState.data(_items);
//     } else {
//       state = PaginationState.data(_items..addAll(result));
//     }
//   }

//   Future<void> fetchFirstBatch() async {
//     try {
//       state = const PaginationState.loading();
//       final List<T> result = await fetchItems(null);
//       final DocumentSnapshot? lastDocument =
//           result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
//       updateData(result, lastDocument);
//     } catch (e, stk) {
//       state = PaginationState.error(e, stk);
//     }
//   }

//   void deleteItem(Item item) {
//     print(_items.length);
//     _items.where((element){
//       Item item1 = element as Item;
//       return item1.id != item.id;
//     });
//     print(_items.length);
//     state = PaginationState.data(List<T>.from(_items));
//   }

//   Future<void> fetchNextBatch() async {
//     if (_timer.isActive && _items.isNotEmpty) return;
//     _timer = Timer(const Duration(milliseconds: 1000), () {});
//     if (noMoreAds) return;
//     if (state == PaginationState<T>.onGoingLoading(_items)) return;
//     state = PaginationState.onGoingLoading(_items);
//     try {
//       await Future.delayed(Duration(seconds: 1));
//       final result = await fetchItems(lastDocumentSnapshot);
//       final DocumentSnapshot? lastDocument =
//           result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
//       updateData(result, lastDocument);
//     } catch (e, stk) {
//       state = PaginationState.onGoingError(_items, e, stk);
//     }
//   }
// }

// final soldAdRepositoryProvider = Provider<SoldAdRepository>((ref) {
//   return SoldAdRepository();
// });

// final soldAdsProvider =
//     StateNotifierProvider<ShowSoldAds<Item>, PaginationState<Item>>((ref) {
//   return ShowSoldAds<Item>(
//     itemsPerBatch: 5,
//     fetchItems: (snapshot) {
//       return ref.read(soldAdRepositoryProvider).fetchSoldAds(snapshot);
//     },
//   )..init();
// });
