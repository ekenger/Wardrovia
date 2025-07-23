import 'package:Wardrovia/services/cart_service.dart';
import 'package:Wardrovia/screens/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/favorites_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final String productName;
  final String productPrice;
  final String productImage;
  final String targetGender;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.targetGender,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedSize = 'S';
  String selectedColor = 'Yeşil';
  int quantity = 1;
  bool isFavorite = false;
  bool isLoading = false;
  bool isAddingToCart = false;
  int cartItemCount = 0;

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];
  final List<Color> colors = [
    const Color(0xFFB3B68B),
    const Color(0xFF8E6CEF),
    const Color(0xFF272727),
  ];

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _checkCartItemCount();
  }

  Future<void> _checkIfFavorite() async {
    final favorite = await FavoritesService.isFavorite(widget.productId);
    if (mounted) {
      setState(() {
        isFavorite = favorite;
      });
    }
  }

  Future<void> _checkCartItemCount() async {
    try {
      final cartSnapshot = await CartService.getUserCartItems().first;
      if (mounted) {
        setState(() {
          cartItemCount = cartSnapshot.docs.length;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          cartItemCount = 0;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isFavorite) {
        await FavoritesService.removeFromFavorites(widget.productId);
        if (mounted) {
          setState(() {
            isFavorite = false;
          });
        }
      } else {
        await FavoritesService.addToFavorites(
          productId: widget.productId,
          itemName: widget.productName,
          imageUrl: widget.productImage,
          itemPrice: widget.productPrice,
          targetGender: widget.targetGender,
        );
        if (mounted) {
          setState(() {
            isFavorite = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _addToCart() async {
    if (isAddingToCart) return;

    setState(() {
      isAddingToCart = true;
    });

    try {
      await CartService.addToCart(
        productId: widget.productId,
        productName: widget.productName,
        price: widget.productPrice,
        imageUrl: widget.productImage,
        quantity: quantity,
        size: selectedSize,
        color: selectedColor,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.productName} sepete eklendi'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        _checkCartItemCount();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),

              _buildProductImages(),

              _buildProductInfo(),

              _buildSizeSelector(),

              _buildColorSelector(),

              _buildQuantitySelector(),

              _buildProductDetails(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildBottomButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/icons/backbutton.png'),
            ),
          ),

          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                shape: BoxShape.circle,
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey,
                          ),
                        ),
                      )
                      : Image.asset(
                        isFavorite
                            ? 'assets/icons/fav-icon_selected.png'
                            : 'assets/icons/fav-icon.png',
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImages() {
    return Container(
      height: 248,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 161,
            height: 248,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(widget.productImage),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            widget.productName,
            style: GoogleFonts.gabarito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.productPrice,
            style: GoogleFonts.gabarito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8E6CEF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 33, 24, 0),
      child: GestureDetector(
        onTap: () => _showSizeSelector(),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Beden',
                  style: GoogleFonts.figtree(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF272727),
                  ),
                ),
                const Spacer(),
                Text(
                  selectedSize,
                  style: GoogleFonts.gabarito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF272727),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.keyboard_arrow_down, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GestureDetector(
        onTap: () => _showColorSelector(),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Renk',
                  style: GoogleFonts.figtree(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF272727),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB3B68B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.keyboard_arrow_down, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Adet',
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF272727),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8E6CEF),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/icons/minus.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$quantity',
                  style: GoogleFonts.figtree(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF272727),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    quantity++;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8E6CEF),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/icons/add.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            'Hareket özgürlüğü ve ikonik stil bir arada.'
            'Nike Windrunner eşofman altı, hafif yapısı ve rahat kesimiyle gün boyu konfor sunar. Günlük kullanım için ideal, zamansız bir parça.',
            style: GoogleFonts.figtree(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Gönderim & İade',
            style: GoogleFonts.gabarito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ücretsiz kargo · 60 gün içinde ücretsiz iade',
            style: GoogleFonts.figtree(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 24),

          _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yorumlar',
          style: GoogleFonts.gabarito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '4.5 Puan',
          style: GoogleFonts.gabarito(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '213 Yorum',
          style: GoogleFonts.figtree(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.6,
            color: const Color(0xFF272727),
          ),
        ),
        const SizedBox(height: 16),

        _buildReviewCard(),
      ],
    );
  }

  Widget _buildReviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/ellipse_13.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Emre K.',
                  style: GoogleFonts.gabarito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF272727),
                  ),
                ),
              ),
              _buildStarRating(4.5),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ürün beklediğim gibi geldi. Kalitesi gayet iyi, açıklamalarda yazdığı gibi. Kargolama süreci de sorunsuzdu. Tavsiye ederim.',
            style: GoogleFonts.figtree(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: const Color(0xFF272727),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '12 gün önce',
            style: GoogleFonts.figtree(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: const Color(0xFF272727),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        IconData icon;
        if (index < rating.floor()) {
          icon = Icons.star;
        } else if (index < rating && rating % 1 >= 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return Icon(icon, size: 16, color: Color(0xFF8E6CEF));
      }),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              child: FloatingActionButton.extended(
                onPressed: isAddingToCart ? null : _addToCart,
                backgroundColor: const Color(0xFF8E6CEF),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                label: Container(
                  width: MediaQuery.of(context).size.width - 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isAddingToCart) ...[
                        Text(
                          widget.productPrice,
                          style: GoogleFonts.gabarito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Sepete Ekle',
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ekleniyor...',
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (cartItemCount > 0) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                ).then((_) => _checkCartItemCount());
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E6CEF),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$cartItemCount',
                            style: GoogleFonts.figtree(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8E6CEF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSizeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children:
              sizes.map((size) {
                return ListTile(
                  title: Text(size),
                  onTap: () {
                    setState(() {
                      selectedSize = size;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
        );
      },
    );
  }

  void _showColorSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children:
              colors.map((color) {
                return ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(_getColorName(color)),
                  onTap: () {
                    setState(() {
                      selectedColor = _getColorName(color);
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
        );
      },
    );
  }

  String _getColorName(Color color) {
    if (color == const Color(0xFFB3B68B)) return 'Yeşil';
    if (color == const Color(0xFF8E6CEF)) return 'Bej';
    if (color == const Color(0xFF272727)) return 'Siyah';
    return 'Unknown';
  }
}
