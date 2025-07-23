import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomProfileList extends StatelessWidget {
  final String settingName;
  final VoidCallback? onTap;
  const CustomProfileList({super.key, required this.settingName, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(8),
          ),
          width: MediaQuery.of(context).size.width - 48,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 19, bottom: 17),
                child: Text(
                  settingName,
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 20, bottom: 20),
                child: Image.asset('assets/icons/arrowright2.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
