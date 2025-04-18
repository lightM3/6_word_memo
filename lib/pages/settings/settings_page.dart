import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final int initialWordLimit;
  final ValueChanged<int> onWordLimitChanged;

  const SettingsPage({
    super.key,
    required this.initialWordLimit,
    required this.onWordLimitChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int _wordLimit;

  @override
  void initState() {
    super.initState();
    _wordLimit = widget.initialWordLimit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ayarlar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Günlük yeni kelime sınırı:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _wordLimit.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: _wordLimit.toString(),
                    onChanged: (value) {
                      setState(() {
                        _wordLimit = value.toInt();
                      });
                    },
                  ),
                ),
                Text(
                  '$_wordLimit',
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                widget.onWordLimitChanged(_wordLimit);
                Navigator.pop(context);
              },
              icon: Icon(Icons.save),
              label: Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
