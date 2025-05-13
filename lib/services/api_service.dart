import 'dart:io';
import 'package:duo_lingo/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static final String baseUrl = dotenv.env['API_URL']!;

  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'token': data['token'], 'username': username};
      } else {
        print("Login failed: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  static Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }

  static Future<String?> resetPassword(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/forgot-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["newPassword"];
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception("Sunucu hatası: ${response.statusCode}");
    }
  }

  //Kelime ekleme
  static Future<String?> addWord(
    String token,
    Map<String, dynamic> wordData,
  ) async {
    final url = Uri.parse('$baseUrl/api/words');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(wordData),
      );

      if (response.statusCode == 200) {
        return null; // Başarılı
      } else if (response.statusCode == 400) {
        final body = json.decode(response.body);
        if (body is String) return body;
        return "Bir hata oluştu";
      } else {
        print("Kelime ekleme hatası: ${response.statusCode}");
        return "Sunucu hatası";
      }
    } catch (e) {
      print("Kelime ekleme istisnası: $e");
      return "İstisna: $e";
    }
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

  //Ses dosyası ekleme
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

  //Resim dosyası ekleme
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

  static Future<List<dynamic>> fetchQuiz(String token) async {
    final url = Uri.parse('$baseUrl/api/quiz/today');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Quiz fetch failed: ${response.body}');
      return [];
    }
  }

  static Future<bool> submitQuiz(String token, List<int> correctWordIds) async {
    final url = Uri.parse('$baseUrl/api/quiz/submit');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(correctWordIds),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> fetchAnalysis(String token) async {
    final url = Uri.parse('$baseUrl/api/userword/analysis');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Analiz verileri alınamadı.");
    }
  }

  static Future<Map<String, int>> fetchCategoryStats(String token) async {
    final url = Uri.parse('$baseUrl/api/userword/category-stats');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return {
        for (var item in decoded)
          item['category'] as String: item['learnedCount'] as int,
      };
    } else {
      print('Kategori başarı verisi alınamadı: ${response.body}');
      return {};
    }
  }

  static Future<List<dynamic>> fetchAllWords(String token) async {
    final url = Uri.parse('$baseUrl/api/words/all');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Tüm kelimeler alınamadı: ${response.statusCode}");
      return [];
    }
  }

  static Future<List<dynamic>> fetchDueWords(String token) async {
    final url = Uri.parse('$baseUrl/api/userword/due');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Tekrar listesi alınamadı: ${response.statusCode}");
      return [];
    }
  }

  static Future<bool> resetPasswordWithToken(
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token, 'newPassword': newPassword}),
    );

    return response.statusCode == 200;
  }

}
