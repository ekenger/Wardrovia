import 'package:Wardrovia/screens/category_products_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCategoryItem extends StatelessWidget {
  final String imagePath;
  final String categoryName;
  const CustomCategoryItem({
    super.key,
    required this.imagePath,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsPage(categoryName: categoryName),
          ),
        );
      },
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Text(
            categoryName,
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

final fixedCategories = [
  {'imagePath': 'assets/images/hoodie.png', 'name': 'Hoodieler'},
  {'imagePath': 'assets/images/shorts.png', 'name': 'Şortlar'},
  {'imagePath': 'assets/images/shoes.png', 'name': 'Ayakkabılar'},
  {'imagePath': 'assets/images/bags.png', 'name': 'Çantalar'},
  {'imagePath': 'assets/images/accessories.png', 'name': 'Aksesuarlar'},
];
