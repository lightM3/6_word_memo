// add_word_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:duo_lingo/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddWordPage extends StatefulWidget {
  @override
  _AddWordPageState createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _engController = TextEditingController();
  final _trController = TextEditingController();
  final _sampleController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _selectedImage;
  File? _selectedAudio;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    print("TOKEN YÜKLENDİ: $_token");
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
      });
    }
  }

  void _saveWord() async {
    if (_engController.text.isEmpty ||
        _trController.text.isEmpty ||
        _token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("İngilizce ve Türkçe alanlar zorunludur.")),
      );
      return;
    }

    String? uploadedImagePath;
    if (_selectedImage != null) {
      uploadedImagePath = await ApiService.uploadImage(
        _selectedImage!,
        _token!,
      );
    }
    String? uploadedAudioPath;
    if (_selectedAudio != null && _token != null) {
      uploadedAudioPath = await ApiService.uploadAudio(
        _selectedAudio!,
        _token!,
      );
    }

    final wordData = {
      "engWord": _engController.text,
      "trWord": _trController.text,
      "sampleSentence": _sampleController.text,
      "category": _categoryController.text,
      if (uploadedImagePath != null) "imagePath": uploadedImagePath,
      if (uploadedAudioPath != null) "audioPath": uploadedAudioPath,
    };

    final success = await ApiService.addWord(_token!, wordData);

    if (success) {
      Navigator.pop(context, true); // başarılı ekleme
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Kelime eklenemedi.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kelime Ekle")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _engController,
              decoration: InputDecoration(labelText: "İngilizce Kelime"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _trController,
              decoration: InputDecoration(labelText: "Türkçe Karşılığı"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _sampleController,
              decoration: InputDecoration(labelText: "Cümle"),
              maxLines: 2,
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: "Kategori"),
            ),
            SizedBox(height: 12),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 120)
                : Container(height: 120, color: Colors.grey[200]),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text("Resim Seç"),
            ),
            ElevatedButton.icon(
              onPressed: _pickAudio,
              icon: Icon(Icons.audio_file),
              label: Text("Ses Dosyası"),
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _saveWord, child: Text("Kaydet")),
          ],
        ),
      ),
    );
  }
}
