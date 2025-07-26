import 'package:Wardrovia/constants/custom_profile_list.dart';
import 'package:Wardrovia/screens/add_address_page.dart';
import 'package:Wardrovia/screens/add_payment_page.dart';
import 'package:Wardrovia/screens/favorites_page.dart';
import 'package:Wardrovia/screens/support_page.dart';
import 'package:Wardrovia/screens/edit_profile_page.dart';
import 'package:Wardrovia/services/user_service.dart';
import 'package:Wardrovia/models/user.dart' as models;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 70, right: 24, left: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<models.User?>(
                  stream: UserService.getUserStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final user = snapshot.data;

                    return Column(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircleAvatar(
                            backgroundImage:
                                user?.profileImage != null
                                    ? NetworkImage(user!.profileImage!)
                                    : const AssetImage('assets/ellipse_13.png')
                                        as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 32),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: MediaQuery.of(context).size.width - 48,
                          height: 96,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 13,
                                  bottom: 8,
                                  left: 16,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.name ?? "Kullanıcı Adı",
                                      style: GoogleFonts.gabarito(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      user?.email ?? "E-posta",
                                      style: GoogleFonts.figtree(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      user?.phone ?? "Telefon",
                                      style: GoogleFonts.figtree(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    if (user != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  EditProfilePage(user: user),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Düzenle",
                                    style: GoogleFonts.gabarito(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: const Color(0xFF8E6CEF),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 26),
                Expanded(
                  child: ListView.builder(
                    itemCount: profileItems.length,
                    itemBuilder: (context, index) {
                      final profileItem = profileItems[index];
                      return CustomProfileList(
                        settingName: profileItem['settingsName']!,
                        onTap: () {
                          switch (profileItem['settingsName']) {
                            case 'Adreslerim':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddAddressPage(),
                                ),
                              );
                              break;
                            case 'Favorilerim':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FavoritesPage(),
                                ),
                              );
                              break;
                            case 'Ödeme Yöntemlerim':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddPaymentPage(),
                                ),
                              );
                              break;
                            case 'Yardım':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SupportPage(),
                                ),
                              );
                              break;
                            case 'Destek':
                              break;
                            default:
                              break;
                          }
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Uyarı',
                                style: GoogleFonts.gabarito(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              content: Text(
                                'Çıkış yapmak istediğinize emin misiniz?',
                                style: GoogleFonts.figtree(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Vazgeç',
                                    style: GoogleFonts.gabarito(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF8E6CEF),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      FirebaseAuth.instance.signOut();
                                    });
                                  },
                                  child: Text(
                                    'Evet',
                                    style: GoogleFonts.gabarito(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF8E6CEF),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      });
                    },
                    child: Text(
                      "Çıkış Yap",
                      style: GoogleFonts.gabarito(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFFFA3636),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final profileItems = [
  {'settingsName': 'Adreslerim'},
  {'settingsName': 'Favorilerim'},
  {'settingsName': 'Ödeme Yöntemlerim'},
  {'settingsName': 'Yardım'},
  {'settingsName': 'Destek'},
];
