import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'SignInAuth.dart';
import 'config.dart'; // Ensure this import path is correct

class NFTListProvider with ChangeNotifier {
  final Uri baseURI = Uri.parse("${AppConfig.baseURL}");
  late SecureStorageService storage = SecureStorageService();
  List<dynamic> _nftList = [];

  List<dynamic> get nftList => _nftList;

  Future<void> loadNFTList(String address, String chain) async {
    final String? token = await storage.getToken(); // Retrieve the token
    if (token == null) {
      print('No token found');
      throw Exception('Authentication token not found.');
    }
    final response = await http.get(
      Uri.parse('${baseURI}get_user_nfts?address=$address&chain=$chain'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final jsonData = jsonDecode(response.body);
      final filteredNftList =
          (jsonData['result'] as List<dynamic>).where((nft) {
        if (nft['normalized_metadata']?['attributes'] != null) {
          var attributes =
              nft['normalized_metadata']['attributes'] as List<dynamic>;
          // Debug print
          print("Checking NFT: ${nft['name']}, Attributes: $attributes");
          bool hasLandTrait =
              attributes.any((attr) => attr['trait_type'] == "Land");
          print("Has Land Trait: $hasLandTrait");
          return hasLandTrait;
        }
        return false;
      }).toList();

      _nftList = filteredNftList;
      notifyListeners();
    } else {
      print('Failed to load NFT list with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load NFT list');
    }
  }

  // void selectNFTAndInitiateTransfer(Map<String, dynamic> selectedNft) async {
  //   final String? token = await storage.getToken();
  //   if (token == null) {
  //     print("Token not found");
  //     return;
  //   }

  //   final Uri uri = Uri.parse('http://192.168.1.12:8000/create_land_transfer/');
  //   try {
  //     final response = await http.post(uri,
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode({
  //           'khasraNumber': selectedNft['khasraNumber'],
  //           // Include other required fields as per your backend API
  //         }));

  //     if (response.statusCode == 200) {
  //       print("Transfer initiated successfully");
  //     } else {
  //       print("Failed to initiate transfer");
  //     }
  //   } catch (e) {
  //     print("Error initiating transfer: $e");
  //   }
  // }
}
