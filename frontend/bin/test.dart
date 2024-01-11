
import 'package:http/http.dart' as http;

main() async {
  // var response = await http.get(Uri.parse('http://127.0.0.1:8000/core/a'));
  AuthService authService = AuthService();
  var responseBody = await authService.registration(
      "aaa",
      "mazhardraws@gmail.com",
      "mazharsyed",
      "Syed",
      "Mazhar Abbas",
      "03335448187",
      "12101-3000871-4");
  print(responseBody);
}

class AuthService {
  final registrationUri = Uri.parse("http://127.0.0.1:8000/registration/");
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
