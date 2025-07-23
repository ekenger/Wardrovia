import 'package:Wardrovia/constants/custom_category_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAllCategories extends StatefulWidget {
  const CustomAllCategories({super.key});

  @override
  State<CustomAllCategories> createState() => _CustomAllCategoriesState();
}

class _CustomAllCategoriesState extends State<CustomAllCategories> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(right: 24, left: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tüm Kategoriler",
              style: GoogleFonts.gabarito(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final category = allCategories[index];
                  return CustomCategoryList(
                    imagePath: category['imagePath']!,
                    categoryName: category['name']!,
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

final allCategories = [
  {'imagePath': 'assets/images/hoodie.png', 'name': 'Hoodieler'},
  {'imagePath': 'assets/images/shorts.png', 'name': 'Şortlar'},
  {'imagePath': 'assets/images/shoes.png', 'name': 'Ayakkabılar'},
  {'imagePath': 'assets/images/bags.png', 'name': 'Çantalar'},
  {'imagePath': 'assets/images/accessories.png', 'name': 'Aksesuarlar'},
  {'imagePath': 'assets/images/tshirt.png', 'name': 'Tişörtler'},
  {'imagePath': 'assets/images/pants.png', 'name': 'Pantolonlar'},
  {'imagePath': 'assets/images/shirts.png', 'name': 'Gömlekler'},
  {'imagePath': 'assets/images/jackets.png', 'name': 'Ceketler'},
  {'imagePath': 'assets/images/coat.png', 'name': 'Montlar'},
  {'imagePath': 'assets/images/sweatshirts.png', 'name': 'Sweatshirtler'},
];
