import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String adTitle;
  final String adDescription;
  final String createdAt;
  final double price;
  final List<String> images;
  final String postedBy;
  final String categoryName;
  final String subCategoryName;
  const Item({
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

  factory Item.fromJson(
      Map<String, dynamic> json, String id, String createdAt) {
    return Item(
      id: id,
      adTitle: json['adTitle'],
      adDescription: json['adDescription'],
      createdAt: createdAt,
      price: json['price'],
      images: getImages(json['images']),
      postedBy: json['postedBy'],
      categoryName: json['categoryName'],
      subCategoryName: json['subCategoryName'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'adTitle':adTitle,
      'adDescription':adDescription,
      'price':price,
      'images':images,
      'postedBy':postedBy,
      'categoryName':categoryName,
      'subCategoryName':subCategoryName,
      'createdAt':FieldValue.serverTimestamp(),
    };
  }
}

class Phones extends Item {
  final String brand;
  const Phones({
    required super.id,
    required super.adTitle,
    required super.adDescription,
    required this.brand,
    required super.createdAt,
    required super.price,
    required super.images,
    required super.postedBy,
    required super.categoryName,
    required super.subCategoryName,
  });
}
