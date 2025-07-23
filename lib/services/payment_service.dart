import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_card.dart';

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _userId => _auth.currentUser?.uid ?? '';

  static Stream<QuerySnapshot> getUserPaymentMethods() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('payment_methods')
        .orderBy('isDefault', descending: true)
        .snapshots();
  }

  static Future<void> addPaymentMethod(PaymentCard card) async {
    if (_userId.isEmpty) return;

    if (card.isDefault) {
      await _removeDefaultFromOthers();
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('payment_methods')
        .doc(card.id)
        .set(card.toFirestore());
  }

  static Future<void> updatePaymentMethod(PaymentCard card) async {
    if (_userId.isEmpty) return;

    if (card.isDefault) {
      await _removeDefaultFromOthers();
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('payment_methods')
        .doc(card.id)
        .update(card.toFirestore());
  }

  static Future<void> deletePaymentMethod(String cardId) async {
    if (_userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('payment_methods')
        .doc(cardId)
        .delete();
  }

  static Future<void> setDefaultPaymentMethod(String cardId) async {
    if (_userId.isEmpty) return;

    await _removeDefaultFromOthers();

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('payment_methods')
        .doc(cardId)
        .update({'isDefault': true});
  }

  static Future<void> _removeDefaultFromOthers() async {
    final cards =
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('payment_methods')
            .where('isDefault', isEqualTo: true)
            .get();

    for (var doc in cards.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }

  static Future<PaymentCard?> getDefaultPaymentMethod() async {
    if (_userId.isEmpty) return null;

    final snapshot =
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('payment_methods')
            .where('isDefault', isEqualTo: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return PaymentCard.fromFirestore(snapshot.docs.first.data());
    }
    return null;
  }

  static String detectCardType(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');

    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      return 'Mastercard';
    } else if (cardNumber.startsWith('3')) {
      return 'American Express';
    } else {
      return 'Unknown';
    }
  }
}
