import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final List<String> sizes;
  final String imageBase64;
  final String collection;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.sizes,
    required this.imageBase64,
    required this.collection,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'sizes': sizes,
      'imageBase64': imageBase64,
      'collection': collection,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name']?.toString() ?? '', // Handle null case
      price: (map['price'] as num?)?.toDouble() ?? 0.0, // Handle null case
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Uncategorized',
      sizes: List<String>.from(map['sizes'] ?? []),
      imageBase64: map['imageBase64']?.toString() ?? '',
      collection: map['collection']?.toString() ?? '',
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    List<String>? sizes,
    String? imageBase64,
    String? collection,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      sizes: sizes ?? this.sizes,
      imageBase64: imageBase64 ?? this.imageBase64,
      collection: collection ?? this.collection,
    );
  }
}
