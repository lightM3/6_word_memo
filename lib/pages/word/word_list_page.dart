import 'package:duo_lingo/config.dart';
import 'package:flutter/material.dart';
import 'package:duo_lingo/services/api_service.dart';
import 'package:duo_lingo/pages/word/add_word_page.dart';

class WordListPage extends StatefulWidget {
  final String token;
  WordListPage({required this.token});

  @override
  _WordListPageState createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  List<Map<String, dynamic>> words = [];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final fetchedWords = await ApiService.fetchUserWords(widget.token);
    print('Gelen veri: $fetchedWords');
    setState(() {
      words = fetchedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelimelerim'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddWordPage()),
              );

              if (result == true) await _loadWords();
            },
          ),
        ],
      ),
      body:
          words.isEmpty
              ? Center(child: Text("Henüz kelime eklenmedi."))
              : ListView.builder(
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final word = words[index];
                  final wordData = word["word"];
                  if (wordData == null) return SizedBox();

                  final imagePath = wordData["imagePath"];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading:
                          imagePath != null &&
                                  imagePath.toString().isNotEmpty &&
                                  imagePath != "Null" &&
                                  imagePath != "string"
                              ? Image.network(
                                '${ApiService.baseUrl}/$imagePath',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.broken_image),
                              )
                              : Icon(Icons.image_not_supported),
                      title: Text(wordData["engWord"] ?? ""),
                      subtitle: Text(wordData["trWord"] ?? ""),
                    ),
                  );
                },
              ),
    );
  }
}
