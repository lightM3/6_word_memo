// lib/pages/quiz/quiz_page.dart
import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../utils/dummy_data.dart';
import 'quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late QuizSession _quizSession;
  bool _answered = false;
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    // Sahte quiz oluştur
    _quizSession = DummyData.generateQuizSession();
  }

  void _checkAnswer(int index) {
    if (_answered) return; // Zaten cevap verildi
    
    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      
      // Doğru cevap mı?
      QuizQuestion currentQuestion = _quizSession.questions[_quizSession.currentQuestionIndex];
      bool isCorrect = index == currentQuestion.correctOptionIndex;
      
      // Sonuçları kaydet
      _quizSession.results[_quizSession.currentQuestionIndex] = isCorrect;
    });
    
    // 1.5 saniye sonra bir sonraki soruya geç
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        _answered = false;
        _selectedOptionIndex = null;
        
        if (_quizSession.currentQuestionIndex < _quizSession.questions.length - 1) {
          _quizSession.currentQuestionIndex++;
        } else {
          // Quiz tamamlandı, sonuç sayfasına git
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultPage(quizSession: _quizSession),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    QuizQuestion currentQuestion = _quizSession.questions[_quizSession.currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelime Sınavı'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_quizSession.currentQuestionIndex + 1}/${_quizSession.questions.length}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // İlerleme çubuğu
            LinearProgressIndicator(
              value: (_quizSession.currentQuestionIndex + 1) / _quizSession.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            SizedBox(height: 24),
            
            // Kelime ve örnek cümle
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      currentQuestion.word.engWord,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if (currentQuestion.word.sampleSentence != null)
                      Text(
                        currentQuestion.word.sampleSentence!,
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Tekrar bilgisi
            Text(
              '${currentQuestion.word.repetitionCount}/6 Tekrar',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            
            // Seçenekler
            ...List.generate(currentQuestion.options.length, (index) {
              bool isCorrect = index == currentQuestion.correctOptionIndex;
              bool isSelected = _selectedOptionIndex == index;
              Color? buttonColor;
              
              if (_answered) {
                if (isCorrect) {
                  buttonColor = Colors.green;
                } else if (isSelected) {
                  buttonColor = Colors.red;
                }
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: buttonColor, // primary yerine backgroundColor kullanın
    padding: EdgeInsets.symmetric(vertical: 12),
  ),
  onPressed: _answered ? null : () => _checkAnswer(index),
  child: Text(
    currentQuestion.options[index],
    style: TextStyle(fontSize: 18),
  ),
)
              );
            }),
          ],
        ),
      ),
    );
  }
}