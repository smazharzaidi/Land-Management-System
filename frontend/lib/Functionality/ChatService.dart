import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String apiUrl = "http://chatapiapp.southindia.azurecontainer.io/chat/";

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"text": message}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["response"];
      } else {
        return "Error from API service";
      }
    } catch (e) {
      return "Failed to connect to the API";
    }
  }
}
