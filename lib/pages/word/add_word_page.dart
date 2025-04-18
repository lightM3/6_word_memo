import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddWordPage extends StatefulWidget {
  @override
  _AddWordPageState createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _engController = TextEditingController();
  final _trController = TextEditingController();
  final _sampleController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _saveWord() {
    if (_engController.text.isNotEmpty && _trController.text.isNotEmpty) {
      Navigator.pop(context, {
        "eng": _engController.text,
        "tr": _trController.text,
        "sample": _sampleController.text,
        "imagePath": _selectedImage?.path,
      });
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
              decoration: InputDecoration(labelText: "Cümle İçinde Kullanımı"),
              maxLines: 2,
            ),
            SizedBox(height: 12),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 120)
                : Container(height: 120, color: Colors.grey[200]),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text("Resim Seç"),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveWord,
              child: Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
