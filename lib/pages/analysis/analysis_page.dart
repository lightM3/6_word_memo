import 'package:flutter/material.dart';
import '../../utils/dummy_data.dart';
import '../../models/word_model.dart';

class AnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sahte veriler
    List<Word> allWords = DummyData.getWords();
    int totalWords = allWords.length;
    int learnedWords = allWords.where((w) => w.repetitionCount >= 6).length;

    double successRate = totalWords == 0 ? 0 : learnedWords / totalWords;

    // Sahte kategori verisi (gerçek projede veritabanından gelir)
    Map<String, int> categorySuccess = {
      'fruit': 3,
      'object': 2,
      'animal': 1,
      'vehicle': 4,
    };

    return Scaffold(
      appBar: AppBar(title: Text('Analiz Raporu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Genel Başarı Oranı'),
                subtitle: Text('%${(successRate * 100).toStringAsFixed(1)}'),
                trailing: Icon(
                  successRate >= 0.7 ? Icons.check_circle : Icons.warning,
                  color: successRate >= 0.7 ? Colors.green : Colors.red,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Kategorilere Göre Başarı:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...categorySuccess.entries.map((entry) {
              return ListTile(
                title: Text(entry.key.toUpperCase()),
                subtitle: LinearProgressIndicator(
                  value: entry.value / 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
                trailing: Text('%${(entry.value / 6 * 100).toStringAsFixed(0)}'),
              );
            }).toList(),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Bu alan ileride PDF çıktısı olarak da geliştirilebilir
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Rapor kağıt çıktısı için hazır!")),
                );
              },
              icon: Icon(Icons.print),
              label: Text("Yazdır / PDF Al"),
            )
          ],
        ),
      ),
    );
  }
}
