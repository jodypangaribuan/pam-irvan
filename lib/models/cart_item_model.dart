import 'product_model.dart';

class CartItemModel {
  final String productId;
  final int quantity;
  final ProductModel product;
  final String size;
  final double price;

  CartItemModel({
    required this.productId,
    required this.quantity,
    required this.product,
    required this.size,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'size': size,
      'price': price,
      'product': product.toMap(),
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId']?.toString() ?? '', // Handle null case
      quantity: (map['quantity'] as num?)?.toInt() ?? 1, // Handle null case
      size: map['size']?.toString() ?? '', // Handle null case
      price: (map['price'] as num?)?.toDouble() ?? 0.0, // Handle null case
      product: ProductModel.fromMap(
        map['product'] as Map<String, dynamic>? ?? {}, // Handle null case
        map['productId']?.toString() ?? '', // Handle null case
      ),
    );
  }

  CartItemModel copyWith({
    String? productId,
    int? quantity,
    ProductModel? product,
    String? size,
    double? price,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
      size: size ?? this.size,
      price: price ?? this.price,
    );
  }
}
