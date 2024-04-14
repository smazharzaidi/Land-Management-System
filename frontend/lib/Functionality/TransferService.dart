import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'SignInAuth.dart';

class TransferService {
  final SecureStorageService storage = SecureStorageService();
  Future<List<dynamic>> fetchApprovedTransfers() async {
    final String? token = await storage.getToken();
    final Uri apiUri = Uri.parse("${AppConfig.baseURL}get_approved_transfers/");
    final response = await http.get(apiUri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load approved transfers');
    }
  }

  Future<List<dynamic>> fetchPendingTransfers() async {
    final String? token = await storage.getToken();
    final Uri apiUri = Uri.parse("${AppConfig.baseURL}get_pending_transfers/");
    final response = await http.get(apiUri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load pending transfers');
    }
  }
}
