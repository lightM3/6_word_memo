import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:duo_lingo/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisPage extends StatefulWidget {
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  List<dynamic> userWords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserWords();
  }

  Future<void> _loadUserWords() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      final words = await ApiService.fetchUserWords(token);
      setState(() {
        userWords = words;
        isLoading = false;
      });
    }
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    int total = userWords.length;
    int learned =
        userWords.where((w) => (w["repetitionCount"] ?? 0) >= 6).length;
    double rate = total == 0 ? 0 : (learned / total) * 100;

    final categoryMap = <String, int>{};
    for (var item in userWords) {
      final cat = item["word"]?["category"] ?? "belirsiz";
      categoryMap[cat] =
          (categoryMap[cat] ?? 0) +
          ((item["repetitionCount"] ?? 0) >= 6 ? 1 : 0);
    }

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
                  'Genel Başarı Oranı: %${rate.toStringAsFixed(1)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Kategorilere Göre Başarı:',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                ...categoryMap.entries.map((entry) {
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
    int total = userWords.length;
    int learned =
        userWords.where((w) => (w["repetitionCount"] ?? 0) >= 6).length;
    double rate = total == 0 ? 0 : learned / total;

    final categoryMap = <String, int>{};
    for (var item in userWords) {
      final cat = item["word"]?["category"] ?? "belirsiz";
      categoryMap[cat] =
          (categoryMap[cat] ?? 0) +
          ((item["repetitionCount"] ?? 0) >= 6 ? 1 : 0);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Analiz Raporu')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text('Genel Başarı Oranı'),
                        subtitle: Text('%${(rate * 100).toStringAsFixed(1)}'),
                        trailing: Icon(
                          rate >= 0.7 ? Icons.check_circle : Icons.warning,
                          color: rate >= 0.7 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Kategorilere Göre Başarı:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...categoryMap.entries.map((entry) {
                      final double percentage = entry.value / 6;
                      return ListTile(
                        title: Text(entry.key.toUpperCase()),
                        subtitle: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple,
                          ),
                        ),
                        trailing: Text(
                          '%${(percentage * 100).toStringAsFixed(0)}',
                        ),
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
