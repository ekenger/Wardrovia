import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address.dart';
import '../models/payment_card.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _userId => _auth.currentUser?.uid ?? '';

  static Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required Address shippingAddress,
    required PaymentCard paymentMethod,
    String? couponCode,
    double discountAmount = 0.0,
  }) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    try {
      final orderId = _firestore.collection('orders').doc().id;

      final orderData = {
        'orderId': orderId,
        'userId': _userId,
        'userEmail': _auth.currentUser?.email,
        'items': items,
        'totalAmount': totalAmount,
        'discountAmount': discountAmount ?? 0,
        'finalAmount': totalAmount,
        'shippingAddress': shippingAddress.toFirestore(),
        'paymentMethod': {
          'cardType': paymentMethod.cardType,
          'lastFourDigits': paymentMethod.cardNumber.substring(
            paymentMethod.cardNumber.length - 4,
          ),
          'holderName': paymentMethod.cardHolderName,
        },
        'couponCode': couponCode,
        'orderStatus': 'confirmed',
        'paymentStatus': 'paid',
        'createdAt': FieldValue.serverTimestamp(),
        'estimatedDelivery': DateTime.now().add(const Duration(days: 7)),
        'shippedAt': null,
        'deliveredAt': null,
      };

      await _firestore.collection('orders').doc(orderId).set(orderData);

      await _clearUserCart();

      return orderId;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<void> _clearUserCart() async {
    if (_userId.isEmpty) return;

    final cartRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('cartItems');
    final cartItems = await cartRef.get();

    for (var doc in cartItems.docs) {
      await doc.reference.delete();
    }
  }

  static Future<Map<String, dynamic>?> getOrder(String orderId) async {
    if (_userId.isEmpty) return null;

    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  static Stream<QuerySnapshot> getUserOrders() {
    if (_userId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: _userId)
        .snapshots();
  }

  static Stream<QuerySnapshot> getUserOrdersByStatus(String status) {
    if (_userId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: _userId)
        .where('orderStatus', isEqualTo: status)
        .snapshots();
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    try {
      Map<String, dynamic> updateData = {'orderStatus': status};

      if (status == 'shipped') {
        updateData['shippedAt'] = FieldValue.serverTimestamp();
      } else if (status == 'delivered') {
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
