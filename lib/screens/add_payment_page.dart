import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_card.dart';
import '../services/payment_service.dart';

class AddPaymentPage extends StatefulWidget {
  final PaymentCard? selectedPaymentMethod;

  const AddPaymentPage({super.key, this.selectedPaymentMethod});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;
  String _cardType = '';

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
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
                    _buildPaymentMethodsList(),
                    _buildAddPaymentForm(),
                  ],
                ),
              ),
            ),
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
            child: Image.asset('assets/icons/backbutton.png'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Ödeme Yöntemleri',
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

  Widget _buildPaymentMethodsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: PaymentService.getUserPaymentMethods(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final paymentMethods =
            snapshot.data!.docs
                .map(
                  (doc) => PaymentCard.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList();

        return Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kayıtlı Ödeme Yöntemlerim',
                style: GoogleFonts.gabarito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF272727),
                ),
              ),
              const SizedBox(height: 16),
              ...paymentMethods.map(
                (method) => _buildPaymentMethodItem(method),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodItem(PaymentCard paymentMethod) {
    final isSelected = widget.selectedPaymentMethod?.id == paymentMethod.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8E6CEF) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
        border:
            isSelected
                ? Border.all(color: const Color(0xFF8E6CEF), width: 2)
                : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 25,
          decoration: BoxDecoration(
            color: _getCardColor(paymentMethod.cardType),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: _getCardIcon(paymentMethod.cardType)),
        ),
        title: Text(
          paymentMethod.maskedCardNumber,
          style: GoogleFonts.gabarito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF272727),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paymentMethod.cardHolderName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF272727),
              ),
            ),
            Text(
              '${paymentMethod.cardType} • SKT ${paymentMethod.formattedExpiry}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF272727),
              ),
            ),
            if (paymentMethod.isDefault)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8E6CEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Varsayılan',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!paymentMethod.isDefault)
              IconButton(
                icon: const Icon(Icons.star_border, color: Color(0xFF8E6CEF)),
                onPressed: () => _setAsDefault(paymentMethod.id),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deletePaymentMethod(paymentMethod.id),
            ),
          ],
        ),
        onTap: () => Navigator.pop(context, paymentMethod),
      ),
    );
  }

  Widget _buildAddPaymentForm() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yeni Ödeme Yöntemi Ekle',
              style: GoogleFonts.gabarito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF272727),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              _cardHolderController,
              'Kart Üzerindeki Ad Soyad',
              'Kart Üzerindeki Ad Soyad',
            ),
            const SizedBox(height: 16),
            _buildCardNumberField(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildExpiryField()),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    _cvvController,
                    'CVV',
                    '***',
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isDefault,
                  onChanged:
                      (value) => setState(() => _isDefault = value ?? false),
                  activeColor: const Color(0xFF8E6CEF),
                ),
                Text(
                  'Varsayılan Ödeme Yöntemi Yap',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF272727),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePaymentMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E6CEF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Kaydet',
                          style: GoogleFonts.inter(
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
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF272727),
            ),
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label alanı zorunludur.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCardNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kart Numarası',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cardNumberController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(19),
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          onChanged: (value) {
            final cardType = PaymentService.detectCardType(value);
            setState(() => _cardType = cardType);
          },
          decoration: InputDecoration(
            hintText: '1234 5678 9012 3456',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF272727),
            ),
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon:
                _cardType.isNotEmpty
                    ? Container(
                      width: 40,
                      height: 25,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getCardColor(_cardType),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(child: _getCardIcon(_cardType)),
                    )
                    : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Kart Numarası zorunludur.';
            }
            if (value.replaceAll(' ', '').length < 13) {
              return 'Geçersiz Kart Numarası';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildExpiryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Kullanma Tarihi',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _expiryController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(5),
            FilteringTextInputFormatter.digitsOnly,
            _ExpiryDateFormatter(),
          ],
          decoration: InputDecoration(
            hintText: 'Ay/Yıl',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF272727),
            ),
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Son Kullanma Tarihi zorunludur.';
            }
            if (value.length != 5) {
              return 'Geçersiz Son Kullanma Tarihi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Color _getCardColor(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'american express':
        return const Color(0xFF006FCF);
      default:
        return const Color(0xFF8E6CEF);
    }
  }

  Widget _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Image.asset(
          'assets/icons/visa.png',
          width: 30,
          height: 18,
          fit: BoxFit.contain,
        );
      case 'mastercard':
        return Image.asset(
          'assets/icons/mastercard.png',
          width: 30,
          height: 18,
          fit: BoxFit.contain,
        );
      case 'american express':
        return Image.asset(
          'assets/icons/amex.png',
          width: 30,
          height: 18,
          fit: BoxFit.contain,
        );
      default:
        return Image.asset(
          'assets/icons/default_card.png',
          width: 30,
          height: 18,
          fit: BoxFit.contain,
        );
    }
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final parts = _expiryController.text.split('/');
      final paymentCard = PaymentCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardHolderName: _cardHolderController.text.trim(),
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryMonth: parts[0],
        expiryYear: parts[1],
        cvv: _cvvController.text.trim(),
        cardType: _cardType,
        isDefault: _isDefault,
      );

      await PaymentService.addPaymentMethod(paymentCard);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödeme yöntemi başarıyla kaydedildi.'),
            backgroundColor: Color(0xFF8E6CEF),
          ),
        );

        _formKey.currentState!.reset();
        _cardHolderController.clear();
        _cardNumberController.clear();
        _expiryController.clear();
        _cvvController.clear();
        setState(() {
          _isDefault = false;
          _cardType = '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme yöntemi kaydedilirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAsDefault(String cardId) async {
    try {
      await PaymentService.setDefaultPaymentMethod(cardId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varsayılan ödeme yöntemi güncellendi.'),
            backgroundColor: Color(0xFF8E6CEF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Varsayılan ödeme yöntemi güncellenirken bir hata oluştu: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePaymentMethod(String cardId) async {
    try {
      await PaymentService.deletePaymentMethod(cardId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödeme yöntemi başarıyla silindi.'),
            backgroundColor: Color(0xFF8E6CEF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme yöntemi silinirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
