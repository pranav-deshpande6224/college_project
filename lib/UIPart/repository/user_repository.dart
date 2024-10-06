
class UserRepository {
  // Future<NewUser> getUserdata() async {
  //   AuthHandler handler = AuthHandler.authHandlerInstance;
  //   final fireStore = handler.fireStore;
  //   if (handler.newUser.user != null) {
  //     try {
  //       final querySnapshot = await fireStore.collection('users').get();
  //       if (querySnapshot.docs.isNotEmpty) {
  //         final userData = querySnapshot.docs.first.data();
  //         return NewUser.fromJson(userData);
  //       } else {
  //         throw Exception('No user data found');
  //       }
  //     } catch (e) {
  //       throw e.toString();
  //     }
  //   } else {
  //     throw Exception('User is not authenticated');
  //   }
  // }
}
