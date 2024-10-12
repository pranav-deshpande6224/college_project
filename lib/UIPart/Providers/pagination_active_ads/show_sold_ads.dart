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
    if (_isLoadingSold) return;
    _soldLastDocument = null;
    _hasMoreSold = true;
    await fetchInitialItems();
  }

   void resetState() {
    _hasMoreSold = true;
    _isLoadingSold = false;
    _soldLastDocument = null;
    state = AsyncValue.loading();
  }


  void deleteItem(Item item) {
    state = AsyncValue.data(state.asData!.value.copyWith(
        items: state.asData!.value.items.where((element) {
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
    StateNotifierProvider<ShowSoldAds, AsyncValue<SoldAdState>>(
        (ref) {
  return ShowSoldAds();
});
