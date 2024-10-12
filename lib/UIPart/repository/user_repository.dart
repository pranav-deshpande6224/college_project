import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';

class UserRepository {
  Future<void> getUserdata() async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> querySnapshot = await fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .get();
        handler.newUser.email = querySnapshot['email'];
        handler.newUser.firstName = querySnapshot['firstName'];
      } catch (e) {
        throw e.toString();
      }
    } else {
      throw Exception('User is not authenticated');
    }
  }

  Future<void> putData(String firstName) async {
    AuthHandler handler = AuthHandler.authHandlerInstance;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        await fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .update({'firstName': firstName});
        handler.newUser.firstName = firstName;
      } catch (e) {
        throw e.toString();
      }
    }
  }
}
