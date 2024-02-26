import 'package:flutter/material.dart';
// Import other necessary packages or files you might need

class NFTWalletScreen extends StatefulWidget {
  const NFTWalletScreen({Key? key}) : super(key: key);

  @override
  _NFTWalletScreenState createState() => _NFTWalletScreenState();
}

class _NFTWalletScreenState extends State<NFTWalletScreen> {
  // Assume we have a list of NFTs for demonstration purposes
  // In a real app, this list would probably come from a backend or blockchain query
  final List<String> _nfts = [
    'NFT #1 - Land Parcel',
    'NFT #2 - Art Piece',
    'NFT #3 - Collectible',
    // Add more NFTs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFT Wallet'),
        backgroundColor: Colors.green, // Consistent with the DashboardScreen
      ),
      body: ListView.builder(
        itemCount: _nfts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading:
                  const Icon(Icons.account_balance_wallet, color: Colors.green),
              title: Text(_nfts[index]),
              subtitle: const Text('Details about the NFT here'),
              onTap: () {
                // Implement what happens when you tap on an NFT
                // For example, showing more details or initiating a transfer
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement action for adding a new NFT or refreshing the list
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
