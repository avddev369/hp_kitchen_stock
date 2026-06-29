import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../widgets/filterDialogueBox.dart';
import '../../utils/search_utils.dart';

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
  List<dynamic> filteredItems = [];
  bool isLoading = false;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic> selectedFilters = {};
  bool isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  List<dynamic> _sortLatestFirst(List<dynamic> source) {
    final sorted = List<dynamic>.from(source);
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse((a["date"] ?? "").toString());
      final bDate = DateTime.tryParse((b["date"] ?? "").toString());
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  void _filterItems() {
    setState(() {
      filteredItems = _sortLatestFirst(items.where((item) {
        bool matchesAction =
            selectedAction == null || item["action"] == selectedAction;
        bool matchesFilter = true;

        if (isFilterApplied) {
          if (selectedFilters["itemName"]?.isNotEmpty == true) {
            matchesFilter &=
                item["itemName"]?.toLowerCase() ==
                selectedFilters["itemName"]?.toLowerCase();
          }
          if (selectedFilters["categoryName"]?.isNotEmpty == true) {
            matchesFilter &=
                item["categoryName"]?.toLowerCase() ==
                selectedFilters["categoryName"]?.toLowerCase();
          }
          if (selectedFilters["type"]?.isNotEmpty == true) {
            matchesFilter &=
                item["type"]?.toLowerCase() ==
                selectedFilters["type"]?.toLowerCase();
          }
          if (selectedFilters["sevakName"]?.isNotEmpty == true) {
            matchesFilter &=
                item["sevakName"]?.toLowerCase() ==
                selectedFilters["sevakName"]?.toLowerCase();
          }

          // ✅ Check Date Filtering
          DateTime? itemDate = DateTime.tryParse(item["date"]);
          if (itemDate != null) {
            if (selectedFilters["startDate"] != null) {
              matchesFilter &=
                  itemDate.isAfter(selectedFilters["startDate"]) ||
                  itemDate.isAtSameMomentAs(selectedFilters["startDate"]);
            }
            if (selectedFilters["endDate"] != null) {
              matchesFilter &=
                  itemDate.isBefore(selectedFilters["endDate"]) ||
                  itemDate.isAtSameMomentAs(selectedFilters["endDate"]);
            }
          }
        }

        return matchesAction && matchesFilter;
      }).toList());
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
            items = _sortLatestFirst([
              ...jsonResponse["data"]["add"].map(
                (item) => {...item, "action": "add"},
              ),
              ...jsonResponse["data"]["remove"].map(
                (item) => {...item, "action": "remove"},
              ),
            ]);
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
              Icon(Icons.error, color: Colors.white),
              Text(" $e"),
            ],
          ),
        ),
      );
    }

    setState(() => isLoading = false);
  }

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

      filteredItems = _sortLatestFirst(items.where((item) {
        if (isNotEmpty(filter["itemName"]) &&
            item["itemName"] != filter["itemName"])
          return false;

        if (isNotEmpty(filter["categoryName"]) &&
            item["categoryName"] != filter["categoryName"])
          return false;

        if (isNotEmpty(filter["type"]) && item["type"] != filter["type"])
          return false;

        if (isNotEmpty(filter["sevakName"]) &&
            item["sevakName"] != filter["sevakName"])
          return false;

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
        if (expiryStr == null || expiryStr is! String || expiryStr.isEmpty)
          return false;

        DateTime? itemExpDate = DateTime.tryParse(expiryStr);
        if (itemExpDate == null) return false;

        if (expirystartDate != null) {
          DateTime maxExp = expiryendDate != null
              ? expiryendDate
                    .add(Duration(days: 1))
                    .subtract(Duration(seconds: 1))
              : expirystartDate
                    .add(Duration(days: 1))
                    .subtract(Duration(seconds: 1));
          if (itemExpDate.isBefore(expirystartDate) ||
              itemExpDate.isAfter(maxExp)) {
            return false;
          }
        }

        return true;
      }).toList());

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
            Icon(
              Icons.error,
              color: Colors.white,
              size: 30,
            ), // White error icon
            SizedBox(width: 8), // Space between icon and text
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
      builder: (context) => FilterDialogueBox(onApplyFilter: applyFilter),
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
                    filteredItems = _sortLatestFirst(items.where((item) {
                      return matchesSearchQuery(query, [
                        item["itemName"]?.toString(),
                        item["itemGujName"]?.toString(),
                        item["gujName"]?.toString(),
                        item["categoryName"]?.toString(),
                        item["categoryGujName"]?.toString(),
                        item["sevakName"]?.toString(),
                        item["type"]?.toString(),
                        item["location"]?.toString(),
                        item["itemTo"]?.toString(),
                      ]);
                    }).toList());
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
            icon: const Icon(Icons.refresh_rounded, color: kTextPrimary),
            onPressed: () => fetchItems(forceRefresh: true),
          ),
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
                }
              });
              if (!isSearching) {
                _filterItems();
              }
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
                });
                _filterItems();
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
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      var item = filteredItems[index];
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
        // Header row — inline, no big card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Activity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                    Text(
                      isFilterApplied
                          ? 'Showing filtered results'
                          : 'Add & remove history',
                      style: TextStyle(fontSize: 11, color: kTextSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kOrangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${filteredItems.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: kOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (selectedFilters.isEmpty && !isSearching) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                Expanded(child: _buildRadioButton("add", "Add")),
                const SizedBox(width: 6),
                Expanded(child: _buildRadioButton("remove", "Remove")),
              ],
            ),
          ),
        ],
      ],
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
              value == 'add'
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
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
      } catch (_) {
        formattedExpiry = "Invalid";
      }
    }

    final bool isAdd = item["action"] == "add";
    final borderColor = isAdd
        ? const Color(0xFF22A45D)
        : const Color(0xFFE05050);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  item["itemName"] ?? "No Name",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAdd ? const Color(0xFFD1F5E4) : const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAdd ? "Add" : "Remove",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isAdd ? const Color(0xFF0A6640) : const Color(0xFF9B1C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Info grid — 3 columns
          Row(
            children: [
              _compactCell("Category", item["categoryName"]),
              const SizedBox(width: 5),
              _compactCell("Qty", "${item["qty"]} ${item["unit"]}"),
              const SizedBox(width: 5),
              _compactCell("Type", item["type"]),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              _compactCell(
                "Sevak",
                item["sevakName"]?.isNotEmpty == true ? item["sevakName"] : "N/A",
              ),
              const SizedBox(width: 5),
              _compactCell(
                "Sevak No",
                item["sevakNo"]?.isNotEmpty == true ? item["sevakNo"] : "N/A",
              ),
              const SizedBox(width: 5),
              _compactCell("Location", item["location"] ?? "N/A"),
            ],
          ),
          const SizedBox(height: 8),

          // Footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item["date"].toString().split("T")[0],
                style: const TextStyle(fontSize: 10, color: kTextSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Expiry: $formattedExpiry",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB84A1A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactCell(String label, String? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 8.5,
                color: kTextSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value ?? "N/A",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
              overflow: TextOverflow.ellipsis,
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
