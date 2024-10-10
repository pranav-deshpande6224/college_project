import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:intl/intl.dart';

class HomeRepository {
  Future<List<Item>> fetchHomeAds(DocumentSnapshot? lastDocument) async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        Query<Map<String, dynamic>> query = fireStore
            .collection('AllAds')
            .orderBy('createdAt', descending: true)
            .limit(8);
        if (lastDocument != null) {
          query = query.startAfterDocument(lastDocument);
        }
        final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
        List<Item> items = [];
        for (final doc in snapshot.docs) {
          DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
          DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
          Timestamp timeStamp = doc.data()['createdAt'];
          final dateString =
              DateFormat('dd--MM--yy').format(timeStamp.toDate());
          final item =
              Item.fromJson(dataDoc.data()!, dataDoc.id, dateString, doc);
          items.add(item);
        }
        return items;
      } catch (e) {
        throw e.toString();
      }
    } else {
      // No user exists Need to check this case also
      return [];
    }
  }
}
