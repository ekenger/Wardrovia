import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wardrovia/constants/custom_item_banner.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryName;

  const CategoryProductsPage({super.key, required this.categoryName});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  bool isLoading = true;
  List<DocumentSnapshot> products = [];

  @override
  void initState() {
    super.initState();
    fetchProductsByCategory();
  }

  Future<void> fetchProductsByCategory() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: widget.categoryName)
            .get();

    setState(() {
      products = snapshot.docs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset('assets/icons/backbutton.png'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.categoryName} (${products.length})',
              style: GoogleFonts.gabarito(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 23),
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : products.isEmpty
                      ? Center(child: Text('Bu kategoriye ait ürün bulunamadı'))
                      : GridView.builder(
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.6,
                            ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return CustomItemBanner(
                            productId: products[index].id,
                            imageUrl: product['imageUrl'] ?? '',
                            itemName: product['name'] ?? '',
                            itemPrice: "${product['price']} TL",
                            targetGender: product['targetGender'] ?? '',
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
