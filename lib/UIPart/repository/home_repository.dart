import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeRepository {
  Future<List<Item>> fetchHomeAds() async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      List<Item> allItems = [];
      try {
        QuerySnapshot<Map<String, dynamic>> data = await fireStore
            .collection('AllAds')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();
        for (final doc in data.docs) {
          DocumentReference adRef = doc['adReference'];
          DocumentSnapshot originalAdSnapshot = await adRef.get();
          print('id of doc in home is ${originalAdSnapshot.id}');
          if (originalAdSnapshot.exists) {
            Map<String, dynamic> snaphsot =
                originalAdSnapshot.data() as Map<String, dynamic>;

            Timestamp createdAt = originalAdSnapshot.get('createdAt');
            String formattedDate =
                DateFormat('dd/MM/yyyy').format(createdAt.toDate());
            final adData =
                Item.fromJson(snaphsot, originalAdSnapshot.id, formattedDate);
            allItems.add(adData);
          }
        }
        return allItems;
      } catch (e) {
        throw e.toString();
      }
    } else {
      // No user exists Need to check this case also
      return [];
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((_) {
  return HomeRepository();
});
