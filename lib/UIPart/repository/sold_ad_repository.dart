import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:intl/intl.dart';

class SoldAdRepository {
  Future<List<Item>> fetchSoldAds(DocumentSnapshot? lastDocument) async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        Query<Map<String, dynamic>> query = fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MySoldAds')
            .orderBy('createdAt', descending: true)
            .limit(5);
        if (lastDocument != null) {
          query = query.startAfterDocument(lastDocument);
        }
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        final docs = querySnapshot.docs.map<Item>((doc) {
          Timestamp timeStamp = doc.data()['createdAt'];
          final dateString =
              DateFormat('dd--MM--yy').format(timeStamp.toDate());
          return Item.fromJson(doc.data(), doc.id, dateString, doc);
        }).toList();
        return docs;
      } catch (e) {
        throw e.toString();
      }
    } else {
      // TODO Handle the case when the user is not authenticated
      return [];
    }
  }
}
