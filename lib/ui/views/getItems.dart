import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:klitchen_stock/ui/controllers/filterItemsController.dart' show FilteredItemsController;
import 'package:klitchen_stock/ui/views/showitemsDetails.dart' show ItemDetailScreen;
import '../../api/api.dart';
import '../../widgets/addDialogbox.dart';

class FilteredItemsScreen extends StatefulWidget {
  final int categoryId;
  final String? categoryName;
  final String? qty;



  FilteredItemsScreen({Key? key, required this.categoryId, required this.categoryName,this.qty})
      : super(key: key);

  @override
  _FilteredItemsScreenState createState() => _FilteredItemsScreenState();
}

class _FilteredItemsScreenState extends State<FilteredItemsScreen> {
  final FilteredItemsController _fc = Get.find<FilteredItemsController>();

  @override
  void initState() {
    super.initState();
    getItems();
  }

  getItems() async {
    await _fc.GetFilteredItems(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        backgroundColor: Colors.blueGrey[50],
        appBar: AppBar(
          title: Center(
            child: Text(
              widget.categoryName ?? "Category",
              style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.orange,
          automaticallyImplyLeading: false,
        ),
        body: _fc.filteredItems.isEmpty
            ? Center(child: SpinKitFadingCircle(color: Colors.orange,))
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
            mainAxisExtent: 190,
          ),
          itemCount: _fc.filteredItems.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            var item = _fc.filteredItems[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(
                      itemId: item.itemId ?? 0,
                      itemName: item.engName ?? 'N/A',
                      qty: item.qty
                      ,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Add & Remove Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async{
                            await  showAddItemDialog(
                                context,
                                item.itemId,
                                item.categoryId,
                                widget.categoryName ?? '',
                                item.engName
                              );


                              // await Api.getFilteredItems(widget.categoryId);
                            },
                            child: const Icon(
                              Icons.add_circle_outline_outlined,
                              color: Colors.orange,
                              size: 35,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () async {
                              showRemoveItemDialog(
                                context,
                                item.itemId,
                                item.categoryId,
                                widget.categoryName ?? '',
                                item.engName

                              );
                            },
                            child: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.orange,
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Item Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.engName ?? 'No Name',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          const DottedLine(
                            dashLength: 3,
                            dashGapLength: 5,
                            dashColor: Colors.black54,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${item.qty ?? 'null'} ${item.unit ?? 'null'}",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          const DottedLine(
                            dashLength: 3,
                            dashGapLength: 5,
                            dashColor: Colors.black54,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.location ?? 'Unknown',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
