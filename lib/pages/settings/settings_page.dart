import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  final int initialWordLimit;
  final ValueChanged<int> onWordLimitChanged;

  const SettingsPage({
    Key? key,
    required this.initialWordLimit,
    required this.onWordLimitChanged,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int _wordLimit;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _wordLimit = widget.initialWordLimit;
    _loadThemePref();
  }

  Future<void> _loadThemePref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", value);
    setState(() {
      _isDarkMode = value;
    });
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ayarlar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(
              'Günlük yeni kelime sınırı:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
                      setState(() => _wordLimit = value.toInt());
                    },
                  ),
                ),
                Text('$_wordLimit', style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 32),
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
