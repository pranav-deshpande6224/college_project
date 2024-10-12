import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeAdState {
  final List<Item> items;
  final bool isLoadingMore;
  HomeAdState({
    required this.items,
    this.isLoadingMore = false,
  });
  HomeAdState copyWith({
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return HomeAdState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowHomeAds extends StateNotifier<AsyncValue<HomeAdState>> {
  ShowHomeAds() : super(const AsyncValue.loading());
  DocumentSnapshot<Map<String, dynamic>>? _lastHomeDocument;
  bool _hasMoreHome = true;
  bool _isLoadingHome = false;
  final int _itemsPerPageHome = 8;
  AuthHandler handler = AuthHandler.authHandlerInstance;

  Future<void> fetchInitialItems() async {
    if (_isLoadingHome) return;
    _isLoadingHome = true;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        Query<Map<String, dynamic>> query = fireStore
            .collection('AllAds')
            .orderBy('createdAt', descending: true)
            .limit(_itemsPerPageHome);

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
          _lastHomeDocument = querySnapshot.docs.last;
        }
        _hasMoreHome = querySnapshot.docs.length == _itemsPerPageHome;
        state = AsyncValue.data(HomeAdState(items: items));
      } catch (error, stack) {
        state = AsyncValue.error(error, stack);
      } finally {
        _isLoadingHome = false;
      }
    } else {
      // TODO Handle the case when the user is not authenticated
      return;
    }
  }

  Future<void> refreshItems() async {
    if (_isLoadingHome) return; // Prevent multiple simultaneous requests
    _lastHomeDocument = null;
    _hasMoreHome = true;
    await fetchInitialItems();
  }

  void deleteItem(Item item) {
    state = AsyncValue.data(state.asData!.value.copyWith(
        items: state.asData!.value.items.where((element) {
      return element.id != item.id;
    }).toList()));
  }

  void resetState() {
    _hasMoreHome = true;
    _isLoadingHome = false;
    _lastHomeDocument = null;
    state = AsyncValue.loading();
  }

  Future<void> fetchMoreItems() async {
    if (_isLoadingHome ||
        !_hasMoreHome ||
        state.asData?.value.isLoadingMore == true) {
      return;
    }
    state = AsyncValue.data(state.asData!.value.copyWith(isLoadingMore: true));
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        await Future.delayed(Duration(seconds: 1));
        Query<Map<String, dynamic>> query = fireStore
            .collection('AllAds')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_lastHomeDocument!)
            .limit(_itemsPerPageHome);
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
          _lastHomeDocument = querySnapshot.docs.last;
        }
        _hasMoreHome = moreHomeItems.length == _itemsPerPageHome;
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

final homeAdsprovider =
    StateNotifierProvider<ShowHomeAds, AsyncValue<HomeAdState>>((ref) {
  return ShowHomeAds();
});



























// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:college_project/UIPart/IOS_Files/model/item.dart';
// import 'package:college_project/UIPart/Providers/pagination_active_ads/pagination_state.dart';
// import 'package:college_project/UIPart/repository/home_repository.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class HomeAds<T> extends StateNotifier<PaginationState<T>> {
//   final Future<List<T>> Function(DocumentSnapshot? lastDocument) fetchItems;
//   final int itemsPerBatch;
//   final List<T> _items = [];
//   bool noMoreAds = false;
//   DocumentSnapshot? lastDocumentSnapshot;
//   Timer _timer = Timer(Duration(milliseconds: 0), () {});
//   HomeAds({required this.fetchItems, required this.itemsPerBatch})
//       : super(const PaginationState.loading());

//   void init() {
//     if (_items.isEmpty) {
//       fetchFirstBatch();
//     }
//   }

//   Future<void> fetchFirstBatch() async {
//     try {
//       //  state = const PaginationState.loading();
//       final List<T> result = await fetchItems(null);
//       final DocumentSnapshot? lastDocument =
//           result.isNotEmpty ? (result.last as Item).documentSnapshot : null;
//       updateData(result, lastDocument);
//     } catch (e, stk) {
//       state = PaginationState.error(e, stk);
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

//   Future<void> refreshAds() async {
//     _items.clear();
//     noMoreAds = false;
//     lastDocumentSnapshot = null;
//     init();
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

// final homeRepositoryProvider = Provider<HomeRepository>((_) {
//   return HomeRepository();
// });

// final showHomeAdsProvider =
//     StateNotifierProvider<HomeAds<Item>, PaginationState<Item>>((ref) {
//   return HomeAds<Item>(
//     fetchItems: (lastDocument) {
//       return ref.read(homeRepositoryProvider).fetchHomeAds(lastDocument);
//     },
//     itemsPerBatch: 8,
//   )..init();
// });
