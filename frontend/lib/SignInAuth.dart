import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/SignInScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServiceLogin {
  final loginUri = Uri.parse("http://192.168.1.11:8000/login/");
  final refreshTokenUri =
      Uri.parse("http://192.168.1.11:8000/api/token/refresh/");
  final storage = SecureStorageService();
  Future<String?> getToken() async {
    return await storage.getToken();
  }

  Future<void> saveUsername(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<bool> login(String username, String password) async {
    var response = await http.post(
      loginUri,
      body: {"username": username, "password": password},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      await storage.saveToken(data['access']); // Save the access token

      // Extract and save the username
      String username = data['user']['username'];
      await saveUsername(username);
      print("Username: $username");


      return true;
    }
    return false;
  }

  Future<bool> refreshToken() async {
    String? refreshToken = await storage.getToken();
    if (refreshToken == null) return false;

    var response = await http.post(
      refreshTokenUri,
      body: jsonEncode({"refresh": refreshToken}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      await storage.saveToken(data['access']);
      return true;
    }
    return false;
  }

  Future<bool> isTokenValidAndNotExpired() async {
    final token = await storage.getToken();
    if (token == null) {
      return false;
    }
    return !await storage.isTokenExpired();
  }

  Future<void> logout() async {
    String? refreshToken = await storage
        .getToken(); // Assuming this gets the refresh token. You might need to adjust this to get the actual refresh token.
    if (refreshToken != null) {
      // Call the backend's logout endpoint
      await http.post(
        Uri.parse(
            "http://192.168.1.11:8000/logout/"), // Adjust the URL to your backend's logout endpoint
        body: jsonEncode({"refresh": refreshToken}),
        headers: {"Content-Type": "application/json"},
      );
    }
    await storage
        .deleteToken(); // Continue to delete the token from secure storage
  }

  Timer? _inactivityTimer;

  void startInactivityTimer(BuildContext context) {
    const inactivityDuration = Duration(minutes: 10);

    _inactivityTimer?.cancel(); // Cancel any existing timer
    _inactivityTimer =
        Timer(inactivityDuration, () => logoutDueToInactivity(context));
  }

  void logoutDueToInactivity(BuildContext context) async {
    await logout();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => SignInScreen()));
  }

  void resetInactivityTimer(BuildContext context) {
    startInactivityTimer(context);
  }
}

class SecureStorageService {
  final _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = json
        .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final exp = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);

    await _storage.write(key: 'authToken', value: token);
    await _storage.write(key: 'tokenExpiry', value: exp.toIso8601String());
  }

  Future<DateTime?> getTokenExpiry() async {
    final expiryString = await _storage.read(key: 'tokenExpiry');
    if (expiryString == null) return null;
    return DateTime.tryParse(expiryString);
  }

  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'authToken');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'authToken');
  }
}
