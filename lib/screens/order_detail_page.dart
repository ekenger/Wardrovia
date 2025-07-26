import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Wardrovia/services/order_service.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  OrderDetailPage({super.key, required this.orderId});

  Map<String, dynamic>? _orderData;

  void _setOrderData(Map<String, dynamic> data) {
    _orderData = data;
  }

  String _getCreatedDate(Timestamp? createdAt) {
    if (createdAt == null) return '';
    return "${createdAt.toDate().day} ${_getMonthName(createdAt.toDate().month)}";
  }

  String _getShippedDate() {
    if (_orderData == null) return '';
    final shippedAt = _orderData!['shippedAt'] as Timestamp?;
    if (shippedAt == null) return '';
    return "${shippedAt.toDate().day} ${_getMonthName(shippedAt.toDate().month)}";
  }

  String _getDeliveredDate() {
    if (_orderData == null) return '';
    final deliveredAt = _orderData!['deliveredAt'] as Timestamp?;
    if (deliveredAt == null) return '';
    return "${deliveredAt.toDate().day} ${_getMonthName(deliveredAt.toDate().month)}";
  }

  String _getEstimatedDeliveryDate() {
    if (_orderData == null) return '';
    final estimatedDelivery = _orderData!['estimatedDelivery'];
    DateTime date;

    if (estimatedDelivery is Timestamp) {
      date = estimatedDelivery.toDate();
    } else if (estimatedDelivery is DateTime) {
      date = estimatedDelivery;
    } else {
      return '';
    }

    return "Tahmini: ${date.day} ${_getMonthName(date.month)}";
  }

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
          _setOrderData(orderData);
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

                  _buildOrderItems(context, items, finalAmount),

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildStatusItem(
            isCompleted: orderStatus == 'delivered',
            isActive: orderStatus == 'delivered',
            title: "Teslim Edildi",
            date:
                orderStatus == 'delivered'
                    ? _getDeliveredDate()
                    : _getEstimatedDeliveryDate(),
            isEstimated: orderStatus != 'delivered',
          ),
          const SizedBox(height: 51),
          _buildStatusItem(
            isCompleted: ['shipped', 'delivered'].contains(orderStatus),
            isActive: orderStatus == 'shipped',
            title: "Kargoya Verildi",
            date:
                ['shipped', 'delivered'].contains(orderStatus)
                    ? _getShippedDate()
                    : '',
          ),
          const SizedBox(height: 51),
          _buildStatusItem(
            isCompleted: [
              'confirmed',
              'shipped',
              'delivered',
            ].contains(orderStatus),
            isActive: orderStatus == 'confirmed',
            title: "Sipariş Onaylandı",
            date:
                ['confirmed', 'shipped', 'delivered'].contains(orderStatus)
                    ? _getCreatedDate(createdAt)
                    : '',
          ),
          const SizedBox(height: 51),
          _buildStatusItem(
            isCompleted: true,
            isActive: false,
            title: "Sipariş Alındı",
            date: _getCreatedDate(createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(
    BuildContext context,
    List items,
    double finalAmount,
  ) {
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
          GestureDetector(
            onTap: () {
              _showOrderItemsDialog(context, items);
            },
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
          ),
        ],
      ),
    );
  }

  Widget _buildShippingDetails(Map<String, dynamic> shippingAddress) {
    // Adres bilgilerini düzgün şekilde parse et
    String formattedAddress = 'Adres bilgisi bulunamadı';
    String phoneNumber = 'Telefon bilgisi bulunamadı';

    if (shippingAddress.isNotEmpty) {
      // Adres bilgilerini birleştir
      final addressLine1 = shippingAddress['addressLine1'] ?? '';
      final addressLine2 = shippingAddress['addressLine2'] ?? '';
      final city = shippingAddress['city'] ?? '';
      final state = shippingAddress['state'] ?? '';
      final postalCode = shippingAddress['postalCode'] ?? '';
      final country = shippingAddress['country'] ?? '';

      List<String> addressParts = [];
      if (addressLine1.isNotEmpty) addressParts.add(addressLine1);
      if (addressLine2.isNotEmpty) addressParts.add(addressLine2);
      if (city.isNotEmpty) addressParts.add(city);
      if (state.isNotEmpty) addressParts.add(state);
      if (postalCode.isNotEmpty) addressParts.add(postalCode);
      if (country.isNotEmpty) addressParts.add(country);

      if (addressParts.isNotEmpty) {
        formattedAddress = addressParts.join(', ');
      }

      // Telefon numarası
      phoneNumber =
          shippingAddress['phoneNumber'] ??
          shippingAddress['phone'] ??
          'Telefon bilgisi bulunamadı';
    }

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
                    "Teslimat Adresi:",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.6,
                      color: const Color(0xFF272727),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedAddress,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.6,
                      color: const Color(0xFF272727),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Telefon:",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.6,
                      color: const Color(0xFF272727),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneNumber,
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
    bool isEstimated = false,
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
                  isEstimated
                      ? const Color(0xFF8E6CEF)
                      : (isActive
                          ? const Color(0xFF272727)
                          : const Color(0xFF272727).withOpacity(0.5)),
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

  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      // "1350 TL" gibi string değerleri parse et
      String cleanPrice = price.replaceAll(RegExp(r'[^\d.,]'), '');
      cleanPrice = cleanPrice.replaceAll(',', '.');
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    return 0.0;
  }

  void _showOrderItemsDialog(BuildContext context, List items) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sipariş Ürünleri',
            style: GoogleFonts.gabarito(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Ürün resmi
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child:
                              item['image'] != null && item['image'].isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                        );
                                      },
                                    ),
                                  )
                                  : const Icon(Icons.shopping_bag),
                        ),
                        const SizedBox(width: 12),
                        // Ürün bilgileri
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Ürün adı bulunamadı',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Adet: ${item['quantity'] ?? 1}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_parsePrice(item['price']).toStringAsFixed(2)} TL',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: const Color(0xFF8E6CEF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Kapat',
                style: GoogleFonts.gabarito(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8E6CEF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
