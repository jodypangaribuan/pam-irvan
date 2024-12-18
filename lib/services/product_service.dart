import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class ProductService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Add this line
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Wishlist operations
  Future<void> toggleWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final wishlist = List<String>.from(doc.data()?['wishlist'] ?? []);

    if (wishlist.contains(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
    }

    await docRef.update({'wishlist': wishlist});
  }

  Stream<List<String>> watchWishlist() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore.collection('users').doc(user.uid).snapshots().map(
          (doc) => List<String>.from(doc.data()?['wishlist'] ?? []),
        );
  }

  Future<bool> isInWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final wishlist = List<String>.from(doc.data()?['wishlist'] ?? []);
    return wishlist.contains(productId);
  }

  // Cart operations
  Future<void> addToCart(ProductModel product,
      [int quantity = 1, String size = '']) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartItem = CartItemModel(
      productId: product.id,
      quantity: quantity,
      product: product,
      size: size.isEmpty ? product.sizes.first : size,
      price: product.price,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product.id)
        .set(cartItem.toMap());
  }

  Future<void> removeFromCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .update({'quantity': quantity});
  }

  Future<void> incrementCartItem(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final currentQuantity = doc.data()?['quantity'] ?? 1;
    await docRef.update({'quantity': currentQuantity + 1});
  }

  Future<void> decrementCartItem(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final currentQuantity = doc.data()?['quantity'] ?? 1;
    if (currentQuantity <= 1) {
      await removeFromCart(productId);
    } else {
      await docRef.update({'quantity': currentQuantity - 1});
    }
  }

  Stream<List<CartItemModel>> watchCart() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItemModel.fromMap(doc.data()))
            .toList());
  }

  Stream<double> watchCartTotal() {
    return watchCart().map((items) {
      return items.fold(
          0.0, (total, item) => total + (item.price * item.quantity));
    });
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartRef =
        _firestore.collection('users').doc(user.uid).collection('cart');

    final cartItems = await cartRef.get();

    for (var doc in cartItems.docs) {
      await doc.reference.delete();
    }
  }
}
