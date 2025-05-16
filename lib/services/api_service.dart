import 'dart:io';
import 'package:duo_lingo/models/user_settings_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = 'http://10.138.158.31:5041';
  // Giriş yapma
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
        return {
          'token': data['token'],
          'username': username, // veya backend'den dönerse: data['username']
        };
      } else {
        print("Login failed: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // Kayıt olma
  static Future<bool> register(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Register failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Register exception: $e");
      return false;
    }
  }

  //Kelime ekleme
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
    if (response.statusCode == 201) return true;
    if (response.statusCode == 400 && response.body.contains("mevcut"))
      return false;
    return false;
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

  static Future<List<dynamic>> fetchQuiz(String token) async {
    final url = Uri.parse('$baseUrl/api/quiz/today');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Liste döner
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

  static Future<UserSettings?> getUserSettings(String token) async {
    final url = Uri.parse('$baseUrl/api/usersettings');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return UserSettings.fromJson(json.decode(response.body));
    } else {
      print('UserSettings GET failed: ${response.statusCode}');
      return null;
    }
  }

  static Future<bool> updateUserSettings(
    String token,
    UserSettings settings,
  ) async {
    final url = Uri.parse('$baseUrl/api/usersettings');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(settings.toJson()),
    );

    print(
      'Settings update response: ${response.statusCode} - ${response.body}',
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
