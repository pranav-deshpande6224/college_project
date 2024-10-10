import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ActiveAdsState {
  final List<Item> items;
  final bool isLoadingMore;
  ActiveAdsState({
    required this.items,
    this.isLoadingMore = false,
  });
  ActiveAdsState copyWith({
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return ActiveAdsState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowActiveAds extends StateNotifier<AsyncValue<ActiveAdsState>> {
  ShowActiveAds() : super(const AsyncValue.loading());

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  final int _itemsPerPage = 5;
  AuthHandler handler = AuthHandler.authHandlerInstance;

  Future<void> fetchInitialItems() async {
    if (_isLoading) return;
    _isLoading = true;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        Query<Map<String, dynamic>> query = fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MyActiveAds')
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
          _lastDocument = querySnapshot.docs.last;
        }
        _hasMore = querySnapshot.docs.length == _itemsPerPage;
        state = AsyncValue.data(ActiveAdsState(items: docs));
      } catch (error, stack) {
        state = AsyncValue.error(error, stack);
      } finally {
        _isLoading = false;
      }
    } else {
      // TODO Handle the case when the user is not authenticated
      return;
    }
  }


  Future<void> refreshItems() async {
    if (_isLoading) return; // Prevent multiple simultaneous requests
    _lastDocument = null;
    _hasMore = true;
    await fetchInitialItems();
  }

  Future<void> fetchMoreItems() async {
    if (_isLoading || !_hasMore || state.asData?.value.isLoadingMore == true) {
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
            .collection('MyActiveAds')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(_itemsPerPage);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        final newDocs = querySnapshot.docs.map<Item>((doc) {
          Timestamp timeStamp = doc.data()['createdAt'];
          final dateString =
              DateFormat('dd--MM--yy').format(timeStamp.toDate());
          return Item.fromJson(doc.data(), doc.id, dateString, doc);
        }).toList();
        if (newDocs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        _hasMore = newDocs.length == _itemsPerPage;
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
  void deleteItem(Item item){
  state = AsyncValue.data(state.asData!.value.copyWith(items: state.asData!.value.items.where((element) {
    return element.id != item.id;
  }).toList()));
}
}

final showActiveAdsProvider =
    StateNotifierProvider.autoDispose<ShowActiveAds, AsyncValue<ActiveAdsState>>((ref) {
  return ShowActiveAds();
});

























// class ShowActiveAds<T> extends StateNotifier<PaginationState<T>> {
//   final Future<List<T>> Function(DocumentSnapshot? lastDocument) fetchNextItems;
//   final int itemsPerBatch;
//   final List<T> _items = [];
//   bool noMoreAds = false;
//   DocumentSnapshot? lastDocumentSnapshot;
//   Timer _timer = Timer(Duration(milliseconds: 0), () {});
//   ShowActiveAds({required this.fetchNextItems, required this.itemsPerBatch})
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
//       final List<T> result = await fetchNextItems(null);
//       final DocumentSnapshot? lastDocument =
//           result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
//       updateData(result, lastDocument);
//     } catch (e, stk) {
//       state = PaginationState.error(e, stk);
//       print("Error in fetchFirstBatch: $e");
//     }
//   }

//   Future<void> refreshAds() async {
//     _items.clear();
//     noMoreAds = false;
//     lastDocumentSnapshot = null;
//     await fetchFirstBatch();
//   }

//   Future<void> fetchNextBatch() async {
//     if (_timer.isActive && _items.isNotEmpty) return;
//     _timer = Timer(const Duration(milliseconds: 1000), () {});
//     if (noMoreAds) return;
//     if (state == PaginationState<T>.onGoingLoading(_items)) return;
//     state = PaginationState.onGoingLoading(_items);
//     try {
//       await Future.delayed(Duration(seconds: 1));
//       final result = await fetchNextItems(lastDocumentSnapshot);
//       final DocumentSnapshot? lastDocument =
//           result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
//       updateData(result, lastDocument);
//     } catch (e, stk) {
//       state = PaginationState.onGoingError(_items, e, stk);
//       print("Error in fetchNextBatch: $e");
//     }
//   }

//   // Future<void> deleteActiveAd(Item ad) async {
//   //   state = AsyncData(
//   //     state.value!.where((item) => item.id != ad.id).toList(),
//   //   );
//   // }
// }

// final activeAdRepositoryProvider = Provider<ActiveAdRepository>((ref) {
//   return ActiveAdRepository();
// });
// final showActiveAdsProvider =
//     StateNotifierProvider<ShowActiveAds<Item>, PaginationState<Item>>((ref) {
//   return ShowActiveAds<Item>(
//       itemsPerBatch: 5,
//       fetchNextItems: (snapshot) {
//         return ref.read(activeAdRepositoryProvider).fetchActiveAds(snapshot);
//       })
//     ..init();
// });