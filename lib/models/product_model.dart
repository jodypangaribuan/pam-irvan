import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageBase64;
  final String category;
  final DateTime createdAt;
  final int stock;
  final List<String> sizes;
  final String collection;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageBase64,
    required this.category,
    required this.createdAt,
    required this.stock,
    required this.sizes,
    required this.collection,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageBase64': imageBase64,
      'category': category,
      'createdAt': createdAt,
      'stock': stock,
      'sizes': sizes,
      'collection': collection,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageBase64: map['imageBase64'] ?? '',
      category: map['category'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      stock: map['stock'] ?? 0,
      sizes: List<String>.from(map['sizes'] ?? []),
      collection: map['collection'] ?? '',
    );
  }
}
