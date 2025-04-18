import 'package:flutter/material.dart';
import 'add_word_page.dart';

class WordListPage extends StatefulWidget {
  @override
  _WordListPageState createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  List<Map<String, String>> words = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelimelerim'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newWord = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddWordPage()),
              );
              if (newWord != null) {
                setState(() {
                  words.add(newWord);
                });
              }
            },
          )
        ],
      ),
      body: words.isEmpty
          ? Center(child: Text("Henüz kelime eklenmedi."))
          : ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: word["imagePath"] != null
                        ? Image.asset(word["imagePath"]!, width: 40, height: 40, fit: BoxFit.cover)
                        : Icon(Icons.image_not_supported),
                    title: Text(word["eng"] ?? ""),
                    subtitle: Text(word["tr"] ?? ""),
                  ),
                );
              },
            ),
    );
  }
}
