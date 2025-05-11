import 'package:duo_lingo/services/api_service.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("Şifremi Unuttum")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Şifre sıfırlamak için e-posta adresinizi girin.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                if (email.isEmpty) return;

                try {
                  final newPassword = await ApiService.resetPassword(email);
                  if (newPassword != null) {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text("Yeni Şifreniz"),
                            content: Text("Geçici şifreniz: $newPassword"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Tamam"),
                              ),
                            ],
                          ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Bu e-postaya ait bir kullanıcı bulunamadı.",
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Bir hata oluştu: $e")),
                  );
                }
              },
              child: Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
