import 'package:http/http.dart' as http;

class AuthServiceLogin {
  final loginUri = Uri.parse("http://192.168.1.3:8000/login/");
  Future<String> login(String username, String password) async {
    var response = await http
        .post((loginUri), body: {"login_id": username, "password": password});
    return response.body;
  }
}
