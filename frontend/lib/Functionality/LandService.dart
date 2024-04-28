import 'package:http/http.dart' as http;
import '../Functionality/config.dart';
import 'dart:convert';

import 'SignInAuth.dart';

class LandService {
  Future<Map<String, dynamic>> fetchMarkedLand(
      String tehsil, String khasra, String division) async {
    final storage = SecureStorageService();
    final String? token = await storage.getToken();
    final Uri apiUri = Uri.parse(
        '${AppConfig.baseURL}get_marked_land/$tehsil/$khasra/$division/');
    final response = await http.get(apiUri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load marked land');
    }
  }
}
