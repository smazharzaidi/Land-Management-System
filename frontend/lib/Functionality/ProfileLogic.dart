import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart'; // Assuming this file contains your base URL and other configurations
import 'SignInAuth.dart';

class UserProfile {
  String? email;
  String? mobileNumber;
  // Add other profile fields if necessary

  UserProfile({this.email, this.mobileNumber});
}

class ProfileLogic {
  late SecureStorageService storage = SecureStorageService();
  Future<UserProfile> getUserProfile() async {
    final String? token = await storage.getToken();
    var uri = Uri.parse('${AppConfig.baseURL}get_user_profile/');
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return UserProfile(
        email: data['email'],
        mobileNumber: data['mobile_number'],
      );
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<void> saveUserProfile(
      {required String email, required String mobileNumber}) async {
    final String? token = await storage.getToken();
    var uri = Uri.parse('${AppConfig.baseURL}update_user_profile/');
    var response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'email': email,
        'mobile_number': mobileNumber,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }
}
