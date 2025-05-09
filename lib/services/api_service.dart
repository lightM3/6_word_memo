// api_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = 'http://10.138.158.31:5041';

  static Future<String?> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['token'];
      } else {
        print('Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  static Future<bool> addWord(
    String token,
    Map<String, dynamic> wordData,
  ) async {
    final url = Uri.parse('$baseUrl/api/words');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(wordData),
    );
    print('Add Word Response: ${response.statusCode} - ${response.body}');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> fetchUserWords(String token) async {
    final url = Uri.parse('$baseUrl/api/userword/all');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Gelen veri: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded.cast<Map<String, dynamic>>();
    } else {
      print('Kelime listesi çekilemedi: ${response.statusCode}');
      return [];
    }
  }
  static Future<String?> uploadAudio(File audioFile, String token) async {
    final url = Uri.parse('$baseUrl/api/words/upload-audio');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('file', audioFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['audioPath'];
    } else {
      print('Ses yükleme hatası: ${response.statusCode}');
      return null;
    }
  }


  static Future<String?> uploadImage(File imageFile, String token) async {
    final url = Uri.parse('$baseUrl/api/words/upload-image');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['imagePath'];
    } else {
      print('Resim yükleme hatası: ${response.statusCode}');
      return null;
    }
  }
}
