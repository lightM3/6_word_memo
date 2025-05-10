import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:duo_lingo/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class AnalysisPage extends StatefulWidget {
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  List<dynamic> userWords = [];
  Map<String, int> categoryStats = {};
  String? _username;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    _username = prefs.getString("username");

    if (token != null) {
      final words = await ApiService.fetchUserWords(token);
      final stats = await ApiService.fetchCategoryStats(token);
      setState(() {
        userWords = words;
        categoryStats = stats;
        isLoading = false;
      });
    }
  }

  int get learnedCount =>
      userWords.where((w) => (w["repetitionCount"] ?? 0) >= 6).length;

  double get successRate =>
      userWords.isEmpty ? 0 : learnedCount / userWords.length;

  Map<String, int> get categorySuccess {
    final map = <String, int>{};
    for (var item in userWords) {
      final cat = item["word"]?["category"] ?? "belirsiz";
      final isLearned = (item["repetitionCount"] ?? 0) >= 6;
      map[cat] = (map[cat] ?? 0) + (isLearned ? 1 : 0);
    }
    return map;
  }

  Future<pw.Font> _loadTurkishFont() async {
    final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    return pw.Font.ttf(fontData);
  }

  Future<void> _generatePdf(BuildContext context) async {
    final font = await _loadTurkishFont();
    final pdf = pw.Document();
    final pageWidth = PdfPageFormat.a4.availableWidth;

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'KELİME EZBER RAPORU',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                color: PdfColors.blue100,
                padding: pw.EdgeInsets.all(12),
                child: pw.Text(
                  'Kullanıcı: ${_username ?? "Bilinmeyen"}\nTarih: ${DateTime.now().toLocal()}',
                  style: pw.TextStyle(fontSize: 12, font: font),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Başarı Oranı: %${(successRate * 100).toStringAsFixed(1)}',
                style: pw.TextStyle(fontSize: 18, font: font),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Kategorilere Göre Başarı:',
                style: pw.TextStyle(fontSize: 16, font: font),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Kategori',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: font,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Öğrenilen',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: font,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Toplam',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: font,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...categoryStats.entries.map((entry) {
                    final totalCount =
                        userWords
                            .where(
                              (w) =>
                                  (w["word"]?["category"] ?? "belirsiz") ==
                                  entry.key,
                            )
                            .length;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(entry.key),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('${entry.value}'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('$totalCount'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Analiz Raporu'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : userWords.isEmpty
              ? Center(child: Text("Henüz analiz yapılacak kelime yok."))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text('Genel Başarı Oranı'),
                        subtitle: Text(
                          '%${(successRate * 100).toStringAsFixed(1)}',
                        ),
                        trailing: Icon(
                          successRate >= 0.7
                              ? Icons.check_circle
                              : Icons.warning,
                          color: successRate >= 0.7 ? Colors.green : Colors.red,
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
                    ...categorySuccess.entries.map((entry) {
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
                  ],
                ),
              ),
    );
  }
}
