import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wardrovia/constants/custom_explore_category_button.dart';
import 'package:Wardrovia/screens/order_detail_page.dart';
import 'package:Wardrovia/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String selectedFilter = "confirmed";

  final List<Map<String, String>> filterOptions = [
    {"key": "confirmed", "label": "İşleniyor"},
    {"key": "shipped", "label": "Kargoda"},
    {"key": "delivered", "label": "Teslim Edildi"},
    {"key": "returned", "label": "İade"},
    {"key": "cancelled", "label": "İptal"},
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: OrderService.getUserOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                const SizedBox(height: 41),

                _buildFilterTabs(),

                const SizedBox(height: 24),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: OrderService.getUserOrdersByStatus(selectedFilter),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Hata: ${snapshot.error}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyFilteredState();
                      }

                      final orders = snapshot.data!.docs;

                      orders.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTimestamp = aData['createdAt'] as Timestamp?;
                        final bTimestamp = bData['createdAt'] as Timestamp?;

                        if (aTimestamp == null && bTimestamp == null) return 0;
                        if (aTimestamp == null) return 1;
                        if (bTimestamp == null) return -1;

                        return bTimestamp.compareTo(aTimestamp);
                      });

                      return _buildOrdersList(orders);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Siparişlerim',
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

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 27),
      child: SizedBox(
        height: 27,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filterOptions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 13),
          itemBuilder: (context, index) {
            final filter = filterOptions[index];
            final isSelected = selectedFilter == filter["key"];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter["key"]!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF8E6CEF)
                          : const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  filter["label"]!,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.6,
                    color: isSelected ? Colors.white : const Color(0xFF272727),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<QueryDocumentSnapshot> orders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.separated(
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final orderDoc = orders[index];
          final orderData = orderDoc.data() as Map<String, dynamic>;
          return _buildOrderCard(orderData);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> orderData) {
    final orderId = orderData['orderId'] ?? '';
    final items = orderData['items'] as List? ?? [];
    final itemCount = items.length;
    final orderStatus = orderData['orderStatus'] ?? '';
    final totalAmount = orderData['finalAmount'] ?? 0.0;

    final createdAt = orderData['createdAt'] as Timestamp?;
    final dateStr =
        createdAt != null
            ? "${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}"
            : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderId: orderId),
          ),
        );
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
                      "Sipariş ID: #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}",
                      style: GoogleFonts.gabarito(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 20 / 16,
                        color: const Color(0xFF272727),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "$itemCount ürün",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 1.6,
                            color: const Color(0xFF272727).withOpacity(0.5),
                          ),
                        ),
                        if (dateStr.isNotEmpty) ...[
                          const Text(' • '),
                          Text(
                            dateStr,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              height: 1.6,
                              color: const Color(0xFF272727).withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${totalAmount.toStringAsFixed(2)} TL",
                    style: GoogleFonts.gabarito(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF272727),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Image.asset(
                    'assets/icons/arrowright2.png',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Siparişlerim",
            style: GoogleFonts.gabarito(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/check-out.png', width: 100, height: 100),
            const SizedBox(height: 24),
            Text(
              textAlign: TextAlign.center,
              "Henüz bir siparişiniz bulunmamaktadır.",
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 24),
            CustomExploreCategoryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilteredState() {
    final currentFilterLabel =
        filterOptions.firstWhere(
          (filter) => filter["key"] == selectedFilter,
        )["label"];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.search_off,
              size: 36,
              color: Color(0xFF8E6CEF),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "$currentFilterLabel durumunda sipariş bulunamadı.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Diğer durumlara göz atabilirsiniz.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: const Color(0xFF272727).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
