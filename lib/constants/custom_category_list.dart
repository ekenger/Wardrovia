import 'package:Wardrovia/screens/category_products_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCategoryList extends StatelessWidget {
  final String imagePath;
  final String categoryName;
  const CustomCategoryList({
    super.key,
    required this.imagePath,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryProductsPage(categoryName: categoryName),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(8),
          ),
          width: MediaQuery.of(context).size.width - 48,
          height: 64,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Text(
                categoryName,
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
