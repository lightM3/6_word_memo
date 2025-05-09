import 'dart:math';
import 'package:flutter/material.dart';
import 'package:duo_lingo/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordleGamePage extends StatefulWidget {
  @override
  _WordleGamePageState createState() => _WordleGamePageState();
}

class _WordleGamePageState extends State<WordleGamePage> {
  late String _targetWord;
  final int maxAttempts = 6;
  List<String> _guesses = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showLengthBoxes = true;
  bool _showLengthWarning = false;

  @override
  void initState() {
    super.initState();
    _selectRandomLearnedWord();
  }

  Future<void> _selectRandomLearnedWord() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    final words = await ApiService.fetchUserWords(token);
    final learned =
        words.where((w) => (w["repetitionCount"] ?? 0) >= 6).toList();

    if (learned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Henüz öğrenilmiş kelimeniz yok.")),
      );
      Navigator.pop(context);
      return;
    }

    final random = Random();
    final selected = learned[random.nextInt(learned.length)];
    setState(() {
      _targetWord = selected["word"]["engWord"].toString().toLowerCase();
      print("📌 Target word: $_targetWord");
    });
  }

  void _submitGuess() {
    String guess = _controller.text.trim().toLowerCase();

    if (guess.length != _targetWord.length) {
      setState(() {
        _showLengthWarning = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showLengthWarning = false;
          });
        }
      });
      return;
    }

    setState(() {
      _guesses.add(guess);
      _controller.clear();
      _showLengthBoxes = false;
    });

    _scrollToBottom();

    if (guess == _targetWord || _guesses.length >= maxAttempts) {
      _showEndDialog(guess == _targetWord);
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showEndDialog(bool won) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(won ? "🎉 Tebrikler!" : "😢 Oyun Bitti"),
            content: Text(
              won
                  ? "Kelimeyi doğru tahmin ettiniz: $_targetWord"
                  : "Doğru kelime: $_targetWord",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _guesses.clear();
                    _controller.clear();
                    _showLengthBoxes = true;
                    _showLengthWarning = false;
                  });
                  _selectRandomLearnedWord();
                },
                child: Text("Yeniden Oyna"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Ana Sayfa"),
              ),
            ],
          ),
    );
  }

  List<Color> evaluateGuess(String guess, String target) {
    List<Color> colors = List.filled(guess.length, Colors.grey[400]!);
    List<bool> matched = List.filled(target.length, false);

    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == target[i]) {
        colors[i] = Colors.green;
        matched[i] = true;
      }
    }

    for (int i = 0; i < guess.length; i++) {
      if (colors[i] == Colors.green) continue;

      for (int j = 0; j < target.length; j++) {
        if (!matched[j] && guess[i] == target[j]) {
          colors[i] = Colors.yellow[700]!;
          matched[j] = true;
          break;
        }
      }
    }

    return colors;
  }

  Widget _buildGuessRow(String guess) {
    List<Color> boxColors = evaluateGuess(guess, _targetWord);
    double boxSize =
        MediaQuery.of(context).size.width / (_targetWord.length + 2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(guess.length, (i) {
          return Container(
            width: boxSize.clamp(30.0, 45.0),
            height: boxSize.clamp(30.0, 45.0),
            margin: EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: boxColors[i],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              guess[i].toUpperCase(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLengthBoxRow() {
    double boxSize =
        MediaQuery.of(context).size.width / (_targetWord.length + 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_targetWord.length, (index) {
        return Container(
          width: boxSize.clamp(30.0, 45.0),
          height: boxSize.clamp(30.0, 45.0),
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("Bulmaca (Wordle)")),
      body:
          _targetWord == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_showLengthWarning)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Kelime ${_targetWord.length} harfli olmalı!",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    if (_showLengthBoxes) _buildLengthBoxRow(),
                    SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _guesses.length,
                        itemBuilder:
                            (_, index) => _buildGuessRow(_guesses[index]),
                      ),
                    ),
                    if (_guesses.length < maxAttempts) ...[
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: "Tahmininizi girin",
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _submitGuess(),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _submitGuess,
                        child: Text("Gönder"),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
