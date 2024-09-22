import 'package:flutter/material.dart';

class FavAds extends StatefulWidget {
  const FavAds({super.key});

  @override
  State<FavAds> createState() => _FavAdsState();
}

class _FavAdsState extends State<FavAds> {
  @override
  Widget build(BuildContext context) {
    return   const Center(
      child: Text('Favourite Ads'),
    );
  }
}