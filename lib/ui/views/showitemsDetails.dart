import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/api.dart'; // Import your API logic
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;
  final String itemName;
  final int? qty;


  const ItemDetailScreen({Key? key, required this.itemId, required this.itemName,this.qty}) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Future<Map<String, dynamic>> futureItemDetails;
  TextEditingController searchController = TextEditingController();
  List<dynamic> allItems = [];
  List<dynamic> filteredItems = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    futureItemDetails = Api.getItemDetails(widget.itemId);
  }
  getItems() async {

  }

  void _searchItems(String query) {
    if (query.isEmpty) {
      setState(() => filteredItems = allItems);
      return;
    }

    setState(() {
      filteredItems = allItems.where((item) {
        String itemName = item['itemName']?.toString().toLowerCase() ?? '';
        String category = item['categoryName']?.toString().toLowerCase() ?? '';
        String location = item['location']?.toString().toLowerCase() ?? '';
        String sevakName = item['sevakName']?.toString().toLowerCase() ?? '';
        String itemTo = item['itemTo']?.toString().toLowerCase() ?? '';

        return itemName.contains(query.toLowerCase()) ||
            category.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase()) ||
            sevakName.contains(query.toLowerCase()) ||
            itemTo.contains(query.toLowerCase());
      }).toList();
    });
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Colors.white,
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: searchController,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search items...',
            hintStyle: GoogleFonts.poppins(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _searchItems,
        )
            : Text(
          widget.itemName,
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredItems = allItems;
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureItemDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitFadingCircle(
                color: Colors.orange,
                size: 50.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/nodata.jpg',
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                    fit: BoxFit.cover,
                  ),


                  const SizedBox(height: 10),
                  const Text(
                    'No details available for this item',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            allItems = snapshot.data?['data'] ?? [];
            filteredItems = filteredItems.isEmpty && searchController.text.isEmpty ?  List.from(allItems): filteredItems;

            if (filteredItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/nodata.jpg',
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
                      fit: BoxFit.cover,
                    ),


                    const SizedBox(height: 10),
                    const Text(
                      'No details available for this item',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        var item = filteredItems[index];
                        String itemTo = item['itemTo']?.toString().toLowerCase() ?? '';

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['itemName'] ?? 'No Name',
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: itemTo == "add"
                                                ? Colors.green.withOpacity(0.9)
                                                : Colors.red,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            itemTo == "add" ? "Add" : "Remove",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const DottedLine(
                                      dashLength: 3,
                                      dashGapLength: 5,
                                      dashColor: Colors.black54,
                                      direction: Axis.horizontal,
                                    ),
                                    const SizedBox(height: 10),
                                    Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoText('Category', item['categoryName']),
                                        _buildInfoText('Location', item['location']),
                                      ],
                                    ),
                                    Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoText('Quantity', "${item['qty'] ?? ''} ${item['unit'] ?? ''}"),
                                        _buildInfoText('Date', item['date']),
                                      ],
                                    ),
                                    Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoText('Item Type', item['type']),
                                        _buildInfoText('Sevak Name', item['sevakName']),
                                      ],
                                    ),
                                    Flex(
                                      direction: Axis.horizontal,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoText('Sevak No', item['sevakNo']),
                                        _buildItemToText('Item To', item['itemTo'], itemTo),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // 🔻 Expiry Date Box - Full width at bottom
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.deepOrange, Colors.orange],

                                          // colors: [Color(0xFF757575), Color(0xFF212121)], // Sleek gray to black
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(12),
                                          topLeft: Radius.circular(10),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(0.3),
                                            offset: const Offset(2, 2),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child:  Text(
                                        "Expiry Dt : ${item['expiryDate'] != null && item['expiryDate'].toString().isNotEmpty
                                            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(item['expiryDate']))
                                            : 'N/A'}",
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      )


                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )

                        ;
                      },
                    ),
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.orange,
                //     boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Total Quantity:",
                //         style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                //       ),
                //       Text(
                //         "${widget.qty}",
                //         style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            );
          } else {
            return const Center(child: Text('No details available for this item'));
          }
        },
      ),
    );
  }

  Widget _buildInfoText(String title, dynamic value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$title: ',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: '${value ?? 'N/A'}',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemToText(String title, dynamic value, String itemTo) {
    Color textColor = itemTo == 'add' ? Colors.green : (itemTo == 'remove' ? Colors.red : Colors.black);
    FontWeight fontWeight = itemTo == 'add' || itemTo == 'remove' ? FontWeight.bold : FontWeight.normal;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$title: ',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: '${value ?? 'N/A'}',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: fontWeight, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
