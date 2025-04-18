import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hoş Geldiniz!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
              ),
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
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Geçici: giriş başarılı varsayılıyor
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Giriş Yap'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: Text('Şifremi Unuttum'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Hesabınız yok mu? Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
