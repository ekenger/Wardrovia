import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart' as models;

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  static String get _userId => _auth.currentUser?.uid ?? '';

  static Future<void> createUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (_userId.isEmpty) return;

    final user = models.User(
      id: _userId,
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(_userId).set(user.toFirestore());
  }

  static Stream<models.User?> getUserStream() {
    if (_userId.isEmpty) return Stream.value(null);

    return _firestore.collection('users').doc(_userId).snapshots().map((doc) {
      if (doc.exists) {
        return models.User.fromFirestore(doc.data()!);
      }
      return null;
    });
  }

  static Future<void> updateUser(models.User user) async {
    if (_userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .update(user.toFirestore());
  }

  static Future<void> updateUserField(String field, dynamic value) async {
    if (_userId.isEmpty) return;

    await _firestore.collection('users').doc(_userId).update({
      field: value,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  static Future<void> updateProfileImage(String imageUrl) async {
    await updateUserField('profileImage', imageUrl);
  }
}
