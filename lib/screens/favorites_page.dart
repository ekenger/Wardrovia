import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/favorites_service.dart';
import '../constants/custom_item_banner.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FavoritesService.getUserFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final favorites = snapshot.data?.docs ?? [];

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset('assets/icons/backbutton.png'),
                ),
                SizedBox(width: 58),
                Text(
                  'Favorilerim (${favorites.length})',
                  style: GoogleFonts.gabarito(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body:
              favorites.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz favori ürününüz yok',
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(24),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favorite =
                            favorites[index].data() as Map<String, dynamic>;
                        return CustomItemBanner(
                          key: ValueKey(favorite['productId']),
                          productId: favorite['productId'],
                          imageUrl: favorite['imageUrl'],
                          itemName: favorite['itemName'],
                          itemPrice: favorite['itemPrice'],
                          targetGender: favorite['targetGender'],
                        );
                      },
                    ),
                  ),
        );
      },
    );
  }
}
