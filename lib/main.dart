import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/auth/forgot_password_page.dart';
import 'pages/home/home_page.dart';
import 'pages/analysis/analysis_page.dart';
import 'pages/game/wordle_game_page.dart';

void main() {
  runApp(WordMemoryApp());
}

class WordMemoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Ezberleme',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/home': (context) => HomePage(),
        '/analysis': (context) => AnalysisPage(),
        '/wordle': (context) => WordleGamePage(),
      },
    );
  }
}
