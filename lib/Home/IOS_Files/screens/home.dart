import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:flutter/cupertino.dart';

import '../../../constants/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    getAllData();
    super.initState();
  }

  getAllData() async {
    final fbCloudFireStore = handler.fireStore;
    QuerySnapshot<Map<String, dynamic>> data = await fbCloudFireStore
        .collection('AllAds')
        .orderBy('createdAt', descending: true)
        .get();
    for (final doc in data.docs) {
      DocumentReference adRef = doc['adReference'];
      DocumentSnapshot originalAdSnapshot = await adRef.get();
      print('${originalAdSnapshot.data()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Constants.screenBgColor,
        child: const Center(
          child: Text('Home Screen'),
        ),
      ),
    );
  }
}
