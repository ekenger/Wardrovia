import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> addToCart({
    required String productId,
    required String productName,
    required String price,
    required String imageUrl,
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartItemId =
        '${productId}_${size ?? 'default'}_${color ?? 'default'}';

    final existingItem =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cartItems')
            .doc(cartItemId)
            .get();

    if (existingItem.exists) {
      final currentQuantity = existingItem.data()?['quantity'] ?? 0;
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cartItems')
          .doc(cartItemId)
          .update({
            'quantity': currentQuantity + quantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } else {
      final cartItem = {
        'productId': productId,
        'productName': productName,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'size': size ?? 'M',
        'color': color ?? 'Default',
        'addedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cartItems')
          .doc(cartItemId)
          .set(cartItem);
    }
  }

  static Future<void> removeFromCart(String cartItemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cartItems')
        .doc(cartItemId)
        .delete();
  }

  static Future<void> updateQuantity(String cartItemId, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cartItems')
        .doc(cartItemId)
        .update({'quantity': quantity});
  }

  static Stream<QuerySnapshot> getUserCartItems() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cartItems')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  static Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final cartItems =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cartItems')
            .get();

    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  static String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  static Stream<QuerySnapshot> getCartItems() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cartItems')
        .snapshots();
  }

  static Future<List<Map<String, dynamic>>> getCartItemsForOrder() async {
    final user = _auth.currentUser;
    final String _userId = user?.uid ?? '';
    if (_userId.isEmpty) throw Exception('User not authenticated');

    try {
      final cartSnapshot =
          await _firestore
              .collection('users')
              .doc(_userId)
              .collection('cartItems')
              .get();

      List<Map<String, dynamic>> cartItems = [];

      for (var doc in cartSnapshot.docs) {
        final cartData = doc.data();
        final productId = cartData['productId'];

        final productDoc =
            await _firestore.collection('products').doc(productId).get();

        if (productDoc.exists) {
          final productData = productDoc.data()!;

          cartItems.add({
            'productId': productId,
            'name': productData['name'] ?? '',
            'image': productData['imageUrl'] ?? '',
            'category': productData['category'] ?? '',
            'price': cartData['price'] ?? '0 TL',
            'quantity': cartData['quantity'] ?? 1,
          });
        } else {
          cartItems.add({
            'productId': productId,
            'name': cartData['productName'] ?? '',
            'image': cartData['imageUrl'] ?? '',
            'category': cartData['category'] ?? '',
            'price': cartData['price'] ?? '0 TL',
            'quantity': cartData['quantity'] ?? 1,
          });
        }
      }

      return cartItems;
    } catch (e) {
      throw Exception('Failed to get cart items: $e');
    }
  }
}
