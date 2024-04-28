import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'SignInAuth.dart';
import 'config.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class TaxChallanLogic {
  Future<String?> generateChallanPdf(
      BuildContext context, String userType) async {
    try {
      final storage = SecureStorageService();
      final String? token = await storage.getToken();
      final url = Uri.parse('${AppConfig.baseURL}generate_challan/$userType/');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final filePath = await _saveAndOpenFile(bytes, '$userType-challan.pdf');
        return filePath;
      } else {
        throw Exception(
            'Failed to download the PDF. Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
      return null;
    }
  }

  Future<String> _saveAndOpenFile(List<int> bytes, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    print('File saved at ${file.path}'); // Log the file path
    return file.path;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
