import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../widgets/filterDialogueBox.dart';
import '../../widgets/filterScreen.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({Key? key}) : super(key: key);

  @override
  _ManageItemsScreenState createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  String? selectedAction = "add";
  List<dynamic> items = [];
  List<dynamic> filteredItems = []; // For search filtering
  bool isLoading = false;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic> selectedFilters = {}; // Store selected filter values
  bool isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  void _filterItems() {
    setState(() {
      filteredItems = items.where((item) {
        bool matchesAction =
            selectedAction == null || item["action"] == selectedAction;
        bool matchesFilter = true;

        if (isFilterApplied) {
          if (selectedFilters["itemName"]?.isNotEmpty == true) {
            matchesFilter &= item["itemName"]?.toLowerCase() ==
                selectedFilters["itemName"]?.toLowerCase();
          }
          if (selectedFilters["categoryName"]?.isNotEmpty == true) {
            matchesFilter &= item["categoryName"]?.toLowerCase() ==
                selectedFilters["categoryName"]?.toLowerCase();
          }
          if (selectedFilters["location"]?.isNotEmpty == true) {
            matchesFilter &= item["location"]?.toLowerCase() ==
                selectedFilters["location"]?.toLowerCase();
          }
          if (selectedFilters["type"]?.isNotEmpty == true) {
            matchesFilter &= item["type"]?.toLowerCase() ==
                selectedFilters["type"]?.toLowerCase();
          }
          if (selectedFilters["sevakName"]?.isNotEmpty == true) {
            matchesFilter &= item["sevakName"]?.toLowerCase() ==
                selectedFilters["sevakName"]?.toLowerCase();
          }

          // ✅ Check Date Filtering
          DateTime? itemDate = DateTime.tryParse(item["date"]);
          if (itemDate != null) {
            if (selectedFilters["startDate"] != null) {
              matchesFilter &= itemDate.isAfter(selectedFilters["startDate"]) ||
                  itemDate.isAtSameMomentAs(selectedFilters["startDate"]);
            }
            if (selectedFilters["endDate"] != null) {
              matchesFilter &= itemDate.isBefore(selectedFilters["endDate"]) ||
                  itemDate.isAtSameMomentAs(selectedFilters["endDate"]);
            }
          }
        }

        return matchesAction && matchesFilter;
      }).toList();
    });
  }

  void fetchItems({bool forceRefresh = false}) async {
    if (items.isNotEmpty && !forceRefresh) {
      _filterItems(); // Use existing data
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://27.116.52.24:8060/getManageItems"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (!jsonResponse["errorStatus"]) {
          setState(() {
            items = [
              ...jsonResponse["data"]["add"]
                  .map((item) => {...item, "action": "add"}),
              ...jsonResponse["data"]["remove"]
                  .map((item) => {...item, "action": "remove"}),
            ];
          });
          _filterItems(); // Apply existing filters
        }
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.white,
            ),
            Text(" $e"),
          ],
        )),
      );
    }

    setState(() => isLoading = false);
  }

  // void applyFilter(Map<String, dynamic> filter) {
  //   setState(() {
  //     selectedFilters = filter;
  //     isFilterApplied = true;
  //
  //     bool isNotEmpty(String? value) => value?.trim().isNotEmpty ?? false;
  //
  //     // 🔹 Date parsing variables
  //     DateTime? startDate;
  //     DateTime? endDate;
  //     DateTime? expirystartDate;
  //     DateTime? expiryendDate;
  //
  //     // 🔹 Define expected input format
  //     final dateFormat = DateFormat("yyyy-MM-dd");
  //
  //     try {
  //       if (isNotEmpty(filter["startDate"])) {
  //         startDate = dateFormat.parse(filter["startDate"]!);
  //       }
  //       if (isNotEmpty(filter["endDate"])) {
  //         endDate = dateFormat.parse(filter["endDate"]!);
  //       }
  //       if (isNotEmpty(filter["startExpDate"])) {
  //         expirystartDate = dateFormat.parse(filter["startExpDate"]!);
  //       }
  //       if (isNotEmpty(filter["endExpDate"])) {
  //         expiryendDate = dateFormat.parse(filter["endExpDate"]!); // ✅ Corrected line
  //       }
  //     } catch (e) {
  //       showError("Invalid date format. Use yyyy-MM-dd.");
  //       return;
  //     }
  //
  //     // 🔴 Validations
  //     if (endDate != null && startDate == null) {
  //       showError("Start date is required when selecting an end date.");
  //       return;
  //     }
  //
  //     if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
  //       showError("End date cannot be before start date.");
  //       return;
  //     }
  //
  //     if (expiryendDate != null && expirystartDate == null) {
  //       showError("Expiry start date is required when selecting an end date.");
  //       return;
  //     }
  //
  //     if (expirystartDate != null &&
  //         expiryendDate != null &&
  //         expiryendDate.isBefore(expirystartDate)) {
  //       showError("Expiry end date cannot be before start date.");
  //       return;
  //     }
  //
  //     // 🔎 Filtering logic
  //     filteredItems = items.where((item) {
  //       if (isNotEmpty(filter["itemName"]) &&
  //           item["itemName"] != filter["itemName"]) return false;
  //
  //       if (isNotEmpty(filter["categoryName"]) &&
  //           item["categoryName"] != filter["categoryName"]) return false;
  //
  //       if (isNotEmpty(filter["location"]) &&
  //           item["location"] != filter["location"]) return false;
  //
  //       if (isNotEmpty(filter["type"]) &&
  //           item["type"] != filter["type"]) return false;
  //
  //       if (isNotEmpty(filter["sevakName"]) &&
  //           item["sevakName"] != filter["sevakName"]) return false;
  //
  //       // 🔹 Check item creation date
  //       DateTime? itemDate = DateTime.tryParse(item["date"]);
  //       if (itemDate == null) return false;
  //
  //       if (startDate != null && endDate != null) {
  //         final endOfEndDate = endDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
  //         if (itemDate.isBefore(startDate) || itemDate.isAfter(endOfEndDate)) {
  //           return false;
  //         }
  //       } else if (startDate != null) {
  //         if (itemDate.isBefore(startDate)) return false;
  //       }
  //
  //       // 🔹 Check expiry date
  //       final expiryStr = item["expiryDate"];
  //       if (expiryStr == null || expiryStr is! String || expiryStr.isEmpty) return false;
  //
  //       DateTime? itemExpDate = DateTime.tryParse(expiryStr);
  //       if (itemExpDate == null) return false;
  //
  //       if (expirystartDate != null && expiryendDate != null) {
  //         final endOfEndDate = expiryendDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
  //         if (itemExpDate.isBefore(expirystartDate) || itemExpDate.isAfter(endOfEndDate)) {
  //           return false;
  //         }
  //       } else if (expirystartDate != null) {
  //         if (itemExpDate.isBefore(expirystartDate)) return false;
  //       }
  //
  //       return true;
  //     }).toList();
  //
  //     // Optional: Handle empty state
  //     if (filteredItems.isEmpty) {
  //       print("No data found for selected filters.");
  //       // You can also set a flag here to display a message in UI.
  //     }
  //   });
  // }


// 🔹 Function to show error in Snackbar



  void applyFilter(Map<String, dynamic> filter) {
    setState(() {
      selectedFilters = filter;
      isFilterApplied = true;

      bool isNotEmpty(String? value) => value?.trim().isNotEmpty ?? false;

      // 🔹 Date parsing variables
      DateTime? startDate;
      DateTime? endDate;
      DateTime? expirystartDate;
      DateTime? expiryendDate;

      final dateFormat = DateFormat("yyyy-MM-dd");

      try {
        if (isNotEmpty(filter["startDate"])) {
          startDate = dateFormat.parse(filter["startDate"]!);
        }
        if (isNotEmpty(filter["endDate"])) {
          endDate = dateFormat.parse(filter["endDate"]!);
        }
        if (isNotEmpty(filter["startExpDate"])) {
          expirystartDate = dateFormat.parse(filter["startExpDate"]!);
        }
        if (isNotEmpty(filter["endExpDate"])) {
          expiryendDate = dateFormat.parse(filter["endExpDate"]!);
        }
      } catch (e) {
        showError("Invalid date format. Use yyyy-MM-dd.");
        return;
      }

      // 🔴 Validations
      if (endDate != null && startDate == null) {
        showError("Start date is required when selecting an end date.");
        return;
      }
      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        showError("End date cannot be before start date.");
        return;
      }
      if (expiryendDate != null && expirystartDate == null) {
        showError("Expiry start date is required when selecting an end date.");
        return;
      }
      if (expirystartDate != null &&
          expiryendDate != null &&
          expiryendDate.isBefore(expirystartDate)) {
        showError("Expiry end date cannot be before start date.");
        return;
      }

      // 🔎 Filtering logic
      filteredItems = items.where((item) {
        if (isNotEmpty(filter["itemName"]) &&
            item["itemName"] != filter["itemName"]) return false;

        if (isNotEmpty(filter["categoryName"]) &&
            item["categoryName"] != filter["categoryName"]) return false;

        if (isNotEmpty(filter["location"]) &&
            item["location"] != filter["location"]) return false;

        if (isNotEmpty(filter["type"]) &&
            item["type"] != filter["type"]) return false;

        if (isNotEmpty(filter["sevakName"]) &&
            item["sevakName"] != filter["sevakName"]) return false;

        // 🔹 Filter by item creation date
        DateTime? itemDate = DateTime.tryParse(item["date"]);
        if (itemDate == null) return false;

        if (startDate != null) {
          DateTime max = endDate != null
              ? endDate.add(Duration(days: 1)).subtract(Duration(seconds: 1))
              : startDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
          if (itemDate.isBefore(startDate) || itemDate.isAfter(max)) {
            return false;
          }
        }

        // 🔹 Filter by expiry date
        final expiryStr = item["expiryDate"];
        if (expiryStr == null || expiryStr is! String || expiryStr.isEmpty) return false;

        DateTime? itemExpDate = DateTime.tryParse(expiryStr);
        if (itemExpDate == null) return false;

        if (expirystartDate != null) {
          DateTime maxExp = expiryendDate != null
              ? expiryendDate.add(Duration(days: 1)).subtract(Duration(seconds: 1))
              : expirystartDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
          if (itemExpDate.isBefore(expirystartDate) || itemExpDate.isAfter(maxExp)) {
            return false;
          }
        }

        return true;
      }).toList();

      if (filteredItems.isEmpty) {
        print("No data found for selected filters.");
        // Optionally show UI message here
      }
    });
  }



  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error,
                color: Colors.white, size: 30), // White error icon
            SizedBox(width: 8), // Space between icon and text
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialogueBox(
        onApplyFilter: applyFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search Item name wise...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (query) {
                  setState(() {
                    filteredItems = items.where((item) {
                      return item["itemName"]
                              ?.toLowerCase()
                              .contains(query.toLowerCase()) ??
                          false;
                    }).toList();
                  });
                },
              )
            : const Text(
                "Reports",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredItems = items;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              isFilterApplied ? Icons.close : Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              if (isFilterApplied) {
                setState(() {
                  selectedFilters.clear();
                  isFilterApplied = false;
                  filteredItems = items;
                });
              } else {
                openFilterDialog();
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (selectedFilters.isEmpty &&
              !isSearching) // Hide radio buttons when filters or search are applied
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildRadioButton("add", "Add"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _buildRadioButton("remove", "Remove"),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: SpinKitFadingCircle(color: Colors.orange))
                : (filteredItems == null || filteredItems.isEmpty)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/nodata.jpg',
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height *
                                  0.3, // 30% of screen height
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No details available for this item',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: filteredItems!.length,
                        itemBuilder: (context, index) {
                          var item = filteredItems![index];
                          return _buildItemCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(String value, String label) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedAction,
          activeColor: Colors.white,
          onChanged: (value) {
            setState(() {
              selectedAction = value;
              _filterItems(); // Apply filtering & radio together
            });
          },
        ),
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }


  Widget _buildItemCard(dynamic item) {
    String formattedExpiry = "N/A";
    if (item["expiryDate"] != null && item["expiryDate"].toString().isNotEmpty) {
      try {
        formattedExpiry = DateFormat('dd-MM-yyyy').format(DateTime.parse(item["expiryDate"]));
      } catch (e) {
        formattedExpiry = "Invalid Date";
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // 🔹 Header
          Row(
            children: [
              Expanded(
                child: Text(
                  item["itemName"] ?? "No Name",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item["action"] == "add"
                      ? Colors.green.withOpacity(0.9)
                      : Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item["action"] == "add" ? "Add" : "Remove",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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

          // 🔹 Content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoText("Category:", item["categoryName"]),
                    const SizedBox(height: 10),
                    _infoText("Category (Guj):", item["categoryGujName"]),
                    const SizedBox(height: 10),
                    _infoText("Location:", item["location"]),
                    const SizedBox(height: 10),
                    _infoText(
                        "Sevak Name:",
                        item["sevakName"]?.isNotEmpty == true
                            ? item["sevakName"]
                            : "N/A"),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoText("Qty:", "${item["qty"]} ${item["unit"]}"),
                    const SizedBox(height: 10),
                    _infoText("Type:", item["type"]),
                    const SizedBox(height: 10),
                    _infoText(
                        "Sevak No:",
                        item["sevakNo"]?.isNotEmpty == true
                            ? item["sevakNo"]
                            : "N/A"),
                    const SizedBox(height: 10),
                    _infoText("Date:", item["date"].toString().split("T")[0]),
                  ],
                ),
              ),
            ],
          ),

          // 🔻 Expiry date container at bottom right
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Colors.orange],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                "Expiry Dt : $formattedExpiry",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          children: [
            TextSpan(
              text: value ?? "N/A",
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
