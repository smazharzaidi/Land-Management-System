import 'package:http/http.dart' as http;

class AuthService {
  final registrationUri = Uri.parse("http://192.168.1.3:8000/registration/");
  Future<String> registration(
      String username,
      String email,
      String password,
      String firstName,
      String lastName,
      String mobileNumber,
      String cnic) async {
    var response = await http.post((registrationUri), body: {
      "username": username,
      "email": email,
      "password": password,
      "first_name": firstName,
      "last_name": lastName,
      "mobile_number": mobileNumber,
      "cnic": cnic,
    });
    return response.body;
  }
}
