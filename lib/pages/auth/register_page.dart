import 'package:flutter/material.dart';
import 'package:duo_lingo/services/api_service.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("Kayıt Ol")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre (Tekrar)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();
                final confirm = _confirmPasswordController.text.trim();

                if (password != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Şifreler uyuşmuyor.")),
                  );
                  return;
                }

                final success = await ApiService.register(
                  username,
                  email,
                  password,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("✅ Kayıt başarılı! Giriş yapabilirsiniz."),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "❌ Kayıt başarısız! Bilgileri kontrol edin.",
                      ),
                    ),
                  );
                }
              },
              child: Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
