class CartItemModel {
  final String productId;
  final int quantity;
  final double price;
  final String name;
  final String imageBase64;

  CartItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.name,
    required this.imageBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'name': name,
      'imageBase64': imageBase64,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'],
      quantity: map['quantity'],
      price: map['price'],
      name: map['name'],
      imageBase64: map['imageBase64'],
    );
  }
}
