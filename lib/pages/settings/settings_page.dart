import 'package:duo_lingo/models/user_settings_model.dart';
import 'package:duo_lingo/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _wordLimit = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final settings = await ApiService.getUserSettings(token);
    if (settings != null) {
      setState(() {
        _wordLimit = settings.dailyWordLimit;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final updated = UserSettings(dailyWordLimit: _wordLimit);
    final success = await ApiService.updateUserSettings(token, updated);

    if (success) {
      await prefs.setInt('dailyWordLimit', _wordLimit);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Limit güncellendi. Yeni kelimeler yarından itibaren eklenecek.',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ayarlar kaydedilemedi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ayarlar')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: ListView(
                  children: [
                    Text(
                      'Günlük yeni kelime sınırı:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                      onPressed: _saveSettings,
                      icon: Icon(Icons.save),
                      label: Text("Kaydet"),
                    ),
                  ],
                ),
              ),
    );
  }
}
