import 'package:duo_lingo/pages/game/wordle_mode_selector_page.dart';
import 'package:duo_lingo/services/api_service.dart';
import 'package:duo_lingo/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../word/word_list_page.dart';
import '../quiz/quiz_page.dart';
import '../quiz/quiz_schedule_page.dart';
import '../settings/settings_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String token;
  HomePage({required this.token});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _dailyWordLimit = 10;
  int _dueCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyLimit();
    _fetchDueCount();
  }

  void _loadDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyWordLimit = prefs.getInt('dailyLimit') ?? 10;
    });
  }

  Future<void> _fetchDueCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final dueWords = await ApiService.fetchDueWords(token);
    setState(() {
      _dueCount = dueWords.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('6 Tekrar Ezberleme'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: "Tema Değiştir",
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Çıkış Yap",
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("token");

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hoşgeldin kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş Geldiniz!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bugün tekrar edilmesi gereken $_dueCount kelimeniz var.',
                      style: TextStyle(fontSize: 16),
                    ),

                    SizedBox(height: 8),
                    Text(
                      'Günlük Kelime Limiti: $_dailyWordLimit',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Ana modüller
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildModuleCard(
                    context,
                    'Kelimelerim',
                    Icons.book,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordListPage(token: widget.token),
                      ),
                    ),
                  ),
                  _buildModuleCard(
                    context,
                    'Test Ol',
                    Icons.quiz,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuizPage()),
                    ),
                  ),
                  _buildModuleCard(
                    context,
                    'Tekrar Takvimi',
                    Icons.calendar_today,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuizSchedulePage()),
                    ),
                  ),
                  _buildModuleCard(
                    context,
                    'Ayarlar',
                    Icons.settings,
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsPage()),
                      );
                    },
                  ),

                  _buildModuleCard(
                    context,
                    'Analiz Raporu',
                    Icons.bar_chart,
                    Colors.teal,
                    () => Navigator.pushNamed(context, '/analysis'),
                  ),
                  _buildModuleCard(
                    context,
                    'Bulmaca',
                    Icons.extension,
                    Colors.indigo,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordleModeSelectorPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
