import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Wardrovia/services/order_service.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: OrderService.getOrder(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState(context);
          }

          final orderData = snapshot.data!;
          return _buildOrderDetail(context, orderData);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, "Sipariş bulunamadı."),
          const Expanded(
            child: Center(
              child: Text(
                'Sipariş bulunamadı.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(
    BuildContext context,
    Map<String, dynamic> orderData,
  ) {
    final items = orderData['items'] as List? ?? [];
    final orderStatus = orderData['orderStatus'] ?? 'confirmed';
    final shippingAddress =
        orderData['shippingAddress'] as Map<String, dynamic>? ?? {};
    final createdAt = orderData['createdAt'] as Timestamp?;
    final finalAmount = orderData['finalAmount'] ?? 0.0;

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, "Sipariş Detayı"),

          const SizedBox(height: 41),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatusTimeline(orderStatus, createdAt),

                  const SizedBox(height: 40),

                  _buildOrderItems(items, finalAmount),

                  const SizedBox(height: 40),

                  _buildShippingDetails(shippingAddress),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 27, right: 27, top: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(child: Image.asset('assets/icons/backbutton.png')),
          ),

          Expanded(
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.gabarito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 19 / 16,
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

  Widget _buildStatusTimeline(String orderStatus, Timestamp? createdAt) {
    final statusList = ['confirmed', 'shipped', 'delivered'];
    final statusLabels = {
      'confirmed': 'Order Confirmed',
      'shipped': 'Shipped',
      'delivered': 'Delivered',
    };

    final currentIndex = statusList.indexOf(orderStatus);
    final dateStr =
        createdAt != null
            ? "${createdAt.toDate().day} ${_getMonthName(createdAt.toDate().month)}"
            : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStatusItem(
            isCompleted: orderStatus == 'delivered',
            isActive: orderStatus == 'delivered',
            title: "Teslim Edildi",
            date: orderStatus == 'delivered' ? dateStr : '',
          ),
          const SizedBox(height: 51),
          _buildStatusItem(
            isCompleted: currentIndex >= 1,
            isActive: orderStatus == 'shipped',
            title: "Kargoya Verildi",
            date: currentIndex >= 1 ? dateStr : '',
          ),
          const SizedBox(height: 51),
          _buildStatusItem(
            isCompleted: currentIndex >= 0,
            isActive: orderStatus == 'confirmed',
            title: "Sipariş Onaylandı",
            date: currentIndex >= 0 ? dateStr : '',
          ),
          const SizedBox(height: 51),
          _buildStatusItem(
            isCompleted: true,
            isActive: false,
            title: "Sipariş Alındı",
            date: dateStr,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(List items, double finalAmount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alınan Ürün",
            style: GoogleFonts.gabarito(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 19 / 16,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 11),
          Container(
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset('assets/icons/receipt1.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${items.length} ürün",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 20 / 16,
                            color: const Color(0xFF272727),
                          ),
                        ),
                        Text(
                          "${finalAmount.toStringAsFixed(2)} TL",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 1.6,
                            color: const Color(0xFF272727).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Tümünü Gör",
                    style: GoogleFonts.gabarito(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 14 / 12,
                      color: const Color(0xFF8E6CEF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingDetails(Map<String, dynamic> shippingAddress) {
    final address = shippingAddress['address'] ?? 'Adres bilgisi bulunamadı';
    final phone = shippingAddress['phone'] ?? 'Telefon bilgisi bulunamadı';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sipariş Detayları",
            style: GoogleFonts.gabarito(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 19 / 16,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 11),
          Container(
            width: 342,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.6,
                      color: const Color(0xFF272727),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.6,
                      color: const Color(0xFF272727),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required bool isCompleted,
    required bool isActive,
    required String title,
    required String date,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color:
                isCompleted ? const Color(0xFF8E6CEF) : const Color(0xFFEFEAF5),
            borderRadius: BorderRadius.circular(100),
          ),
          child:
              isCompleted
                  ? const Icon(Icons.check, size: 8, color: Colors.white)
                  : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 20 / 16,
              color:
                  isActive
                      ? const Color(0xFF272727)
                      : const Color(0xFF272727).withOpacity(0.5),
            ),
          ),
        ),
        if (date.isNotEmpty)
          Text(
            date,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.6,
              color:
                  isActive
                      ? const Color(0xFF272727)
                      : const Color(0xFF272727).withOpacity(0.5),
            ),
          ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month];
  }
}
