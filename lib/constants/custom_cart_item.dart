class CartItem {
  final String productId;
  final String productName;
  final String price;
  final String imageUrl;
  final int quantity;
  final String size;
  final String color;
  final DateTime? addedAt;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.size,
    required this.color,
    this.addedAt,
  });

  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      price: data['price'] ?? '0 TL',
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
      size: data['size'] ?? 'M',
      color: data['color'] ?? 'Default',
      addedAt: data['addedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'size': size,
      'color': color,
      'addedAt': addedAt,
    };
  }

  
  double get priceAsDouble {
    return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }

  
  double get totalPrice {
    return priceAsDouble * quantity;
  }
}
