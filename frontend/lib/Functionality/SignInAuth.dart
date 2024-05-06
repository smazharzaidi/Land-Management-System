import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/UI/SignInScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'LandTransferData.dart';

class AuthServiceLogin {
  final String baseURL = "http://10.130.11.81:8000/";

  LandTransferData? landTransferData;
  static LandTransferData? currentLandTransferData;
  late W3MService _w3mService;
  final loginUri = Uri.parse("http://10.130.11.81:8000/login/");
  final refreshTokenUri =
      Uri.parse("http://10.130.11.81:8000/api/token/refresh/");
  final storage = SecureStorageService();
  Future<String?> getToken() async {
    return await storage.getToken();
  }

  Future<String> forgotPassword(String emailOrCnic) async {
    final uri = Uri.parse("${baseURL}forgot_password/");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"email_or_cnic": emailOrCnic},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'];
    } else {
      return "An error occurred. Please try again.";
    }
  }

  Future<void> saveUsername(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<String?> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Read the username using the same key you used to save it
    String? username = prefs.getString('username');
    return username;
  }

  Future<String> login(String username, String password) async {
    var response = await http.post(
      loginUri,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"username": username, "password": password},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['access'] != null) {
        await storage.saveToken(data['access']); // Save the access token
        await saveUsername(username);

        String cnic = ''; // Variable to hold CNIC
        if (username.contains('@')) {
          // If signed in with email, fetch CNIC from backend
          cnic = await fetchCNICFromEmail(username);
        } else {
          // If signed in with CNIC, use it directly
          cnic = username;
        }
        landTransferData = LandTransferData(
          transferorCNIC: cnic,
          transfereeCNIC: '',
          transferType: '',
          landTehsil: '',
          landKhasra: '',
          landDivision: '',
        );
        print("Stored CNIC: ${landTransferData?.transferorCNIC}");
        currentLandTransferData = landTransferData;

        // Optionally save wallet address if it exists
        String? walletAddress = data['user']['wallet_address'];
        if (walletAddress != null && walletAddress.isNotEmpty) {
          await storage.saveWalletAddress(walletAddress);
        }

        // Other necessary details can be saved as needed here

        return "success"; // Return "success" if login was successful
      } else {
        return "Access token missing in the response"; // Specific error if token is missing
      }
    } else if (response.statusCode == 400) {
      var data = json.decode(response.body);
      if (data['error'] != null) {
        return data[
            'error']; // Return the specific error message from the response
      } else {
        return "Invalid credentials"; // Generic error for 400 status
      }
    } else {
      // Handle other HTTP responses
      return "Login failed with status code ${response.statusCode}.";
    }
  }

  Future<String> resendConfirmationEmail(String email) async {
    try {
      print(
          "Attempting to POST to: ${Uri.parse("${baseURL}resend_confirmation/").toString()}");

      print("Request URL: ${baseURL}resend_confirmation/");
      var response = await http.post(
        Uri.parse("http://10.130.11.81:8000/resend_confirmation/"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"email_or_cnic": email},
      );

      if (response.statusCode == 200) {
        return "Confirmation email resent. Please check your inbox.";
      } else {
        return "Failed to resend confirmation email.";
      }
    } catch (e) {
      return "An error occurred while trying to resend confirmation email: ${e.toString()}";
    }
  }

  Future<String> fetchCNICFromEmail(String email) async {
    final url = Uri.parse('${this.baseURL}get_cnic_by_email/$email/');

    try {
      final response = await http.get(url, headers: {
        // Assuming you have a method to get the token, include it for authentication
        "Authorization": "Bearer ${await this.getToken()}",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['cnic']; // Return the CNIC
      } else {
        // Handle non-200 responses or add error logging
        throw Exception('Failed to load CNIC');
      }
    } catch (e) {
      // Handle exceptions or add error logging
      print(e.toString());
      throw Exception('Error fetching CNIC from email');
    }
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
        .getToken(); // This should get the refresh token, not the access token
    if (refreshToken != null) {
      var response = await http.post(
        Uri.parse(
            "http://10.130.11.81:8000/logout/"), // Adjust the URL to your backend's logout endpoint
        body: jsonEncode({"refresh": refreshToken}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        // Logout was successful on the backend
        if (_w3mService.isConnected) {
          await _w3mService.disconnect();
        }
        // Delete user's local wallet address and token as well
        await storage.deleteWalletAddress();
        await storage.deleteToken();
      } else {
        // Handle errors here
      }
    }
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
  Future<void> deleteWalletAddress() async {
    await _storage.delete(key: 'walletAddress');
  }

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

  Future<void> saveWalletAddress(String walletAddress) async {
    await _storage.write(key: 'walletAddress', value: walletAddress);
  }

  Future<String?> getWalletAddress() async {
    return await _storage.read(key: 'walletAddress');
  }
}
