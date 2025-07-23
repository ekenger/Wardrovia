import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductUploaderWidget extends StatelessWidget {
  ProductUploaderWidget({super.key});

  // 🔧 Search kelimeleri oluşturan yardımcı fonksiyon
  List<String> generateSearchKeywords(String name) {
    final lower = name.toLowerCase();
    final words = lower.split(' ');
    final Set<String> keywords = {...words};

    for (int i = 0; i < words.length; i++) {
      for (int j = i + 1; j < words.length; j++) {
        keywords.add('${words[i]} ${words[j]}');
      }
    }

    return keywords.toList();
  }

  // 🧩 Ürün listesi
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Nike Sportswear Club Erkek Tişört',
      'price': 699.90,
      'targetGender': 'Erkek',
      'category': 'Tişörtler',
      'imageUrl':
          'https://ik.imagekit.io/ekcommerce/assets/images/nikepowererkektisort.png',
      'inStock': true,
      'stockCount': 18,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Adidas Essentials Kadın Tişört',
      'price': 649.00,
      'targetGender': 'Kadın',
      'category': 'Tişörtler',
      'imageUrl':
          'https://ik.imagekit.io/ekcommerce/assets/images/adidasessentialtshirttkadin.png',
      'inStock': true,
      'stockCount': 12,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'LC Waikiki Baskılı Oversize Erkek Tişört',
      'price': 299.99,
      'targetGender': 'Erkek',
      'category': 'Tişörtler',
      'imageUrl':
          'https://ik.imagekit.io/ekcommerce/assets/images/lcwerkekbaskilitshirt.png',
      'inStock': true,
      'stockCount': 20,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Stradivarius Crop Fit Kadın Tişört',
      'price': 429.95,
      'targetGender': 'Kadın',
      'category': 'Tişörtler',
      'imageUrl':
          'https://ik.imagekit.io/ekcommerce/assets/images/stradivariuscroptshirtkadin.png',
      'inStock': true,
      'stockCount': 10,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'H&M Basic Pamuklu Erkek Tişört',
      'price': 249.99,
      'targetGender': 'Erkek',
      'category': 'Tişörtler',
      'imageUrl':
          'https://ik.imagekit.io/ekcommerce/assets/images/basicpamukluerkekhm.png',
      'inStock': true,
      'stockCount': 16,
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Zara Baskılı Kadın Tişört',
      'price': 499.95,
      'targetGender': 'Kadın',
      'category': 'Tişörtler',
      'imageUrl':
          'https://ik.imagekit.io/ekcommerce/assets/images/zarabaskilikadintisort.png',
      'inStock': true,
      'stockCount': 8,
      'createdAt': Timestamp.now(),
    },
  ];

  // 📤 Firestore'a veri yükleyen işlem
  Future<void> uploadProducts(BuildContext context) async {
    final snackBar = ScaffoldMessenger.of(context);

    try {
      for (final product in products) {
        final name = product['name'] as String;
        final keywords = generateSearchKeywords(name);

        await FirebaseFirestore.instance.collection('products').add({
          ...product,
          'searchKeywords': keywords,
        });
      }

      snackBar.showSnackBar(
        const SnackBar(
          content: Text('Ürünler başarıyla yüklendi ✅'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      snackBar.showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.upload_file),
      label: const Text('Ürünleri Yükle'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () => uploadProducts(context),
    );
  }
}
