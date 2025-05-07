import 'package:flutter/material.dart';
import 'package:duo_lingo/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;

                try {
                  print("Giriş işlemi başlatıldı...");
                  String? success = await ApiService.login(username, password);
                  print("Login sonucu: $success");

                  if (success != null) {
                    print("Login başarılı. Yönlendirme yapılıyor...");
                    Navigator.pushNamed(context, '/home');
                  } else {
                    print("Login başarısız");
                    setState(() {
                      errorMessage = 'Geçersiz kullanıcı adı veya şifre.';
                    });
                  }
                } catch (e) {
                  print("Login sırasında hata oluştu: $e");
                  setState(() {
                    errorMessage = 'Bir hata oluştu: $e';
                  });
                }
              },

              child: const Text('Giriş Yap'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text('Şifremi Unuttum'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Hesabınız yok mu? Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
