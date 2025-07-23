import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Wardrovia/screens/product_detail_page.dart';
import '../services/favorites_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomItemBanner extends StatefulWidget {
  final String productId;
  final String imageUrl;
  final String itemName;
  final String itemPrice;
  final String targetGender;

  const CustomItemBanner({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.itemName,
    required this.itemPrice,
    required this.targetGender,
  });

  @override
  State<CustomItemBanner> createState() => _CustomItemBannerState();
}

class _CustomItemBannerState extends State<CustomItemBanner> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Favori toggle işlemi
  Future<void> _toggleFavorite(bool currentFavState) async {
    if (isLoading) return; // Çoklu tıklamayı engelle

    setState(() {
      isLoading = true;
    });

    try {
      if (currentFavState) {
        // Favorilerden çıkar
        await FavoritesService.removeFromFavorites(widget.productId);
      } else {
        // Favorilere ekle
        await FavoritesService.addToFavorites(
          productId: widget.productId,
          itemName: widget.itemName,
          imageUrl: widget.imageUrl,
          itemPrice: widget.itemPrice,
          targetGender: widget.targetGender,
        );
      }
    } catch (e) {
      // Hata durumunda kullanıcıyı bilgilendir
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection('favorites')
              .doc(widget.productId)
              .snapshots(),
      builder: (context, snapshot) {
        final isFav = snapshot.hasData && snapshot.data!.exists;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductDetailPage(
                      productId: widget.productId,
                      productName: widget.itemName,
                      productPrice: widget.itemPrice,
                      productImage: widget.imageUrl,
                      targetGender: widget.targetGender,
                    ),
              ),
            );
          },
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 159,
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(widget.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          widget.itemName,
                          style: GoogleFonts.figtree(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.itemPrice,
                        style: GoogleFonts.gabarito(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: -2,
                right: 12,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(isFav),
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    padding: const EdgeInsets.all(4),
                    child:
                        isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey,
                                ),
                              ),
                            )
                            : Image.asset(
                              isFav
                                  ? 'assets/icons/fav-icon_selected.png'
                                  : 'assets/icons/fav-icon.png',
                              width: 20,
                              height: 20,
                            ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Güncellenen veri listeleri - productId ve targetGender parametresi eklendi
final topSellingItems = [
  {
    'productId': 'erkek_harrington_ceket_001',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/top_selling/erkekharringtonceketi.png',
    'itemName': 'Erkek Harrington Ceketi',
    'itemPrice': '2750 TL',
    'targetGender': 'Erkek',
  },
  {
    'productId': 'nike_windrunner_esofman_009',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/new_in/nikewindrunner.png',
    'itemName': 'Nike WINDRUNNER Eşofman Altı',
    'itemPrice': '1749 TL',
    'targetGender': 'Erkek',
  },
  {
    'productId': 'erkek_antrenor_ceket_003',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/top_selling/erkekantrenorceketi.png',
    'itemName': 'Erkek Antrenör Ceketi',
    'itemPrice': '2000 TL',
    'targetGender': 'Erkek',
  },
  {
    'productId': 'kadin_mini_elbise_004',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/top_selling/kadinelbise.png',
    'itemName': 'Fiyonklu Bağcıklı Yaka İp Askılı Çizgili Mini Elbise',
    'itemPrice': '1599.99 TL',
    'targetGender': 'Kadın',
  },
  {
    'productId': 'kadin_fistolu_bluz_005',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/top_selling/kadinbluz.png',
    'itemName': 'Kolsuz Brodeli Fiyonk Detaylı Fisto Fırfırlı Bluz',
    'itemPrice': '999.99 TL',
    'targetGender': 'Kadın',
  },
  {
    'productId': 'kadin_palazzo_pantolon_006',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/top_selling/kadinpantolon.png',
    'itemName': 'Modal Kumaş Karışımlı Geniş Paça Palazzo Pantolon',
    'itemPrice': '1299.99 TL',
    'targetGender': 'Kadın',
  },
];

final newInItems = [
  {
    'productId': 'nike_unscripted_ceket_007',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/new_in/nikeunscripted.png',
    'itemName': 'Nike UNSCRIPTED Ceket',
    'itemPrice': '3499 TL',
    'targetGender': 'Erkek',
  },
  {
    'productId': 'nike_sb_ceket_008',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/new_in/NikeSB.png',
    'itemName': 'Nike SB Ceket',
    'itemPrice': '2199 TL',
    'targetGender': 'Erkek',
  },
  {
    'productId': 'max_cirro_erkek_terlik_002',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/top_selling/maxcirroerkekterlik.png',
    'itemName': 'Max Cirro Erkek Terlik',
    'itemPrice': '1350 TL',
    'targetGender': 'Erkek',
  },
  {
    'productId': 'kadin_potikareli_bluz_010',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/new_in/kadinbluz.png',
    'itemName': 'Gipeli Pötikareli İnce Askılı Bluz',
    'itemPrice': '899.99 TL',
    'targetGender': 'Kadın',
  },
  {
    'productId': 'kadin_mini_etek_011',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/new_in/kadinetek.png',
    'itemName':
        'Volanlı Büzgülü A Kesim Gofre Viskon Karışımlı Pötikareli Mini Etek',
    'itemPrice': '699.99 TL',
    'targetGender': 'Kadın',
  },
  {
    'productId': 'kadin_cicekli_elbise_012',
    'imagePath':
        'https://ik.imagekit.io/ekcommerce/assets/images/new_in/kadinelbise.png',
    'itemName': 'Pamuklu Kolsuz Bisiklet Yaka A Kesim Mini Çiçekli Elbise',
    'itemPrice': '1599.99 TL',
    'targetGender': 'Kadın',
  },
];
