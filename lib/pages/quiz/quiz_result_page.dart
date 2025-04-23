// lib/pages/quiz/quiz_result_page.dart
import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';

class QuizResultPage extends StatelessWidget {
  final QuizSession quizSession;
  
  const QuizResultPage({Key? key, required this.quizSession}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Doğru cevap sayısı
    int correctCount = quizSession.results.where((result) => result).length;
    double score = quizSession.getScore() * 100;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Sınav Sonucu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Sınav Tamamlandı',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${correctCount}/${quizSession.questions.length} Doğru',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Başarı: %${score.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 18, color: score >= 70 ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // 6 Tekrar prensibi bilgilendirmesi
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '6 Tekrar Prensibi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Eğer bir kelimeyi 6 farklı zaman diliminde doğru yanıtlarsanız kalıcı olarak öğrenmiş sayılırsınız.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tekrar Takvimi:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('• 1. Tekrar: 1 gün sonra'),
                    Text('• 2. Tekrar: 1 hafta sonra'),
                    Text('• 3. Tekrar: 1 ay sonra'),
                    Text('• 4. Tekrar: 3 ay sonra'),
                    Text('• 5. Tekrar: 6 ay sonra'),
                    Text('• 6. Tekrar: 1 yıl sonra'),
                  ],
                ),
              ),
            ),
            
            Spacer(),
            
            // Sonraki quiz tarihi
            Text(
              'Bir sonraki tekrar tarihiniz:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Text(
              '${DateTime.now().add(Duration(days: 1)).day}.${DateTime.now().add(Duration(days: 1)).month}.${DateTime.now().add(Duration(days: 1)).year}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            
            // Ana sayfaya dönüş butonu
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
  context,
  '/home',
  (Route<dynamic> route) => false, // önceki tüm rotaları kaldırır
);

              },
              child: Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }
}