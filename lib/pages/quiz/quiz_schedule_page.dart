// lib/pages/quiz/quiz_schedule_page.dart
import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../utils/dummy_data.dart';

class QuizSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tekrarlanacak kelimeleri sahte veriden al
    List<Word> words = DummyData.getWords();
    
    // Kelimeleri tarihe göre sırala
    words.sort((a, b) => a.nextRepetitionDate!.compareTo(b.nextRepetitionDate!));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tekrar Takvimi'),
      ),
      body: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          final word = words[index];
          final daysLeft = word.nextRepetitionDate!.difference(DateTime.now()).inDays;
          
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(word.engWord),
              subtitle: Text(word.trWord),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${word.repetitionCount}/6 Tekrar'),
                  SizedBox(height: 4),
                  Text(
                    daysLeft <= 0 ? 'Bugün' : '$daysLeft gün sonra',
                    style: TextStyle(
                      color: daysLeft <= 0 ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}