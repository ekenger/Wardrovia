import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address.dart';

class AddressService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _userId => _auth.currentUser?.uid ?? '';

  static Stream<QuerySnapshot> getUserAddresses() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('addresses')
        .orderBy('isDefault', descending: true)
        .snapshots();
  }

  static Future<void> addAddress(Address address) async {
    if (_userId.isEmpty) return;

    
    if (address.isDefault) {
      await _removeDefaultFromOthers();
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('addresses')
        .doc(address.id)
        .set(address.toFirestore());
  }

  static Future<void> updateAddress(Address address) async {
    if (_userId.isEmpty) return;

    
    if (address.isDefault) {
      await _removeDefaultFromOthers();
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('addresses')
        .doc(address.id)
        .update(address.toFirestore());
  }

  static Future<void> deleteAddress(String addressId) async {
    if (_userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  static Future<void> setDefaultAddress(String addressId) async {
    if (_userId.isEmpty) return;

    
    await _removeDefaultFromOthers();

    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('addresses')
        .doc(addressId)
        .update({'isDefault': true});
  }

  static Future<void> _removeDefaultFromOthers() async {
    final addresses =
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('addresses')
            .where('isDefault', isEqualTo: true)
            .get();

    for (var doc in addresses.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }

  static Future<Address?> getDefaultAddress() async {
    if (_userId.isEmpty) return null;

    final snapshot =
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('addresses')
            .where('isDefault', isEqualTo: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return Address.fromFirestore(snapshot.docs.first.data());
    }
    return null;
  }
}
