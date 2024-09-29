import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AdRepository {
  Future<List<Item>> fetchActiveAds() async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      final snapshot = await fireStore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('MyActiveAds')
          .orderBy('createdAt', descending: true)
          .get();
      List<Item> ads = [];
      for (final doc in snapshot.docs) {
        Timestamp timeStamp = doc.data()['createdAt'];
        final dateString = DateFormat('dd--MM--yy').format(timeStamp.toDate());
        print('id of the product of myAds is ${doc.id}');
        ads.add(Item.fromJson(doc.data(), doc.id, dateString));
      }
      return ads;
    } else {
      // No User exists so that Navigate to Login
      return [];
    }
  }

  Future<List<Item>> fetchSoldAds() async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      final snapshot = await fireStore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('MySoldAds')
          .orderBy('createdAt', descending: true)
          .get();
      List<Item> ads = [];
      for (final doc in snapshot.docs) {
        Timestamp timeStamp = doc.data()['createdAt'];
        final dateString = DateFormat('dd--MM--yy').format(timeStamp.toDate());
        ads.add(Item.fromJson(doc.data(), doc.id, dateString));
      }
      return ads;
    } else {
      //  No User exists so that Navigate to Login
      return [];
    }
  }
}

final adRepositoryProvider = Provider<AdRepository>((ref) {
  return AdRepository();
});
