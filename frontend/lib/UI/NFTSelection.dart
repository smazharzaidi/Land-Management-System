import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import '../Functionality/LandTransferData.dart';
import '../Functionality/NFTListProvider.dart';
import 'FingerPrinting.dart'; // Assuming this navigates to your next screen after selection.

class NFTSelection extends StatefulWidget {
  final String address;
  final String chain;
  final LandTransferData landTransferData;

  const NFTSelection({
    Key? key,
    required this.address,
    required this.chain,
    required this.landTransferData,
  }) : super(key: key);

  @override
  _NFTSelectionState createState() => _NFTSelectionState();
}

class _NFTSelectionState extends State<NFTSelection> {
  @override
  void initState() {
    super.initState();
    Provider.of<NFTListProvider>(context, listen: false)
        .loadNFTList(widget.address, widget.chain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Land'),
        backgroundColor: Colors.green,
      ),
      body: Consumer<NFTListProvider>(
        builder: (context, provider, child) {
          if (provider.nftList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: provider.nftList.length,
            itemBuilder: (context, index) {
              var nft = provider.nftList[index];
              var normalizedMetadata = nft['normalized_metadata'] ?? {};
              var imageUrl = normalizedMetadata['image']?.startsWith('ipfs://')
                  ? 'https://ipfs.io/ipfs/${normalizedMetadata['image'].substring(7)}'
                  : 'default_image_path';
              var description = normalizedMetadata['description'] ??
                  'No description available';
              // Extract additional details like CNIC, Khasra Number, Division from normalized_metadata
              var cnic = findAttribute(normalizedMetadata, 'CNIC');
              var khasraNumber =
                  findAttribute(normalizedMetadata, 'Khasra Number');
              var division = findAttribute(normalizedMetadata, 'Division');

              return FlipCard(
                front: Card(
                  child: Column(
                    children: [
                      Image.network(imageUrl, height: 250, fit: BoxFit.cover),
                      ListTile(
                        title: Text(nft['name'] ?? 'Unnamed NFT'),
                        subtitle: Text(description),
                      ),
                    ],
                  ),
                ),
                back: Card(
                  child: ListTile(
                    title: const Text('Details'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CNIC: $cnic'),
                        Text('Khasra Number: $khasraNumber'),
                        Text('Division: $division'),
                        ElevatedButton(
                          onPressed: () {
                            // Extract and update details in LandTransferData
                            widget.landTransferData.updateDetails(
                              tehsil:
                                  findAttribute(normalizedMetadata, 'Tehsil'),
                              khasraNumber: findAttribute(
                                  normalizedMetadata, 'Khasra Number'),
                              division:
                                  findAttribute(normalizedMetadata, 'Division'),
                            );
                            // Debug: Print the updated details
                            widget.landTransferData.printDetails();

                            // Navigate to the FingerPrinting page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FingerPrinting(
                                  nftData: nft, // Pass the NFT data as needed
                                ),
                              ),
                            );
                          },
                          child: const Text('Proceed with this NFT'),
                        ),
                        // Include an action button or other information as needed
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String findAttribute(Map<String, dynamic> metadata, String attributeName) {
    var attribute = metadata['attributes']?.firstWhere(
      (attr) => attr['trait_type'] == attributeName,
      orElse: () => {'value': 'Not provided'},
    );
    return attribute['value'];
  }
}
