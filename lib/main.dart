import 'package:duo_lingo/pages/auth/forgot_password_page.dart' as forgot;
import 'package:duo_lingo/pages/game/wordle_mode_selector_page.dart';
import 'package:duo_lingo/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/analysis/analysis_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const WordMemoryApp(),
    ),
  );
}

class WordMemoryApp extends StatefulWidget {
  const WordMemoryApp({super.key});

  @override
  State<WordMemoryApp> createState() => _WordMemoryAppState();
}

class _WordMemoryAppState extends State<WordMemoryApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Ezberleme',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/analysis': (context) => AnalysisPage(),
        '/wordle': (context) => const WordleModeSelectorPage(),
        '/forgot-password': (context) => forgot.ForgotPasswordPage(),
      },
    );
  }
}
