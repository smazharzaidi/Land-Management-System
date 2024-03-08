import 'package:http/http.dart' as http;

class AuthService {
  final registrationUri = Uri.parse("http://192.168.1.12:8000/registration/");
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
