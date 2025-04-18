import 'package:flutter/material.dart';
import '../word/word_list_page.dart';
import '../quiz/quiz_page.dart';
import '../quiz/quiz_schedule_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _dailyWordLimit = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('6 Tekrar Ezberleme')),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bugün tekrar edilmesi gereken 3 kelimeniz var.',
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
                      MaterialPageRoute(builder: (_) => WordListPage()),
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
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                            initialWordLimit: _dailyWordLimit,
                            onWordLimitChanged: (newLimit) {
                              setState(() {
                                _dailyWordLimit = newLimit;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Kelime limiti $_dailyWordLimit olarak güncellendi.'),
                                ),
                              );
                            },
                          ),
                        ),
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
