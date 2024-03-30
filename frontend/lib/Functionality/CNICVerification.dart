import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../UI/NFTSelection.dart';
import 'DashboardLogic.dart';
import 'SignInAuth.dart';
import 'config.dart';
import 'LandTransferData.dart';

class CNICVerification {
  final Uri baseURI = Uri.parse("${AppConfig.baseURL}");
  late DashboardLogic _logic;
  final BuildContext context;
  SecureStorageService storage = SecureStorageService();
  final LandTransferData landTransferData;
  CNICVerification(this.context, this._logic, this.landTransferData);

  Future<bool> verifyCNICAndNavigate(String cnic, String transferType) async {
    try {
      final String? token = await storage.getToken();
      if (token == null) {
        print('Debug: No token found');
        _showErrorDialog('Authorization token not found. Please login again.');
        return false;
      }
      print('Debug: Verifying CNIC $cnic with token $token');

      // First, verify CNIC
      final Uri verifyCnicUrl = Uri.parse('${baseURI}verify_cnic/');
      final response = await http.post(
        verifyCnicUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({'cnic': cnic}),
      );
      print('Debug: CNIC Verification Response Code: ${response.statusCode}');
      print('Debug: CNIC Verification Response Body: ${response.body}');

      // If CNIC verification is successful, fetch the wallet address
      if (response.statusCode == 200) {
        print('Debug: CNIC verified successfully.');
        landTransferData.updateDetails(transferee: cnic, type: transferType);
        landTransferData.printDetails(); // For debugging
        final String? walletAddress = await _logic.fetchWalletAddress();
        if (walletAddress != null) {
          // If wallet address is successfully fetched, navigate to NFTSelection
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NFTSelection(
                        address: walletAddress,
                        chain: 'sepolia',
                        landTransferData: landTransferData,
                      )));
          return true;
        } else {
          // Handle failure to fetch wallet address
          _showErrorDialog("Failed to fetch wallet address.");
          return false;
        }
      } else {
        _showErrorDialog("CNIC not found or invalid.");
        return false;
      }
    } catch (e) {
      print('Debug: An error occurred while verifying CNIC: $e');
      _showErrorDialog(
          "An error occurred while verifying CNIC. Please try again.");
      return false;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
