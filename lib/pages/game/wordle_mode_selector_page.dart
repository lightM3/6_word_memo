import 'package:flutter/material.dart';
import 'wordle_game_page.dart';

class WordleModeSelectorPage extends StatelessWidget {
  const WordleModeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wordle Modu Seç")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Oyun Modunu Seçin",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            _buildModeCard(
              context,
              title: "Öğrenilmiş Kelimelerden",
              icon: Icons.school,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordleGamePage(useLearnedOnly: true),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            _buildModeCard(
              context,
              title: "Tüm Kelimelerden",
              icon: Icons.language,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordleGamePage(useLearnedOnly: false),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
