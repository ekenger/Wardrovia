import 'package:Wardrovia/screens/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderPlacedPage extends StatelessWidget {
  final String orderId;
  const OrderPlacedPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF8E6CEF),

      body: Stack(
        children: [
          Positioned(
            top: 154,
            left: 0,
            right: 0,
            child: Center(child: Image.asset('assets/image.png')),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(29, 40, 29, 25),
                    child: Text(
                      'Siparişiniz başarıyla alındı.',
                      style: GoogleFonts.gabarito(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 59,
                      bottom: 78,
                      right: 59,
                    ),
                    child: Text(
                      'E-posta adresinize onay mesajı gönderilmiştir.',
                      style: GoogleFonts.figtree(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 342,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrderDetailPage(orderId: orderId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E6CEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Sipariş Detaylarını Görüntüle',
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
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
}
