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
  final String? brand;
  final DocumentSnapshot documentSnapshot;
  const Item({
    required this.documentSnapshot,
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

  factory Item.fromJson(Map<String, dynamic> json, String productId, String createdAt,
      DocumentSnapshot doc) {
    return Item(
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
      'userId': userid
    };
  }
}

// class Phones extends Item {
//   final String brand;
//   const Phones({
//     required super.userid,
//     required super.id,
//     required super.adTitle,
//     required super.adDescription,
//     required this.brand,
//     required super.createdAt,
//     required super.price,
//     required super.images,
//     required super.postedBy,
//     required super.categoryName,
//     required super.subCategoryName,
//   });
// }
