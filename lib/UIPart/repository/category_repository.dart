import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CategoryRepository {
  Future<List<Item>> getThatCategoryData(DocumentSnapshot? lastDocument,
      String categoryName, String subCategoryName) async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      
      try {
        Query<Map<String, dynamic>> query = fireStore
            .collection('Category')
            .doc(categoryName)
            .collection('Subcategories')
            .doc(subCategoryName)
            .collection('Ads')
            .orderBy('createdAt', descending: true)
            .limit(5);
        if (lastDocument != null) {
            query = query.startAfterDocument(lastDocument);
        }
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
        return items;
      } catch (e) {
        throw e.toString();
      }
    } else {
      // TODO NoUSer Navigate to Login Screen
      return [];
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((_) {
  return CategoryRepository();
});
