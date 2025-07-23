import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> addToFavorites({
    required String productId,
    required String itemName,
    required String imageUrl,
    required String itemPrice,
    required String targetGender,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoriteItem = {
      'productId': productId,
      'itemName': itemName,
      'imageUrl': imageUrl,
      'itemPrice': itemPrice,
      'targetGender': targetGender,
      'addedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .set(favoriteItem);
  }

  static Future<void> removeFromFavorites(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  static Future<bool> isFavorite(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(productId)
            .get();

    return doc.exists;
  }

  static Stream<QuerySnapshot> getUserFavorites() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}
