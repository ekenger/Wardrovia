import 'package:Wardrovia/constants/custom_explore_category_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSorryWidget extends StatefulWidget {
  const CustomSorryWidget({super.key});

  @override
  State<CustomSorryWidget> createState() => _CustomSorryWidgetState();
}

class _CustomSorryWidgetState extends State<CustomSorryWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/magnifying-glass.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 24),
            Text(
              "Üzgünüz, aramanıza uygun bir sonuç bulamadık.",
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomExploreCategoryButton(),
            SizedBox(height: 101),
          ],
        ),
      ),
    );
  }
}
