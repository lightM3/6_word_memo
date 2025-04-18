import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
  onPressed: () {
    // Kayıt işlemi başarılı olduğunda
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Kayıt başarılı! Giriş yapabilirsiniz."),
    ));
    // Ana sayfaya değil, login sayfasına geri dönüş
    Navigator.pop(context);
  },
  child: Text('Kayıt Ol'),
),
          ],
        ),
      ),
    );
  }
}
