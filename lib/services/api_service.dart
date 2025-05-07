import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = 'http://192.168.137.103:5041';

  // Android emulator için IP

  // 1. Login
  static Future<String?> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/login');

      final response = await http.post(
        Uri.parse('https://192.168.137.103'),
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

  // 2. Quiz sorularını getir
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

  // 3. Quiz sonuçlarını gönder
  static Future<bool> submitQuiz(String token, List<int> correctIds) async {
    final url = Uri.parse('$baseUrl/api/quiz/submit');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(correctIds),
    );

    return response.statusCode == 200;
  }
}
