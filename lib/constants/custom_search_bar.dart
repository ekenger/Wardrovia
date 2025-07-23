import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  const CustomSearchBar({super.key, required this.onSearchChanged});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color(0xFFF4F4F4),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Image.asset(
              'assets/icons/searchnormal1.png',
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: TextField(
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ara',
                  hintStyle: GoogleFonts.figtree(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  widget.onSearchChanged(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
