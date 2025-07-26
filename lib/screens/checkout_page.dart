import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/address.dart';
import '../models/payment_card.dart';
import '../services/address_service.dart';
import '../services/payment_service.dart';
import 'add_address_page.dart';
import 'add_payment_page.dart';
import 'package:Wardrovia/screens/order_placed_page.dart';
import 'package:Wardrovia/services/coupon_service.dart';
import 'package:Wardrovia/services/order_service.dart';
import 'package:Wardrovia/services/cart_service.dart';
import 'dart:async';

class CheckoutPage extends StatefulWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final Map<String, dynamic>? appliedCoupon;
  final double discountAmount;

  const CheckoutPage({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.appliedCoupon,
    this.discountAmount = 0.0,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Address? selectedAddress;
  PaymentCard? selectedPaymentMethod;
  bool _isPlacingOrder = false;
  List<Map<String, dynamic>> _cartItems = [];
  StreamSubscription? _cartSubscription;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
    _loadCartItems();
  }

  Future<void> _loadDefaults() async {
    final defaultAddress = await AddressService.getDefaultAddress();
    final defaultPayment = await PaymentService.getDefaultPaymentMethod();

    setState(() {
      selectedAddress = defaultAddress;
      selectedPaymentMethod = defaultPayment;
    });
  }

  void _loadCartItems() {
    _cartSubscription = CartService.getUserCartItems().listen((snapshot) {
      final items =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'productId': doc.id,
              'name': data['name'] ?? '',
              'price': data['price'] ?? 0.0,
              'quantity': data['quantity'] ?? 1,
              'image': data['image'] ?? '',
              'category': data['category'] ?? '',
            };
          }).toList();

      if (mounted) {
        setState(() {
          _cartItems = items;
        });
      }
    });
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 41),

                    _buildShippingAddressSection(),

                    const SizedBox(height: 16),

                    _buildPaymentMethodSection(),

                    const SizedBox(height: 134),

                    _buildOrderSummary(),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),

            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF272727),
                size: 16,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Alışverişi Tamamla',
                style: GoogleFonts.gabarito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF272727),
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildShippingAddressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _navigateToAddressSelection(),
        child: Container(
          width: 342,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teslimat Adresi',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF272727).withOpacity(0.5),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedAddress?.formattedAddress ??
                            'Teslimat Adresi Ekleyiniz',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF272727),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF272727),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _navigateToPaymentSelection(),
        child: Container(
          width: 342,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ödeme Yöntemi',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF272727).withOpacity(0.5),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedPaymentMethod?.maskedCardNumber ??
                            'Ödeme Yöntemi Ekleyiniz',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF272727),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF272727),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSummaryRow(
            'Ara Toplam',
            '${widget.subtotal.toStringAsFixed(2)} TL',
          ),
          const SizedBox(height: 12),
          if (widget.appliedCoupon != null && widget.discountAmount > 0) ...[
            _buildSummaryRow(
              widget.appliedCoupon!['code'],
              '-${widget.discountAmount.toStringAsFixed(2)} TL',
              isDiscount: true,
            ),
            const SizedBox(height: 12),
          ],
          _buildSummaryRow(
            'Gönderim Ücreti',
            '${widget.shipping.toStringAsFixed(2)} TL',
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Vergi', '${widget.tax.toStringAsFixed(2)} TL'),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Toplam',
            '${widget.total.toStringAsFixed(2)} TL',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
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
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color:
                isDiscount
                    ? const Color(0xFF5FB567)
                    : const Color(0xFF272727).withOpacity(0.5),
            height: 1.25,
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
                    height: 1.19,
                  )
                  : GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        isDiscount
                            ? const Color(0xFF5FB567)
                            : const Color(0xFF272727),
                    height: 1.25,
                  ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      width: 390,
      height: 100,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Container(
                width: 342,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E6CEF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ElevatedButton(
                  onPressed:
                      _canPlaceOrder() && !_isPlacingOrder ? _placeOrder : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E6CEF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child:
                        _isPlacingOrder
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.total.toStringAsFixed(2)} TL',
                                  style: GoogleFonts.gabarito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.19,
                                  ),
                                ),
                                Text(
                                  'Onayla ve Öde',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ),

          Container(
            width: 134,
            height: 5,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF272727),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }

  bool _canPlaceOrder() {
    return selectedAddress != null && selectedPaymentMethod != null;
  }

  void _navigateToAddressSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressPage(selectedAddress: selectedAddress),
      ),
    );

    if (result != null && result is Address) {
      setState(() {
        selectedAddress = result;
      });
    }
  }

  void _navigateToPaymentSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddPaymentPage(selectedPaymentMethod: selectedPaymentMethod),
      ),
    );

    if (result != null && result is PaymentCard) {
      setState(() {
        selectedPaymentMethod = result;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (!_canPlaceOrder()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen adres ve ödeme yöntemi seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sepetiniz boş'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final completeCartItems = await CartService.getCartItemsForOrder();

      final orderId = await OrderService.createOrder(
        items: completeCartItems,
        totalAmount: widget.total,
        shippingAddress: selectedAddress!,
        paymentMethod: selectedPaymentMethod!,
        couponCode: widget.appliedCoupon?['code'],
        discountAmount: widget.discountAmount,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderPlacedPage(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sipariş oluşturulurken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }
}
