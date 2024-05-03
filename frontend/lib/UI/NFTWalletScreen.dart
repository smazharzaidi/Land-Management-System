import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flip_card/flip_card.dart';
import '../Functionality/NFTListProvider.dart';

class NFTListPage extends StatefulWidget {
  final String address;
  final String chain;

  const NFTListPage({
    Key? key,
    required this.address,
    required this.chain,
  }) : super(key: key);

  @override
  _NFTListPageState createState() => _NFTListPageState();
}

class _NFTListPageState extends State<NFTListPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NFTListProvider>(context, listen: false);
    provider.loadNFTList(widget.address, widget.chain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        title: Text('NFT List',
            style: GoogleFonts.lato(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<NFTListProvider>(
        builder: (context, provider, child) {
          if (provider.nftList.isEmpty) {
            return Center(
                child: Text('No NFTs found', style: GoogleFonts.lato()));
          }
          return ListView.builder(
            itemCount: provider.nftList.length,
            itemBuilder: (context, index) {
              var nftData = provider.nftList[index];
              var normalizedMetadata = nftData['normalized_metadata'];
              var imageUrl = 'https://gateway.pinata.cloud/ipfs/' +
                  normalizedMetadata['image'].substring(7);
              var description = normalizedMetadata['description'] ??
                  'No description available';

              return FlipCard(
                direction: FlipDirection.HORIZONTAL,
                front: buildCardFront(nftData['name'], imageUrl, description),
                back: buildCardBack(normalizedMetadata),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildCardFront(String? name, String imageUrl, String description) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: SizedBox(
        height: 275, // Ensure this is enough to hold the content nicely
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(imageUrl,
                  fit: BoxFit.cover, height: 200, width: double.infinity),
            ),
            ListTile(
              title: Text(name ?? 'Unnamed NFT',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              subtitle: Text(description,
                  style: GoogleFonts.lato(), overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () =>
                    _showDetailsDialog(context, imageUrl, description),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCardBack(Map<String, dynamic> normalizedMetadata) {
    var cnic = normalizedMetadata['attributes'].firstWhere(
            (attr) => attr['trait_type'] == 'CNIC',
            orElse: () => null)?['value'] ??
        'Not provided';
    var khasra = normalizedMetadata['attributes'].firstWhere(
            (attr) => attr['trait_type'] == 'Khasra Number',
            orElse: () => null)?['value'] ??
        'Not provided';
    var division = normalizedMetadata['attributes'].firstWhere(
            (attr) => attr['trait_type'] == 'Division',
            orElse: () => null)?['value'] ??
        'Not provided';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: SizedBox(
        height: 275, // Same height as the front
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Details',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text('CNIC: $cnic', style: GoogleFonts.lato(fontSize: 14)),
              Text('Khasra Number: $khasra',
                  style: GoogleFonts.lato(fontSize: 14)),
              Text('Division: $division',
                  style: GoogleFonts.lato(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(
      BuildContext context, String imageUrl, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl, fit: BoxFit.cover),
              SizedBox(height: 10),
              Text(description, style: GoogleFonts.lato()),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close', style: GoogleFonts.lato()),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }
}
