import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name; // Add this line
  final bool isAdmin;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name, // Add this line
    this.isAdmin = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name, // Add this line
      'isAdmin': isAdmin,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '', // Add this line
      isAdmin: map['isAdmin'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
