import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'SignInAuth.dart';

class TaxChallanLogic {
  Future<Map<String, dynamic>> fetchChallanData(String khasraNumber,
      String tehsil, String division, String userType) async {
    final SecureStorageService storage = SecureStorageService();
    final String? token = await storage.getToken();
    Uri url = Uri.parse(
        '${AppConfig.baseURL}challan/$khasraNumber/$tehsil/$division/$userType');
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load challan data: ${response.statusCode}');
    }
  }
}
