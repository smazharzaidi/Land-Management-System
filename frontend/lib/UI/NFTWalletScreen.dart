import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Load NFTs when the widget is inserted into the tree
    final provider = Provider.of<NFTListProvider>(context, listen: false);
    provider.loadNFTList(widget.address, widget.chain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NFTListProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 150.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('NFT List',
                      style: TextStyle(color: Colors.white)),
                  background: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg/275px-Field_in_K%C3%A4rk%C3%B6l%C3%A4.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var nftData = provider.nftList[index];
                    var normalizedMetadata = nftData['normalized_metadata'];
                    var imageUrl = 'https://ipfs.io/ipfs/' +
                        normalizedMetadata['image'].substring(7);
                    var description = normalizedMetadata['description'] ??
                        'No description available';
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

                    // Determine a consistent card height
                    final double cardHeight =
                        300.0; // Adjust based on your content

                    return FlipCard(
                      front: Card(
                        child: SizedBox(
                          height: cardHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                nftData['name'] ?? 'Unnamed NFT',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(description),
                            ],
                          ),
                        ),
                      ),
                      back: Card(
                        child: SizedBox(
                          height: cardHeight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Details',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text('CNIC: $cnic',
                                    style: TextStyle(fontSize: 14)),
                                Text('Khasra Number: $khasra',
                                    style: TextStyle(fontSize: 14)),
                                Text('Division: $division',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: provider.nftList.length,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
