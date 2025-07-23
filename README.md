
# Wardrovia 🛍️

Wardrovia, Firebase entegrasyonlu modern bir e-ticaret Flutter uygulamasıdır. Kullanıcılar ürün arayabilir, sepete ekleyebilir, sipariş verebilir ve hesaplarını yönetebilir.

## ✨ Özellikler

### 🔐 Kimlik Doğrulama
- Firebase Authentication ile güvenli giriş/kayıt
- Email doğrulama sistemi
- Şifre sıfırlama
- Otomatik oturum yönetimi

### 🛒 E-Ticaret Özellikleri
- Ürün kategorileri ve detay sayfaları
- Gelişmiş arama ve filtreleme
- Sepet yönetimi
- Favori ürünler
- Sipariş takibi
- Kupon sistemi

### 💳 Ödeme ve Teslimat
- Çoklu ödeme kartı desteği
- Adres yönetimi
- Sipariş geçmişi
- Güvenli ödeme işlemleri

### 👤 Kullanıcı Profili
- Kişisel bilgi yönetimi
- Cinsiyet seçimi
- Bildirimler
- Destek sistemi

## 🛠️ Teknolojiler

- **Flutter** - Cross-platform mobil uygulama geliştirme
- **Firebase Core** - Backend altyapısı
- **Firebase Auth** - Kimlik doğrulama
- **Riverpod** - State management
- **flutter_dotenv** - Environment variables
- **Dart** - Programlama dili

## 📁 Proje Yapısı

```
lib/
├── constants/          # Özel UI widget'ları
├── models/            # Veri modelleri (Address, PaymentCard)
├── providers/         # Riverpod state providers
├── screens/           # Uygulama ekranları
├── services/          # Firebase ve API servisleri
├── firebase_options.dart
└── main.dart         # Ana giriş noktası
```

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase hesabı
- Android Studio / VS Code

### Adımlar

1. **Projeyi klonlayın**
```bash
git clone https://github.com/ekenger/wardrovia.git
cd wardrovia
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Environment dosyasını oluşturun**
Proje kökünde `.env` dosyası oluşturun:
```env
# Firebase Configuration
FIREBASE_API_KEY_WEB=your_web_api_key
FIREBASE_API_KEY_ANDROID=your_android_api_key
FIREBASE_API_KEY_IOS=your_ios_api_key
FIREBASE_APP_ID_WEB=your_web_app_id
FIREBASE_APP_ID_ANDROID=your_android_app_id
FIREBASE_APP_ID_IOS=your_ios_app_id
FIREBASE_APP_ID_WINDOWS=your_windows_app_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MEASUREMENT_ID_WEB=your_web_measurement_id
FIREBASE_MEASUREMENT_ID_WINDOWS=your_windows_measurement_id
```

4. **Firebase yapılandırması**
- Firebase Console'da yeni proje oluşturun
- Authentication, Firestore, Storage servislerini aktifleştirin
- Platform bazlı yapılandırma dosyalarını ekleyin

5. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 📱 Ekran Görüntüleri

### Ana Sayfa
- Kategori görüntüleme
- Öne çıkan ürünler
- Arama fonksiyonu

### Ürün Detayı
- Ürün bilgileri
- Fotoğraf galerisi
- Sepete ekleme

### Sepet ve Ödeme
- Sepet yönetimi
- Adres seçimi
- Ödeme işlemi

## 🗂️ Ana Bileşenler

### Servisler
- `AddressService` - Teslimat adresi yönetimi
- `CartService` - Sepet işlemleri
- `CouponService` - İndirim kuponları
- `FavoritesService` - Favori ürünler
- `OrderService` - Sipariş yönetimi
- `PaymentService` - Ödeme işlemleri

### Modeller
- `Address` - Adres bilgileri
- `PaymentCard` - Ödeme kartı bilgileri

### Providers
- `GenderSelectionProvider` - Cinsiyet seçimi state yönetimi

## 🔐 Güvenlik

- Environment variables ile API key'ler güvenli şekilde saklanır
- Firebase security rules ile veri güvenliği
- Email doğrulama ile hesap güvenliği

### Mobile Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun


## 📞 İletişim

Proje Sahibi - [\[GitHub\]](https://github.com/ekenger)

Proje Linki: [https://github.com/ekenger/wardrovia](https://github.com/ekenger/wardrovia)


⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!