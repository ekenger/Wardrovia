import 'package:Wardrovia/screens/all_categories_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomExploreCategoryButton extends StatelessWidget {
  const CustomExploreCategoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 185,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AllCategoriesPage()),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8E6CEF)),
        child: Text(
          "Kategorileri Keşfet",
          style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
