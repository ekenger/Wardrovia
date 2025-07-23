import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSampleCoupons extends StatefulWidget {
  const AddSampleCoupons({super.key});

  @override
  State<AddSampleCoupons> createState() => _AddSampleCouponsState();
}

class _AddSampleCouponsState extends State<AddSampleCoupons> {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addSampleCoupon23() async {
    final coupons = [
      {
        'code': 'HOSGELDIN10',
        'discountType': 'percentage',
        'discountValue': 10,
        'minOrderAmount': 100,
        'maxDiscount': 50,
        'expiryDate': DateTime.now().add(const Duration(days: 30)),
        'isActive': true,
        'description': 'Hoş geldin indirimi %10',
      },
      {
        'code': 'EK50',
        'discountType': 'fixed',
        'discountValue': 50,
        'minOrderAmount': 200,
        'maxDiscount': null,
        'expiryDate': DateTime.now().add(const Duration(days: 15)),
        'isActive': true,
        'description': '50 TL sabit indirim',
      },
      {
        'code': 'UCRETSIZ',
        'discountType': 'percentage',
        'discountValue': 100,
        'minOrderAmount': 0,
        'maxDiscount': 29.99,
        'expiryDate': DateTime.now().add(const Duration(days: 60)),
        'isActive': true,
        'description': 'Ücretsiz kargo',
      },
    ];

    for (var coupon in coupons) {
      await _firestore
          .collection('coupons')
          .doc(coupon['code'] as String)
          .set(coupon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        addSampleCoupon23();
      },
      child: Text("Kupon tanımla"),
    );
  }
}

class SampleCoupons {}
