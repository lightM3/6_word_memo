import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duo_lingo/services/api_service.dart';

class WordleGamePage extends StatefulWidget {
  final bool useLearnedOnly;

  const WordleGamePage({super.key, required this.useLearnedOnly});

  @override
  State<WordleGamePage> createState() => _WordleGamePageState();
}

class _WordleGamePageState extends State<WordleGamePage> {
  String? _targetWord;
  final int maxAttempts = 6;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> _guesses = [];
  bool _showLengthBoxes = true;
  bool _showLengthWarning = false;

  @override
  void initState() {
    super.initState();
    _loadTargetWord();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTargetWord() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final words =
        widget.useLearnedOnly
            ? await ApiService.fetchUserWords(token)
            : await ApiService.fetchAllWords(token);

    final filteredWords =
        widget.useLearnedOnly
            ? words.where((w) => (w["repetitionCount"] ?? 0) >= 6).toList()
            : words;

    if (filteredWords.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Uygun kelime bulunamadı.")));
      Navigator.pop(context);
      return;
    }

    final random = Random();
    final selected = filteredWords[random.nextInt(filteredWords.length)];

    if (!mounted) return;
    setState(() {
      _targetWord =
          widget.useLearnedOnly
              ? selected["word"]["engWord"].toString().toLowerCase()
              : selected["engWord"].toString().toLowerCase();
    });
  }

  void _submitGuess() {
    final guess = _controller.text.trim().toLowerCase();
    if (_targetWord == null) return;

    if (guess.length != _targetWord!.length) {
      setState(() => _showLengthWarning = true);
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) setState(() => _showLengthWarning = false);
      });
      return;
    }

    setState(() {
      _guesses.add(guess);
      _controller.clear();
      _showLengthBoxes = false;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    if (guess == _targetWord || _guesses.length >= maxAttempts) {
      _showEndDialog(guess == _targetWord);
    }
  }

  void _showEndDialog(bool won) {
    if (!mounted) return;
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
                  if (!mounted) return;
                  setState(() {
                    _guesses.clear();
                    _controller.clear();
                    _showLengthBoxes = true;
                    _showLengthWarning = false;
                  });
                  _loadTargetWord();
                },
                child: Text("Yeniden Oyna"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (mounted) Navigator.pop(context);
                },
                child: Text("Ana Sayfa"),
              ),
            ],
          ),
    );
  }

  List<Color> _evaluateGuess(String guess) {
    final target = _targetWord!;
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
    final colors = _evaluateGuess(guess);
    double boxSize = MediaQuery.of(context).size.width / (guess.length + 2);

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
              color: colors[i],
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
    if (_targetWord == null) return SizedBox();
    double boxSize =
        MediaQuery.of(context).size.width / (_targetWord!.length + 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_targetWord!.length, (index) {
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
      appBar: AppBar(title: Text("Bulmaca")),
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
                            "Kelime ${_targetWord!.length} harfli olmalı!",
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
