import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wardrovia/constants/custom_cart_item.dart';
import 'package:Wardrovia/constants/custom_explore_category_button.dart';
import 'package:Wardrovia/screens/checkout_page.dart';
import 'package:Wardrovia/services/cart_service.dart';
import 'package:Wardrovia/services/coupon_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
  final TextEditingController _couponController = TextEditingController();
  Map<String, dynamic>? appliedCoupon;
  bool isApplyingCoupon = false;
  String? couponError;

  // Sabit değerler
  static const double freeShippingThreshold = 500.0;
  static const double shippingFee = 49.99;
  static const double taxRate = 0.1;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: CartService.getUserCartItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Bir hata oluştu: ${snapshot.error}',
                  style: GoogleFonts.figtree(fontSize: 16),
                ),
              );
            }

            final cartDocs = snapshot.data?.docs ?? [];

            if (cartDocs.isEmpty) {
              return _buildEmptyCart();
            }

            final cartItems =
                cartDocs
                    .map(
                      (doc) => CartItem.fromFirestore(
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();

            return _buildCartWithItems(cartItems);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      children: [
        // Header
        _buildHeader(hasItems: false),

        // Boş Sepet
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/parcel.png', width: 100, height: 100),
                const SizedBox(height: 27),
                Text(
                  "Sepetiniz şu anda boş.",
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 27),
                const CustomExploreCategoryButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartWithItems(List<CartItem> cartItems) {
    _cartItems = cartItems;
    final subtotal = _calculateSubtotal(cartItems);
    final discount =
        appliedCoupon != null
            ? CouponService.calculateDiscount(subtotal, appliedCoupon!)
            : 0.0;
    final discountedSubtotal = subtotal - discount;
    final shipping =
        discountedSubtotal >= freeShippingThreshold ? 0.0 : shippingFee;
    final tax = discountedSubtotal * taxRate;
    final total = discountedSubtotal + shipping;

    return Column(
      children: [
        // Header
        _buildHeader(hasItems: true),

        // Content - Expanded ile kaydırılabilir alan
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Ürün listesi
                _buildProductList(cartItems),
              ],
            ),
          ),
        ),

        // Alt kısım - Payment info, promo code ve checkout button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Payment info
              Column(
                children: [
                  _buildPaymentRow(
                    'Ara Toplam',
                    '${subtotal.toStringAsFixed(2)} TL',
                  ),

                  if (discount > 0)
                    Column(
                      children: [
                        _buildPaymentRow(
                          appliedCoupon!['code'],
                          '-${discount.toStringAsFixed(2)} TL',
                          isDiscount: true,
                        ),
                      ],
                    ),
                  _buildPaymentRow(
                    'Gönderim Ücreti',
                    '${shipping.toStringAsFixed(2)} TL',
                  ),

                  _buildPaymentRow('Vergi', '${tax.toStringAsFixed(2)} TL'),

                  _buildPaymentRow(
                    'Toplam',
                    '${total.toStringAsFixed(2)} TL',
                    isTotal: true,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Promo code
              _buildPromoCode(),

              const SizedBox(height: 40),

              // Checkout button
              SizedBox(
                width: 342,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _proceedToCheckout(total),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E6CEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Sepeti Onayla',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({required bool hasItems}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset('assets/icons/backbutton.png'),
          ), // Balance for center alignment
          Text(
            'Sepetim',
            style: GoogleFonts.gabarito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF272727),
            ),
          ),
          if (hasItems)
            GestureDetector(
              onTap: _showRemoveAllDialog,
              child: Text(
                'Sepeti Boşalt',
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF272727),
                ),
              ),
            )
          else
            const SizedBox(width: 81),
        ],
      ),
    );
  }

  Widget _buildProductList(List<CartItem> cartItems) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children:
            cartItems.asMap().entries.map((entry) {
              final item = entry.value;
              return _buildCartItem(item);
            }).toList(),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      width: 342,
      height: 80,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage(item.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and price row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: GoogleFonts.figtree(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF272727),
                          height: 1.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.price,
                      style: GoogleFonts.gabarito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF272727),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                // Beden - Renk - Adet Row'u
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Beden - ${item.size}',
                            style: GoogleFonts.figtree(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF272727),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Renk - ${item.color}',
                            style: GoogleFonts.figtree(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF272727),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity controls
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _updateQuantity(item, item.quantity + 1),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8E6CEF),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/icons/add.png',
                              width: 12,
                              height: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.quantity}',
                          style: GoogleFonts.figtree(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF272727),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _updateQuantity(item, item.quantity - 1),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8E6CEF),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/icons/minus.png',
                              width: 12,
                              height: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color:
                isDiscount
                    ? const Color(0xFF5FB567)
                    : const Color.fromARGB(255, 164, 164, 164),
          ),
        ),
        Text(
          value,
          style:
              isTotal
                  ? GoogleFonts.gabarito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF272727),
                  )
                  : GoogleFonts.figtree(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        isDiscount
                            ? const Color(0xFF5FB567)
                            : const Color(0xFF272727),
                  ),
        ),
      ],
    );
  }

  Widget _buildPromoCode() {
    return Container(
      width: 342,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Discount icon
          Container(
            margin: const EdgeInsets.only(left: 16),
            width: 24,
            height: 24,
            child: Image.asset('assets/icons/discountshape.png'),
          ),

          const SizedBox(width: 13),

          // Text field
          Expanded(
            child: TextField(
              controller: _couponController,
              style: GoogleFonts.figtree(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF272727),
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Kupon Kodu',
                hintStyle: GoogleFonts.figtree(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF272727),
                  height: 1.6,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Apply button
          GestureDetector(
            onTap: isApplyingCoupon ? null : _applyCoupon,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF8E6CEF),
                shape: BoxShape.circle,
              ),
              child:
                  isApplyingCoupon
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Image.asset('assets/icons/arrowright.png'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _calculateSubtotal(List<CartItem> items) {
    return items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    // CartItem'dan document ID'sini oluştur
    final cartItemId = '${item.productId}_${item.size}_${item.color}';

    if (newQuantity <= 0) {
      await CartService.removeFromCart(cartItemId);
    } else {
      await CartService.updateQuantity(cartItemId, newQuantity);
    }
  }

  Future<void> _applyCoupon() async {
    final couponCode = _couponController.text.trim();
    if (couponCode.isEmpty) return;

    setState(() {
      isApplyingCoupon = true;
      couponError = null;
    });

    final coupon = await CouponService.validateCoupon(couponCode);

    setState(() {
      isApplyingCoupon = false;
      if (coupon != null) {
        appliedCoupon = coupon;
        couponError = null;
        _couponController.clear();
      } else {
        couponError = 'Geçersiz kupon kodu';
      }
    });
  }

  void _showRemoveAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sepeti Temizle',
            style: GoogleFonts.gabarito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Tüm ürünleri sepetinizden kaldırmak istediğinizden emin misiniz?',
            style: GoogleFonts.figtree(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: GoogleFonts.figtree(color: const Color(0xFF272727)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeAllItems();
              },
              child: Text(
                'Temizle',
                style: GoogleFonts.figtree(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeAllItems() async {
    // Tüm sepet öğelerini kaldır
    final cartDocs = await CartService.getUserCartItems().first;
    for (var doc in cartDocs.docs) {
      await CartService.removeFromCart(doc.id);
    }
  }

  void _proceedToCheckout(double total) {
    final subtotal = _calculateSubtotal(_cartItems);
    final discount =
        appliedCoupon != null
            ? CouponService.calculateDiscount(subtotal, appliedCoupon!)
            : 0.0;
    final discountedSubtotal = subtotal - discount;
    final shipping =
        discountedSubtotal >= freeShippingThreshold ? 0.0 : shippingFee;
    final tax = discountedSubtotal * taxRate;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CheckoutPage(
              subtotal: subtotal,
              shipping: shipping,
              tax: tax,
              total: total,
              appliedCoupon: appliedCoupon,
              discountAmount: discount,
            ),
      ),
    );
  }
}
