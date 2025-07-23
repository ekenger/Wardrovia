import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Wardrovia/constants/custom_all_categories.dart';
import 'package:Wardrovia/constants/custom_item_banner.dart';
import 'package:Wardrovia/constants/custom_search_bar.dart';
import 'package:Wardrovia/constants/custom_sorry_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<DocumentSnapshot> products = [];
  bool isLoading = false;
  String searchText = '';
  void searchProducts(String query) async {
    setState(() {
      isLoading = true;
      searchText = query;
    });
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where('searchKeywords', arrayContains: query.toLowerCase())
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
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.asset(
                  'assets/icons/backbutton.png',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 9),
              CustomSearchBar(onSearchChanged: searchProducts),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 34),
          Expanded(
            child:
                searchText.isEmpty
                    ? CustomAllCategories() // arama yoksa kategorileri göster
                    : isLoading
                    ? Center(
                      child: CircularProgressIndicator(),
                    ) // arama sürüyor
                    : products.isEmpty
                    ? CustomSorryWidget()
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${products.length} sonuç bulundu.",
                            style: GoogleFonts.figtree(
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF272727),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 0.60,
                                  ),
                              itemCount: products.length,
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
          ),
        ],
      ),
    );
  }
}
