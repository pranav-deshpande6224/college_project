import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  StreamSubscription<List<Item>>? _adsSubscription;

  void _subscribeToAds(String category, String subCategory) {
    _adsSubscription = _listenToAds(category, subCategory).listen((ads) {
      if (ads.isNotEmpty) {
        _lastDocument =
            ads.last.documentSnapshot as DocumentSnapshot<Map<String, dynamic>>;
      }
      _hasMoreCategory = ads.length == _itemsPerPage;
      state = AsyncValue.data(CategoryAdsState(items: ads));
    }, onError: (error, stack) {
      state = AsyncValue.error(error, stack);
    });
  }

  Stream<List<Item>> _listenToAds(String category, String subCategory) {
    final firestore = handler.fireStore;
    return firestore
        .collection('Category')
        .doc(category)
        .collection('Subcategories')
        .doc(subCategory)
        .collection('Ads')
        .orderBy('createdAt', descending: true)
        .limit(_itemsPerPage)
        .snapshots()
        .asyncMap((snapshot) async {
      await Future.delayed(Duration(seconds: 1));
      List<Item> items = [];
      for (var doc in snapshot.docs) {
        DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
        DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
        final item = Item.fromJson(dataDoc.data()!, dataDoc.id, doc, ref);
        items.add(item);
      }
      return items;
    });
  }

  Future<void> fetchInitialItems(String category, String subCategory) async {
    if (_isLoadingCategory) return;
    _isLoadingCategory = true;
    if (handler.newUser.user != null) {
      try {
        _subscribeToAds(category, subCategory);
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

  Future<void> refreshItems(String category, String subCategory) async {
    if (_isLoadingCategory) return; // Prevent multiple simultaneous requests
    _lastDocument = null;
    _hasMoreCategory = true;
    state = AsyncValue.loading();
    await fetchInitialItems(category, subCategory);
  }

  void resetState() {
    _cancelSubscription();
    _hasMoreCategory = true;
    _isLoadingCategory = false;
    _lastDocument = null;
    state = AsyncValue.loading();
  }

  void _cancelSubscription() {
    _adsSubscription?.cancel();
    _adsSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }

  Future<void> fetchMoreItems(String category, String subCategory) async {
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

          return Item.fromJson(dataDoc.data()!, dataDoc.id, doc, ref);
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
