import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flip_card/flip_card.dart';
import '../Functionality/LandTransferData.dart';
import '../Functionality/NFTListProvider.dart';
import '../Functionality/SignInAuth.dart';
import 'FingerPrinting.dart'; // Assuming this navigates to your next screen after selection.

class NFTSelection extends StatefulWidget {
  final String address;
  final String chain;
  final LandTransferData landTransferData;
  final AuthServiceLogin authService;

  const NFTSelection(
      {Key? key,
      required this.address,
      required this.chain,
      required this.landTransferData,
      required this.authService})
      : super(key: key);

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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        title: Text('Select Land',
            style: GoogleFonts.lato(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
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
              var cnic = findAttribute(normalizedMetadata, 'CNIC');
              var khasraNumber =
                  findAttribute(normalizedMetadata, 'Khasra Number');
              var division = findAttribute(normalizedMetadata, 'Division');

              return FlipCard(
                front: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        child: Image.network(imageUrl,
                            height: 250, fit: BoxFit.cover),
                      ),
                      ListTile(
                        title: Text(nft['name'] ?? 'Unnamed NFT',
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.bold)),
                        subtitle: Text(description, style: GoogleFonts.lato()),
                      ),
                    ],
                  ),
                ),
                back: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                  child: ListTile(
                    title: Text('Details',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CNIC: $cnic', style: GoogleFonts.lato()),
                        Text('Khasra Number: $khasraNumber',
                            style: GoogleFonts.lato()),
                        Text('Division: $division', style: GoogleFonts.lato()),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 70.0),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.landTransferData.updateDetails(
                                tehsil:
                                    findAttribute(normalizedMetadata, 'Tehsil'),
                                khasraNumber: findAttribute(
                                    normalizedMetadata, 'Khasra Number'),
                                division: findAttribute(
                                    normalizedMetadata, 'Division'),
                              );
                              widget.landTransferData.printDetails();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FingerPrinting(
                                      landTransferData: widget.landTransferData,
                                      authService: widget.authService,
                                    ),
                                  ));
                            },
                            child: Text('Proceed with this NFT',
                                style: GoogleFonts.lato(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                padding: EdgeInsets.symmetric(vertical: 15.0)),
                          ),
                        ),
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
