import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duo_lingo/services/api_service.dart';

class QuizSchedulePage extends StatefulWidget {
  @override
  _QuizSchedulePageState createState() => _QuizSchedulePageState();
}

class _QuizSchedulePageState extends State<QuizSchedulePage> {
  List<Map<String, dynamic>> userWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserWords();
  }

  Future<void> _fetchUserWords() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final fetched = await ApiService.fetchUserWords(token);

    // Sadece nextRepetitionDate olanları sırala
    fetched.sort((a, b) {
      final dateA =
          DateTime.tryParse(a["nextRepetitionDate"] ?? "") ?? DateTime.now();
      final dateB =
          DateTime.tryParse(b["nextRepetitionDate"] ?? "") ?? DateTime.now();
      return dateA.compareTo(dateB);
    });

    setState(() {
      userWords = fetched;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tekrar Takvimi')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: userWords.length,
                itemBuilder: (context, index) {
                  final wordItem = userWords[index];
                  final wordData = wordItem["word"];

                  // Eğer wordData null gelirse atla
                  if (wordData == null) return SizedBox();

                  final repetitionCount = wordItem["repetitionCount"] ?? 0;
                  final dateStr = wordItem["nextRepetitionDate"] ?? "";
                  final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                  final daysLeft = date.difference(DateTime.now()).inDays;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(wordData["engWord"] ?? ""),
                      subtitle: Text(wordData["trWord"] ?? ""),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$repetitionCount/6 Tekrar'),
                          SizedBox(height: 4),
                          Text(
                            daysLeft <= 0 ? 'Bugün' : '$daysLeft gün sonra',
                            style: TextStyle(
                              color:
                                  daysLeft <= 0 ? Colors.red : Colors.grey[600],
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
