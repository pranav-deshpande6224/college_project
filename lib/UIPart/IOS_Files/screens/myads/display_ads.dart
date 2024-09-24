import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/Authentication/IOS_Files/handlers/auth_handler.dart';
import 'package:college_project/UIPart/IOS_Files/model/item.dart';
import 'package:college_project/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DisplayAds extends ConsumerStatefulWidget {
  final int index;
  const DisplayAds({required this.index, super.key});

  @override
  ConsumerState<DisplayAds> createState() => _DisplayAdsState();
}

class _DisplayAdsState extends ConsumerState<DisplayAds> {
  late AuthHandler handler;
  Future<List<Item>>? ads;
  Future<List<Item>>? soldAds;
  Future<List<Item>> activeAdsAPI() async {
    List<Item> ads = [];
    try {
      if (handler.user != null) {
        QuerySnapshot<Map<String, dynamic>> data = await handler.fireStore
            .collection('users')
            .doc(handler.user!.uid)
            .collection('MyActiveAds')
            .orderBy('createdAt', descending: true)
            .get();

        for (final doc in data.docs) {
          Timestamp timeStamp = doc.data()['createdAt'];
          final dateString =
              DateFormat('dd--MM--yy').format(timeStamp.toDate());
          ads.add(Item.fromJson(doc.data(), doc.id, dateString));
        }
        return ads;
      } else {
        // Navigate to Login screen
        return ads;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  Future<List<Item>> soldAdsAPI() async {
    List<Item> ads = [];
    try {
      if (handler.user != null) {
        QuerySnapshot<Map<String, dynamic>> data = await handler.fireStore
            .collection('users')
            .doc(handler.user!.uid)
            .collection('MySoldAds')
            .orderBy('createdAt', descending: true)
            .get();

        for (final doc in data.docs) {
          String date = doc.data()['createdAt'];
          ads.add(Item.fromJson(doc.data(), doc.id, date));
        }
        return ads;
      } else {
        // Navigate to Login screen
        return ads; // Return empty list if user is null
      }
    } catch (e) {
      throw e.toString();
    }
  }

  void itemSold(Item item) async {
    try {
      // First remove from the Active Ads
      // Add that item to the sold Ads
      // Remove that item at the front end
      if (handler.user != null) {
        await handler.fireStore
            .collection('users')
            .doc(handler.user!.uid)
            .collection('MyActiveAds')
            .doc(item.id)
            .delete();
        await handler.fireStore
            .collection('users')
            .doc(handler.user!.uid)
            .collection('MySoldAds')
            .doc(item.id)
            .set(item.toJson());
        
      } else {
        // Navigate to Login screen
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget showSpinner() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(),
          SizedBox(
            height: 10,
          ),
          Text('Loading...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index == 0) {
      ads = activeAdsAPI();
    } else {
      soldAds = soldAdsAPI();
    }
    return FutureBuilder<List<Item>>(
      future: widget.index == 0 ? ads : soldAds,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return showSpinner();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (widget.index == 0) {
          return snapshot.data!.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No Active Ads'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, index) {
                    return AdCard(
                      ad: snapshot.data![index],
                      adSold: itemSold,
                      isSold: false,
                    );
                  },
                );
        } else {
          return snapshot.data!.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No Sold Ads',
                      style: GoogleFonts.roboto(),
                    ),
                  ],
                ))
              : ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, index) {
                    return AdCard(
                      ad: snapshot.data![index],
                      adSold: itemSold,
                      isSold: true,
                    );
                  },
                );
        }
      },
    );
  }
}
