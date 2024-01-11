// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'FingerPrinting.dart';

class NFTSelection extends StatelessWidget {
  const NFTSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for NFTs
    final List<Map<String, dynamic>> dummyNFTs = [
      {"name": "Land 1", "description": "Land at Location A"},
      {"name": "Land 2", "description": "Land at Location B"},
      {"name": "Land 3", "description": "Land at Location C"},
      // Add more dummy NFTs as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Land',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // Set the color of AppBar icons to white
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: dummyNFTs.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.landscape, color: Colors.green),
              title: Text(dummyNFTs[index]["name"]),
              subtitle: Text(dummyNFTs[index]["description"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FingerPrinting()),
                );
                // Action on tapping NFT
              },
            ),
          );
        },
      ),
    );
  }
}
