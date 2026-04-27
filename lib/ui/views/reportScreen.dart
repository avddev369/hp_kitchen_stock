import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../widgets/filterDialogueBox.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({Key? key}) : super(key: key);

  @override
  _ManageItemsScreenState createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  static const Color kOrange = Color(0xFFFF6B35);
  static const Color kOrangeLight = Color(0xFFFFF0EA);
  static const Color kBackground = Color(0xFFF7F8FA);
  static const Color kSurface = Colors.white;
  static const Color kBorder = Color(0xFFEEEFF4);
  static const Color kTextPrimary = Color(0xFF1A1D23);
  static const Color kTextSecondary = Color(0xFF9599B0);

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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: kTextPrimary),
        ),
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search Item name wise...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: kTextSecondary),
                ),
                style: const TextStyle(color: kTextPrimary),
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
            : Text(
                "Reports",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: kTextPrimary,
            ),
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
              isFilterApplied ? Icons.close_rounded : Icons.filter_alt_outlined,
              color: isFilterApplied ? kOrange : kTextPrimary,
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
      backgroundColor: kBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: _buildTopControls(),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: SpinKitFadingCircle(color: kOrange))
                : filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filteredItems.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildSummaryCard();
                          }
                          var item = filteredItems[index - 1];
                          return _buildItemCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Activity',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isFilterApplied
                          ? 'Showing filtered report results'
                          : 'Browse add and remove history',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: kOrangeLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${filteredItems.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (selectedFilters.isEmpty && !isSearching) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                Expanded(child: _buildRadioButton("add", "Add")),
                const SizedBox(width: 8),
                Expanded(child: _buildRadioButton("remove", "Remove")),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kOrangeLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.assessment_rounded, color: kOrange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedAction == 'add'
                  ? 'Showing added stock records'
                  : 'Showing removed stock records',
              style: const TextStyle(
                fontSize: 13,
                color: kTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(String value, String label) {
    final isSelected = selectedAction == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAction = value;
          _filterItems();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kOrange : kBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == 'add' ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
              size: 18,
              color: isSelected ? Colors.white : kTextSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : kTextPrimary,
              ),
            ),
          ],
        ),
      ),
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
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item["itemName"] ?? "No Name",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: item["action"] == "add"
                      ? const Color(0xFF22A45D)
                      : const Color(0xFFE05050),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item["action"] == "add" ? "Add" : "Remove",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoText("Category", item["categoryName"]),
                    const SizedBox(height: 10),
                    _infoText("Category (Guj)", item["categoryGujName"]),
                    const SizedBox(height: 10),
                    _infoText("Location", item["location"]),
                    const SizedBox(height: 10),
                    _infoText(
                        "Sevak Name",
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
                    _infoText("Qty", "${item["qty"]} ${item["unit"]}"),
                    const SizedBox(height: 10),
                    _infoText("Type", item["type"]),
                    const SizedBox(height: 10),
                    _infoText(
                        "Sevak No",
                        item["sevakNo"]?.isNotEmpty == true
                            ? item["sevakNo"]
                            : "N/A"),
                    const SizedBox(height: 10),
                    _infoText("Date", item["date"].toString().split("T")[0]),
                  ],
                ),
              ),
            ],
          ),

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
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: kOrangeLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assessment_outlined,
                color: kOrange,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No report data available',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String label, String? value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFEEE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value ?? "N/A",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
