import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Sıkça Sorulan Sorular"),
                    const SizedBox(height: 16),
                    _buildFAQSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Nasıl Yapılır?"),
                    const SizedBox(height: 16),
                    _buildHowToSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("İletişim"),
                    const SizedBox(height: 16),
                    _buildContactSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                "Yardım",
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.gabarito(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: const Color(0xFF272727),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        "question": "Siparişimi nasıl takip edebilirim?",
        "answer":
            "Siparişlerinizi 'Siparişlerim' sayfasından takip edebilirsiniz. Sipariş durumunuz gerçek zamanlı olarak güncellenir.",
      },
      {
        "question": "İade işlemi nasıl yapılır?",
        "answer":
            "Ürünü aldığınız tarihten itibaren 14 gün içinde iade edebilirsiniz. Sipariş detaylarından iade talebinde bulunabilirsiniz.",
      },
      {
        "question": "Kargo ücreti ne kadar?",
        "answer":
            "150 TL ve üzeri siparişlerde kargo ücretsizdir. Diğer siparişlerde kargo ücreti 29.90 TL'dir.",
      },
      {
        "question": "Ödeme seçenekleri nelerdir?",
        "answer":
            "Kredi kartı, banka kartı ile ödeme yapabilirsiniz. Tüm ödemeler güvenli SSL ile şifrelenmektedir.",
      },
    ];

    return Column(
      children:
          faqs
              .map((faq) => _buildFAQItem(faq["question"]!, faq["answer"]!))
              .toList(),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Text(
          question,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: const Color(0xFF272727),
          ),
        ),
        children: [
          Text(
            answer,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF272727).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToSection() {
    final howTos = [
      {
        "title": "Sipariş Vermek",
        "description":
            "Beğendiğiniz ürünü sepete ekleyin, adres ve ödeme bilgilerinizi girin, siparişi tamamlayın.",
      },
      {
        "title": "Favori Ürünler",
        "description":
            "Ürün sayfasında kalp ikonuna tıklayarak favorilerinize ekleyebilirsiniz.",
      },
      {
        "title": "Adres Eklemek",
        "description":
            "Profil > Adreslerim sayfasından yeni teslimat adresi ekleyebilirsiniz.",
      },
      {
        "title": "Kupon Kullanmak",
        "description":
            "Ödeme sayfasında kupon kodunuzu girerek indirim kazanabilirsiniz.",
      },
    ];

    return Column(
      children:
          howTos
              .map(
                (howTo) =>
                    _buildHowToItem(howTo["title"]!, howTo["description"]!),
              )
              .toList(),
    );
  }

  Widget _buildHowToItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.gabarito(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: const Color(0xFF8E6CEF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF272727).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daha fazla yardıma mı ihtiyacınız var?",
            style: GoogleFonts.gabarito(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 12),
          _buildContactItem("E-posta", "destek@wardrovia.com"),
          const SizedBox(height: 8),
          _buildContactItem("Telefon", "+90 (212) 555 0123"),
          const SizedBox(height: 8),
          _buildContactItem(
            "Çalışma Saatleri",
            "Pazartesi - Cuma: 09:00 - 18:00",
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "$label:",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: const Color(0xFF272727),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: const Color(0xFF272727).withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
