import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String userid;
  final String id;
  final String adTitle;
  final String adDescription;
  final String createdAt;
  final double price;
  final List<String> images;
  final String postedBy;
  final String categoryName;
  final String subCategoryName;
  final String brand;
  final String chargerType;
  final String tabletType;
  final DocumentSnapshot documentSnapshot;
  final DocumentReference<Map<String, dynamic>>? reference;
  const Item({
    required this.reference,
    required this.documentSnapshot,
    required this.chargerType,
    required this.tabletType,
    required this.brand,
    required this.userid,
    required this.id,
    required this.adTitle,
    required this.adDescription,
    required this.createdAt,
    required this.price,
    required this.images,
    required this.postedBy,
    required this.categoryName,
    required this.subCategoryName,
  });

  static List<String> getImages(List<dynamic> images) {
    List<String> imageList = [];
    for (final image in images) {
      imageList.add(image);
    }
    return imageList;
  }

  factory Item.fromJson(Map<String, dynamic> json, String productId,
      String createdAt, DocumentSnapshot doc, DocumentReference<Map<String,dynamic>>? reference) {
    return Item(
      reference: reference,
      id: productId,
      userid: json['userId'],
      adTitle: json['adTitle'],
      adDescription: json['adDescription'],
      createdAt: createdAt,
      price: json['price'],
      images: getImages(json['images']),
      postedBy: json['postedBy'],
      categoryName: json['categoryName'],
      subCategoryName: json['subCategoryName'],
      brand: json['brand'],
      documentSnapshot: doc,
      chargerType: json['charger_type'],
      tabletType: json['tablet_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adTitle': adTitle,
      'adDescription': adDescription,
      'price': price,
      'images': images,
      'postedBy': postedBy,
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userid,
      'brand': brand,
      'charger_type': chargerType,
      'tablet_type': tabletType,
    };
  }
}
