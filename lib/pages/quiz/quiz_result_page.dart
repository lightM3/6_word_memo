import 'package:duo_lingo/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duo_lingo/services/api_service.dart';
import '../../models/quiz_model.dart';

class QuizResultPage extends StatefulWidget {
  final QuizSession quizSession;

  const QuizResultPage({Key? key, required this.quizSession}) : super(key: key);

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  bool _isSubmitting = true;
  bool _submitSuccess = false;

  @override
  void initState() {
    super.initState();
    _submitResultsToServer();
  }

  Future<void> _submitResultsToServer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      // Doğru bilinen kelimelerin wordId'lerini al
      final correctIds = <int>[];

      for (int i = 0; i < widget.quizSession.questions.length; i++) {
        if (widget.quizSession.results[i]) {
          correctIds.add(widget.quizSession.questions[i].word.id);
        }
      }

      final success = await ApiService.submitQuiz(token, correctIds);

      setState(() {
        _isSubmitting = false;
        _submitSuccess = success;
      });
    } else {
      setState(() {
        _isSubmitting = false;
        _submitSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int correctCount = widget.quizSession.results.where((r) => r).length;
    double score = widget.quizSession.getScore() * 100;

    return Scaffold(
      appBar: AppBar(title: Text('Sınav Sonucu')),
      body:
          _isSubmitting
              ? Center(child: CircularProgressIndicator())
              : Padding(
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
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '${correctCount}/${widget.quizSession.questions.length} Doğru',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Başarı: %${score.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                color: score >= 70 ? Colors.green : Colors.red,
                              ),
                            ),
                            if (!_submitSuccess)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  '⚠️ Sonuçlar sunucuya gönderilemedi!',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '6 Tekrar Prensibi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Eğer bir kelimeyi 6 farklı zaman diliminde doğru yanıtlarsanız kalıcı olarak öğrenmiş sayılırsınız.',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tekrar Takvimi:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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

                    Text(
                      'Bir sonraki tekrar tarihiniz:',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${DateTime.now().add(Duration(days: 1)).day}.${DateTime.now().add(Duration(days: 1)).month}.${DateTime.now().add(Duration(days: 1)).year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString("token");

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomePage(token: token ?? ''),
                          ),
                          (route) => false,
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
