import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Genel';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

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
                    _buildQuickContactSection(),
                    const SizedBox(height: 32),
                    _buildContactForm(),
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
                "Destek",
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

  Widget _buildQuickContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hızlı İletişim",
          style: GoogleFonts.gabarito(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickContactCard(
                title: "Canlı Destek",
                subtitle: "Anında yanıt",
                icon: Icons.chat_bubble_outline,
                onTap: () => _showLiveChatDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickContactCard(
                title: "Telefon",
                subtitle: "+90 212 555 0123",
                icon: Icons.phone_outlined,
                onTap: () => _showCallDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF8E6CEF)),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.gabarito(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF272727),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: const Color(0xFF272727).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bize Yazın",
          style: GoogleFonts.gabarito(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: "Ad Soyad",
                validator:
                    (value) =>
                        value?.isEmpty == true ? "Bu alan zorunludur" : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: "E-posta",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return "Bu alan zorunludur";
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value!)) {
                    return "Geçerli bir e-posta adresi girin";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _subjectController,
                label: "Konu",
                validator:
                    (value) =>
                        value?.isEmpty == true ? "Bu alan zorunludur" : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _messageController,
                label: "Mesajınız",
                maxLines: 5,
                validator:
                    (value) =>
                        value?.isEmpty == true ? "Bu alan zorunludur" : null,
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    final categories = ['Genel', 'Sipariş', 'İade', 'Ürün', 'Teknik', 'Diğer'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: "Kategori",
          border: InputBorder.none,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFF272727).withOpacity(0.7),
          ),
        ),
        items:
            categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: const Color(0xFF272727),
                  ),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFF272727).withOpacity(0.7),
          ),
        ),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: const Color(0xFF272727),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8E6CEF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          "Gönder",
          style: GoogleFonts.gabarito(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Mesajınız Gönderildi",
              style: GoogleFonts.gabarito(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            content: Text(
              "Mesajınızı aldık. En kısa sürede size dönüş yapacağız.",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Tamam",
                  style: GoogleFonts.gabarito(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E6CEF),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showLiveChatDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Canlı Destek",
              style: GoogleFonts.gabarito(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            content: Text(
              "Canlı destek hattımız Pazartesi-Cuma 09:00-18:00 saatleri arasında hizmet vermektedir.",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Tamam",
                  style: GoogleFonts.gabarito(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E6CEF),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Telefon Desteği",
              style: GoogleFonts.gabarito(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "+90 (212) 555 0123",
                  style: GoogleFonts.gabarito(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF8E6CEF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pazartesi - Cuma: 09:00 - 18:00",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Tamam",
                  style: GoogleFonts.gabarito(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E6CEF),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
