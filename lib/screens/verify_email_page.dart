import 'package:Wardrovia/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Wardrovia/screens/home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  bool isLoading = false;
  late User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    checkEmailVerified();
  }

  Future<void> checkEmailVerified() async {
    setState(() => isLoading = true);

    await FirebaseAuth.instance.currentUser!.reload();
    user = FirebaseAuth.instance.currentUser!;

    setState(() {
      isEmailVerified = user.emailVerified;
      isLoading = false;
    });

    if (isEmailVerified) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-posta henüz doğrulanmamış.")),
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doğrulama e-postası gönderildi.")),
      );
      await Future.delayed(const Duration(seconds: 30));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("E-posta Doğrulaması")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "E-posta adresinizi doğrulamanız gerekiyor.\n"
                    "Lütfen e-postanıza gelen bağlantıya tıklayın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Doğrulama E-postasını Yeniden Gönder"),
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Doğrulama Durumunu Kontrol Et"),
                    onPressed: checkEmailVerified,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Çıkış Yap"),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
