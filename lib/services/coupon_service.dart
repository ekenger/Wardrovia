import 'package:cloud_firestore/cloud_firestore.dart';

class CouponService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>?> validateCoupon(String couponCode) async {
    try {
      final doc =
          await _firestore
              .collection('coupons')
              .doc(couponCode.toUpperCase())
              .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final expiryDate = (data['expiryDate'] as Timestamp).toDate();
      final isActive = data['isActive'] as bool;
      if (!isActive || DateTime.now().isAfter(expiryDate)) {
        return null;
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  static double calculateDiscount(
    double subtotal,
    Map<String, dynamic> coupon,
  ) {
    final discountType = coupon['discountType'] as String;
    final discountValue = (coupon['discountValue'] as num).toDouble();
    final minOrderAmount = (coupon['minOrderAmount'] as num?)?.toDouble() ?? 0;

    if (subtotal < minOrderAmount) return 0;

    if (discountType == 'percentage') {
      final discount = subtotal * (discountValue / 100);
      final maxDiscount = (coupon['maxDiscount'] as num?)?.toDouble();
      return maxDiscount != null ? discount.clamp(0, maxDiscount) : discount;
    } else {
      return discountValue.clamp(0, subtotal);
    }
  }
}
