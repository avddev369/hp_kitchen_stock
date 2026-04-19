import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:klitchen_stock/ui/views/reportScreen.dart' show ManageItemsScreen;
import '../../api/api.dart';
import '../../helper/preferences.dart';
import '../../widgets/customAlertDialog.dart';
import 'auth/login.dart';
import 'getItems.dart';

class ShowItemsScreen extends StatefulWidget {
  final String Username; // Required parameter
  const ShowItemsScreen({required this.Username, Key? key}) : super(key: key);

  @override
  _ShowItemsScreenState createState() => _ShowItemsScreenState();
}

class _ShowItemsScreenState extends State<ShowItemsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  bool _showSearchBar = false;

  // Handle search logic
  Future<void> _searchItems(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() => _isLoading = true);

    List<dynamic> results = await Api.searchItems(query);

    setState(() {
      _isSearching = true;
      _searchResults = results;
      _isLoading = false;
    });
  }
  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.red,size: 33,),
              SizedBox(width: 8),
              Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Cancel",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red button background
                side: BorderSide(color: Colors.red.shade700, width: 1), // Optional border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Set border radius to 8
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding for better UI
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await Preferences.clearAll(); // Clear all stored preferences

                String? token = await Preferences.getToken();
                print("Token after logout: $token"); // Should print `null`

                Get.offAll(() => LoginScreen()); // Redirect to login screen
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Logout", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        title: _showSearchBar
            ? TextField(
          controller: _searchController,
          onChanged: _searchItems,
          decoration: InputDecoration(
            hintText: 'Search items...',
            border: InputBorder.none,
            hintStyle: GoogleFonts.roboto(color: Colors.white70),
          ),
          style: GoogleFonts.roboto(color: Colors.white, fontSize: 18),
          autofocus: true,
        )
            : Text('Kitchen Stock', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchResults.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.list_alt_rounded,color: Colors.white,),
            onPressed: () {
             Get.to(ManageItemsScreen());
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app_outlined,color: Colors.white,),
            onPressed: () => _logout(context), // Call logout function
          ),


        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
              child: SpinKitFadingCircle(color: Colors.orange, size: 50.0),
            )
                : _isSearching
                ? _buildSearchResults()
                : _buildDefaultItems(),
          ),
        ],
      ),
    );
  }

  // Search Results ListTile UI
  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
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
    )
        : ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        var item = _searchResults[index];

        return Card(
          color: Colors.white,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListTile(
            title: Text(
             "${item['engName']} | ${item['gujName']} ",
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              "${item['categoryName']}  |  ${item['categoryGujName']}",
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54),
            ),
            trailing: Text(
              item['location'] ?? '',
              style: GoogleFonts.roboto(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        );
      },
    );
  }

  // Default GridView (Non-search mode)
  Widget _buildDefaultItems() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Api.getItems(), // Load default items
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitFadingCircle(color: Colors.orange, size: 50.0),
          );
        } else if (snapshot.hasError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 10), // Space between icon and text
                Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          )
          );
        } else if (snapshot.hasData) {
          var items = snapshot.data!['data'];

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 0.0,
              mainAxisExtent: 140,
              childAspectRatio: 1.5,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilteredItemsScreen(
                        categoryId: item['categoryId'],
                        categoryName: item['engName'],
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['engName'],
                                style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                              showAddItemDialog(context, item['engName'], item['categoryId'].toString());
                              },
                              icon: Icon(Icons.add_circle_outline_outlined, color: Colors.orange, size: 28),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          item['gujName'],
                          style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

  void showAddItemDialog(BuildContext context, String categoryName, String categoryId) {
    TextEditingController engNameController = TextEditingController();
    TextEditingController gujNameController = TextEditingController();
    TextEditingController unitController = TextEditingController();

    String? selectedLocation; // Set default value
    List<String> locations = [
      "HPYM Kothar",
      "AVD",
      "Sukun Cold Storage",
      "Amar Cold Storage"
    ];
    String? selectedUnit;

    List<String> units = [
      "Kg", "gm", "mg", "Liter", "ml", "Piece", "Dozen", "Packet", "Box", "Set", "Pair", "Meter", "Yard", "Foot", "Inch", "Bundle"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Add New Item",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.orange),
          ),
          content: Container(
            width: 400, // Set dialog width
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category Display (Read-Only)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextFormField(

                        initialValue: categoryName,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Category",
                          labelStyle: TextStyle(color: Colors.grey.shade500,fontWeight: FontWeight.w400,fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.orange.withOpacity(0.5))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.orange,width: 2),),

                          fillColor: Colors.grey[200],
                          filled: true,
                        ),
                      ),
                    ),

                    // English Name Input
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextFormField(
                        controller: engNameController,
                        decoration: InputDecoration(
                          labelText: "Item Name (English)",
                          labelStyle: TextStyle(color: Colors.black54,fontWeight: FontWeight.w400,fontSize: 14),

                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.orange.withOpacity(0.5))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.orange,width: 2),),

                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Gujarati Name Input
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextFormField(
                        controller: gujNameController,
                        decoration: InputDecoration(
                          labelText: "Item Name (Gujarati)",
                          labelStyle: TextStyle(color: Colors.black54,fontWeight: FontWeight.w400,fontSize: 14),

                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.orange.withOpacity(0.5))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.orange,width: 2),),

                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Unit Input
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: DropdownButtonFormField2<String>(
                        value: selectedLocation,
                        decoration: InputDecoration(
                          labelText: "Unit",
                          labelStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.orange.withOpacity(0.5))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.orange, width: 2)),
                        ),
                        items: units.map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit, style: TextStyle(color: Colors.black54)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedLocation = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a unit';
                          }
                          return null;
                        },
                        dropdownStyleData: DropdownStyleData( // Move it here
                          maxHeight: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Location Dropdown
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: DropdownButtonFormField2<String>(
                        value: selectedLocation,
                        decoration: InputDecoration(
                          labelText: "Location",
                          labelStyle: TextStyle(color: Colors.black54,fontWeight: FontWeight.w400,fontSize: 14),

                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.orange.withOpacity(0.5))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.orange,width: 2),),

                        ),
                        items: locations.map((String location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(location,style: TextStyle(color: Colors.black54),),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedLocation = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a location';
                          }
                          return null;
                        },
                      ),
                    ),



                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Call the API to add the item
                  try {
                    var result = await Api.addItem(
                      categoryId,
                      engNameController.text,
                      gujNameController.text,
                      unitController.text,
                      selectedLocation!,
                    );
                    if (result['errorStatus'] == false) {
                      // On successful item addition, clear text fields and show success message
                      engNameController.clear();
                      gujNameController.clear();
                      unitController.clear();
                      selectedLocation = null;

                      // Ensure the dialog shows after the state is updated and UI is refreshed
                      Future.delayed(Duration(milliseconds: 100), () {
                        CustomAlertDialog.showSuccessDialog(context, "Success!");
                      });
                      // Refresh the list if needed
                      setState(() {});
                    }
                  } catch (e) {
                    print("Error: $e");
                    // Show error message using GetX dialog
                    Future.delayed(Duration(milliseconds: 100), () {
                      CustomAlertDialog.showErrorDialog(context, "Error!");
                    });
                  }
                  Navigator.pop(context); // Close the main dialog
                }

              },
              child: Text("Add",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
