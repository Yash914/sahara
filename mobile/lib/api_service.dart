import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiService {
  static final String base = AppConfig.apiBaseUrl;
  static Future<bool> healthCheck() async { try { return (await http.get(Uri.parse('$base/'))).statusCode == 200; } catch (_) { return false; } }

  static Future<Map<String, dynamic>> analyzeInteraction({required String caseId, String? text, String? audioPath}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$base/analyze-interaction'));
    request.fields['case_id'] = caseId;
    if (text != null && text.trim().isNotEmpty) request.fields['text'] = text.trim();
    if (audioPath != null && audioPath.isNotEmpty) request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
    final response = await request.send(); final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('Analysis failed: $body');
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getCases() async {
    final response = await http.get(Uri.parse('$base/cases')); if (response.statusCode != 200) throw Exception(response.body);
    final data = jsonDecode(response.body); if (data is Map && data['cases'] is List) return List<dynamic>.from(data['cases']); if (data is List) return data; return [];
  }

  static Future<Map<String, dynamic>> getHistory(String caseId) async {
    final response = await http.get(Uri.parse('$base/case/$caseId/history')); if (response.statusCode != 200) throw Exception(response.body); return jsonDecode(response.body) as Map<String, dynamic>;
  }
  static Future<Map<String, dynamic>> getSummary(String caseId) async {
    final response = await http.get(Uri.parse('$base/case/$caseId/summary')); if (response.statusCode != 200) throw Exception(response.body); return jsonDecode(response.body) as Map<String, dynamic>;
  }
  static Future<Map<String, dynamic>> predict(Map<String, dynamic> payload) async {
    final response = await http.post(Uri.parse('$base/predict'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload)); if (response.statusCode != 200) throw Exception(response.body); return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
