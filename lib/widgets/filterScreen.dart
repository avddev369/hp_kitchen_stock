import 'dart:convert';
import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'filterDialogueBox.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<dynamic> items = [];
  List<dynamic> filteredItems = [];
  bool isLoading = false;
  String? selectedAction = "add";

  String? selectedCategory;
  String? selectedType;
  String? selectedSevakName;
  String? selectedItemName;
  String selectedDateRange = "All Time";

  bool purchase = false;
  bool seva = false;
  bool used = false;
  bool given = false;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://27.116.52.24:8060/getManageItems"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse["errorStatus"] == false) {
          setState(() {
            items = [
              ...jsonResponse["data"]["add"].map(
                (item) => {...item, "action": "add"},
              ),
              ...jsonResponse["data"]["remove"].map(
                (item) => {...item, "action": "remove"},
              ),
            ];
            filteredItems = List.from(items);
          });
        }
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  void applyFilter(Map<String, dynamic> filter) {
    setState(() {
      filteredItems = items.where((item) {
        bool matches = true;

        // Apply filters, but do not exclude "remove" or "add"
        if (filter["itemName"].isNotEmpty)
          matches &= item["itemName"] == filter["itemName"];
        if (filter["categoryName"].isNotEmpty)
          matches &= item["categoryName"] == filter["categoryName"];
        if (filter["type"].isNotEmpty)
          matches &= item["type"] == filter["type"];
        if (filter["sevakName"].isNotEmpty)
          matches &= item["sevakName"] == filter["sevakName"];

        return matches;
      }).toList();
    });

    // Ensure that both "add" and "remove" items are retained in the filtered list
    List<dynamic> addItems = filteredItems
        .where((item) => item["action"] == "add")
        .toList();
    List<dynamic> removeItems = filteredItems
        .where((item) => item["action"] == "remove")
        .toList();

    setState(() {
      filteredItems = [
        ...addItems,
        ...removeItems,
      ]; // Merge both filtered lists
    });
  }

  void openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialogueBox(onApplyFilter: applyFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Items"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: openFilterDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

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
                            // 🟠 Header Row (Item Name & Type)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item["itemName"] ?? "No Name",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item["action"] == "add"
                                        ? Colors.green.withOpacity(0.9)
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["action"] == "add" ? "Add" : "Remove",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),

                            DottedLine(
                              dashLength: 3,
                              dashGapLength: 5,
                              dashColor: Colors.black54,
                              direction: Axis.horizontal,
                            ),
                            SizedBox(height: 10),

                            // 🟢 Two-Column Layout
                            Row(
                              children: [
                                // Left Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _infoText(
                                        "Category:",
                                        item["categoryName"],
                                      ),
                                      SizedBox(height: 10),
                                      _infoText(
                                        "Category (Guj):",
                                        item["categoryGujName"],
                                      ),
                                      SizedBox(height: 10),
                                      _infoText(
                                        "Sevak Name:",
                                        item["sevakName"]?.isNotEmpty == true
                                            ? item["sevakName"]
                                            : "N/A",
                                      ),
                                    ],
                                  ),
                                ),

                                // Right Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _infoText(
                                        "Qty:",
                                        "${item["qty"]} ${item["unit"]}",
                                      ),
                                      SizedBox(height: 10),
                                      _infoText("Type:", item["type"]),
                                      SizedBox(height: 10),
                                      _infoText(
                                        "Sevak No:",
                                        item["sevakNo"]?.isNotEmpty == true
                                            ? item["sevakNo"]
                                            : "N/A",
                                      ),
                                      SizedBox(height: 10),
                                      _infoText(
                                        "Date:",
                                        item["date"].toString().split("T")[0],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: value ?? "N/A",
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
