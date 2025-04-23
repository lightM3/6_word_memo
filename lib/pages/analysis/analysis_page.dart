import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../utils/dummy_data.dart';
import '../../models/word_model.dart';

class AnalysisPage extends StatelessWidget {
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Sahte veriler
    List<Word> allWords = DummyData.getWords();
    int totalWords = allWords.length;
    int learnedWords = allWords.where((w) => w.repetitionCount >= 6).length;
    double successRate = totalWords == 0 ? 0 : (learnedWords / totalWords * 100);
    Map<String, int> categorySuccess = {
      'fruit': 3,
      'object': 2,
      'animal': 1,
      'vehicle': 4,
    };

    pdf.addPage(
  pw.Page(
    build: (pw.Context context) {
      final pageWidth = PdfPageFormat.a4.availableWidth;

      return pw.Padding(
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'Kelime Ezberleme Analiz Raporu'),
            pw.SizedBox(height: 20),
            pw.Text(
              'Genel Başarı Oranı: %${successRate.toStringAsFixed(1)}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('Kategorilere Göre Başarı:', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            ...categorySuccess.entries.map((entry) {
              final double percentage = entry.value / 6;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(entry.key.toUpperCase()),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    height: 10,
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(5),
                      color: PdfColors.grey300,
                    ),
                    child: pw.Container(
                      width: pageWidth * percentage,
                      height: 10,
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(5),
                        color: PdfColors.purple,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('%${(percentage * 100).toStringAsFixed(0)}'),
                  pw.SizedBox(height: 15),
                ],
              );
            }).toList(),
          ],
        ),
      );
    },
  ),
);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => pdf.save(),
      name: 'Kelime_Analiz_Raporu',
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Word> allWords = DummyData.getWords();
    int totalWords = allWords.length;
    int learnedWords = allWords.where((w) => w.repetitionCount >= 6).length;
    double successRate = totalWords == 0 ? 0 : learnedWords / totalWords;

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
              final double percentage = entry.value / 6;
              return ListTile(
                title: Text(entry.key.toUpperCase()),
                subtitle: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
                trailing: Text('%${(percentage * 100).toStringAsFixed(0)}'),
              );
            }).toList(),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _generatePdf(context),
              icon: Icon(Icons.picture_as_pdf),
              label: Text("PDF Oluştur"),
            ),
          ],
        ),
      ),
    );
  }
}
