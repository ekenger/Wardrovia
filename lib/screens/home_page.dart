import 'package:Wardrovia/providers/gender_selection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Wardrovia/constants/custom_item_banner.dart';
import 'package:Wardrovia/constants/custom_category_item.dart';
import 'package:Wardrovia/screens/all_categories_page.dart';
import 'package:Wardrovia/screens/cart_page.dart';
import 'package:Wardrovia/screens/search_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genderState = ref.watch(genderSelectionProvider);
    final genderNotifier = ref.read(genderSelectionProvider.notifier);

    final selectedGender = genderNotifier.getSelectedGenderString();

    final filteredTopSellingItems =
        topSellingItems
            .where((item) => item['targetGender'] == selectedGender)
            .toList();

    final filteredNewInItems =
        newInItems
            .where((item) => item['targetGender'] == selectedGender)
            .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ÜST BAR
                SizedBox(
                  width: 342,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/ellipse_13.png'),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    genders.map((genderText) {
                                      return ListTile(
                                        title: Text(genderText),
                                        onTap: () {
                                          // Seçilen gender'ı enum'a çevir
                                          final selected =
                                              genderText == 'Erkek'
                                                  ? Gender.male
                                                  : Gender.female;
                                          genderNotifier.selectGender(selected);
                                          Navigator.pop(context);
                                        },
                                      );
                                    }).toList(),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              Text(
                                selectedGender,
                                style: GoogleFonts.gabarito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 14 / 12,
                                  color: const Color(0xFF272727),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                'assets/icons/arrowdown2.png',
                                width: 16,
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8E6CEF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/icons/bag2.png',
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Arama kutusu
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  child: Container(
                    width: 342,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 19),
                        Image.asset(
                          'assets/icons/searchnormal1.png',
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Ara",
                          style: GoogleFonts.cabin(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            color: const Color(0xFF272727),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Kategoriler
                SizedBox(
                  width: 342,
                  height: 116,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Kategoriler",
                            style: GoogleFonts.gabarito(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            child: Text(
                              "Tümünü Göster",
                              style: GoogleFonts.figtree(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllCategoriesPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              fixedCategories.map((category) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: CustomCategoryItem(
                                    imagePath: category['imagePath']!,
                                    categoryName: category['name']!,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Çok Satanlar
                sectionTitle("Çok Satanlar"),
                const SizedBox(height: 15),
                buildHorizontalItemList(filteredTopSellingItems),

                const SizedBox(height: 24),

                // Yeni Gelenler
                sectionTitle("Yeni Gelenler", highlight: true),
                const SizedBox(height: 15),
                buildHorizontalItemList(filteredNewInItems),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Başlık widget'ı
  Widget sectionTitle(String title, {bool highlight = false}) {
    return SizedBox(
      width: 342,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.gabarito(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: highlight ? const Color(0xFF8E6CEF) : Colors.black,
            ),
          ),
          Text(
            "Tümünü Göster",
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Ürün liste widget'ı
  Widget buildHorizontalItemList(List<Map<String, String>> items) {
    return SizedBox(
      width: 500,
      height: 282,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CustomItemBanner(
              productId: item['productId']!,
              imageUrl: item['imagePath']!,
              itemName: item['itemName']!,
              itemPrice: item['itemPrice']!,
              targetGender: item['targetGender']!,
            ),
          );
        },
      ),
    );
  }
}

// Cinsiyet listesi (string olarak)
final List<String> genders = ['Erkek', 'Kadın'];
