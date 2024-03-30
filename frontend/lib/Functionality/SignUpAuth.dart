import 'package:http/http.dart' as http;
import 'config.dart';

class AuthService {
  final Uri registrationUri = Uri.parse("${AppConfig.baseURL}registration/");
  Future<String> registration(String username, String email, String password,
      String name, String mobileNumber, String cnic) async {
    var response = await http.post((registrationUri), body: {
      "username": username,
      "email": email,
      "password": password,
      "name": name,
      "mobile_number": mobileNumber,
      "cnic": cnic,
    });
    return response.body;
  }
}
