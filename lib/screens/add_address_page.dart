import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddAddressPage extends StatefulWidget {
  final Address? selectedAddress;

  const AddAddressPage({super.key, this.selectedAddress});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Türkiye');

  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
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
                  children: [_buildAddressList(), _buildAddAddressForm()],
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
                'Adreslerim',
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

  Widget _buildAddressList() {
    return StreamBuilder<QuerySnapshot>(
      stream: AddressService.getUserAddresses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final addresses =
            snapshot.data!.docs
                .map(
                  (doc) =>
                      Address.fromFirestore(doc.data() as Map<String, dynamic>),
                )
                .toList();

        return Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kayıtlı Adreslerim',
                style: GoogleFonts.gabarito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF272727),
                ),
              ),
              const SizedBox(height: 16),
              ...addresses.map((address) => _buildAddressItem(address)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressItem(Address address) {
    final isSelected = widget.selectedAddress?.id == address.id;

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
        title: Text(
          address.title,
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
              address.fullName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF272727),
              ),
            ),
            Text(
              address.formattedAddress,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF272727),
              ),
            ),
            if (address.isDefault)
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
            if (!address.isDefault)
              IconButton(
                icon: const Icon(Icons.star_border, color: Color(0xFF8E6CEF)),
                onPressed: () => _setAsDefault(address.id),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteAddress(address.id),
            ),
          ],
        ),
        onTap: () => Navigator.pop(context, address),
      ),
    );
  }

  Widget _buildAddAddressForm() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yeni Adres Ekle',
              style: GoogleFonts.gabarito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF272727),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              _titleController,
              'Adres Başlığı',
              'Adres Başlığı (Örn: Ev Adresi)',
            ),
            const SizedBox(height: 16),
            _buildTextField(_fullNameController, 'Ad Soyad', 'Ad Soyad'),
            const SizedBox(height: 16),
            _buildTextField(
              _phoneController,
              'Cep Telefonu',
              '0 (5__) ___ __ __',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _addressLine1Controller,
              'Adres Satırı',
              'Cadde, Sokak, No',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _addressLine2Controller,
              'Adres Satırı 2',
              'Daire, Kat, Bina No (opsiyonel)',
              required: false,
            ),
            const SizedBox(height: 16),
            _buildTextField(_cityController, 'İlçe', 'İlçe'),
            const SizedBox(height: 16),
            _buildTextField(_stateController, 'İl', 'İl'),
            const SizedBox(height: 16),
            _buildTextField(_postalCodeController, 'Posta Kodu', 'Posta Kodu'),
            const SizedBox(height: 16),
            _buildTextField(_countryController, 'Ülke', 'Ülke'),
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
                  'Varsayılan Adres Yap',
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
                onPressed: _isLoading ? null : _saveAddress,
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
    bool required = true,
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
          validator:
              required
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label alanı zorunludur.';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final address = Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        isDefault: _isDefault,
      );

      await AddressService.addAddress(address);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adres başarıyla kaydedildi.'),
            backgroundColor: Color(0xFF8E6CEF),
          ),
        );

        _formKey.currentState!.reset();
        _titleController.clear();
        _fullNameController.clear();
        _phoneController.clear();
        _addressLine1Controller.clear();
        _addressLine2Controller.clear();
        _cityController.clear();
        _stateController.clear();
        _postalCodeController.clear();
        _countryController.text = 'Türkiye';
        setState(() => _isDefault = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adres kaydederken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setAsDefault(String addressId) async {
    try {
      await AddressService.setDefaultAddress(addressId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varsayılan adres güncellendi.'),
            backgroundColor: Color(0xFF8E6CEF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Varsayılan adresi güncellerken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await AddressService.deleteAddress(addressId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adres başarıyla silindi.'),
            backgroundColor: Color(0xFF8E6CEF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adres silerken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
