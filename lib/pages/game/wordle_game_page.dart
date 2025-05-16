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
  bool _isLoading = false; // <- Spam tıklama engelleme

  @override
  void initState() {
    super.initState();
    _loadTargetWord();
  }

  Future<void> _loadTargetWord() async {
    setState(() {
      _isLoading = true;
    });

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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Uygun kelime bulunamadı.")));
        Navigator.pop(context);
      }
      return;
    }

    final random = Random();
    final selected = filteredWords[random.nextInt(filteredWords.length)];

    if (mounted) {
      setState(() {
        _targetWord =
            widget.useLearnedOnly
                ? selected["word"]["engWord"].toString().toLowerCase()
                : selected["engWord"].toString().toLowerCase();
        _isLoading = false;
      });
    }
  }

  void _submitGuess() {
    if (_isLoading || _targetWord == null) return;

    final guess = _controller.text.trim().toLowerCase();

    if (guess.length != _targetWord!.length) {
      if (mounted) {
        setState(() => _showLengthWarning = true);
      }
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showLengthWarning = false);
        }
      });
      return;
    }

    if (mounted) {
      setState(() {
        _guesses.add(guess);
        _controller.clear();
        _showLengthBoxes = false;
      });
    }

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
                  if (mounted) {
                    setState(() {
                      _guesses.clear();
                      _controller.clear();
                      _showLengthBoxes = true;
                      _showLengthWarning = false;
                    });
                    _loadTargetWord();
                  }
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
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0;
    const spacing = 4.0;

    final n = guess.length;
    final availableWidth = screenWidth - horizontalPadding;
    final totalSpacing = (n - 1) * spacing;
    final boxSize = ((availableWidth - totalSpacing) / n).clamp(10.0, 40.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(n, (i) {
          return Container(
            width: boxSize,
            height: boxSize,
            margin: EdgeInsets.only(right: i == n - 1 ? 0 : spacing),
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

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0;
    const spacing = 4.0;

    final n = _targetWord!.length;
    final availableWidth = screenWidth - horizontalPadding;
    final totalSpacing = (n - 1) * spacing;
    final boxSize = ((availableWidth - totalSpacing) / n).clamp(10.0, 40.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(n, (i) {
        return Container(
          width: boxSize,
          height: boxSize,
          margin: EdgeInsets.only(right: i == n - 1 ? 0 : spacing),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
                        onPressed: _isLoading ? null : _submitGuess,
                        child: Text("Gönder"),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
