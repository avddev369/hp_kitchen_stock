import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../itemProvider.dart';

class FilterDialogueBox extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilter;

  const FilterDialogueBox({Key? key, required this.onApplyFilter})
      : super(key: key);

  @override
  _FilterDialogueBoxState createState() => _FilterDialogueBoxState();
}

class _FilterDialogueBoxState extends State<FilterDialogueBox> {
  String? selectedCategory;
  String? selectedLocation;
  String? selectedType;
  String? selectedSevakName;
  String? selectedItemName;
  String selectedDateRange = "All";
  String selectedExpiryDateRange="All";

  bool purchase = false;
  bool seva = false;
  bool used = false;
  bool given = false;

  DateTime? startDate;
  DateTime? endDate;

  DateTime? startExpDate;
  DateTime? endExpDate;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemProvider>(context, listen: false).fetchItems();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }
  Future<void> _selectExpDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startExpDate = picked;
        } else {
          endExpDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Set AlertDialog border radius
          ),
          title: const Text("Filter Options"),
          content: itemProvider.isLoading
              ? const Center(child: SpinKitFadingCircle(color: Colors.orange))
              : SingleChildScrollView(
                  child: Container(
                    width: 700,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader("Item Name"),
                        _buildDropdown(
                            "Item Name",
                            itemProvider.items
                                .map((e) => (e["itemName"] as String?) ?? "")
                                .toSet()
                                .toList(),
                            selectedItemName,
                                (value) => setState(() => selectedItemName = value)),

                        _buildHeader("Category"),
                        _buildDropdown(
                            "Category",
                            itemProvider.items
                                .map((e) => (e["categoryName"] as String?) ?? "")
                                .toSet()
                                .toList(),
                            selectedCategory,
                                (value) => setState(() => selectedCategory = value)),

                        _buildHeader("Location"),
                        _buildDropdown(
                            "Location",
                            itemProvider.items
                                .map((e) => (e["location"] as String?) ?? "")
                                .toSet()
                                .toList(),
                            selectedLocation,
                                (value) => setState(() => selectedLocation = value)),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader("Seva Type"),
                                  _buildDropdown(
                                    "Seva Type",
                                    itemProvider.items
                                        .map((e) => (e["type"] as String?) ?? "")
                                        .toSet()
                                        .toList(),
                                    selectedType,
                                        (value) => setState(() => selectedType = value),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10), // Space between the dropdowns
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader("Sevak Name"),
                                  _buildDropdown(
                                    "Sevak Name",
                                    itemProvider.items
                                        .map((e) => (e["sevakName"] as String?) ?? "")
                                        .toSet()
                                        .toList(),
                                    selectedSevakName,
                                        (value) => setState(() => selectedSevakName = value),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),


                        _buildHeader("Expiry Date"),

                        _buildDropdown(
                            "Date Range",
                            ["All", "Custom Range"],
                            selectedExpiryDateRange,
                                (value) => setState(() => selectedExpiryDateRange = value!)),

                        if (selectedExpiryDateRange == "Custom Range") ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateField(
                                  label: "Start Date",
                                  date: startExpDate,
                                  onTap: () => _selectExpDate(context, true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDateField(
                                  label: "End Date",
                                  date: endExpDate,
                                  onTap: () => _selectExpDate(context, false),
                                ),
                              ),
                            ],
                          )
                        ],

                        const SizedBox(height: 10),
                        _buildHeader("Date Range"),
                        _buildDropdown(
                            "Date Range",
                            ["All", "Custom Range"],
                            selectedDateRange,
                                (value) => setState(() => selectedDateRange = value!)),

                        if (selectedDateRange == "Custom Range") ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateField(
                                  label: "Start Date",
                                  date: startDate,
                                  onTap: () => _selectDate(context, true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDateField(
                                  label: "End Date",
                                  date: endDate,
                                  onTap: () => _selectDate(context, false),
                                ),
                              ),
                            ],
                          )
                        ],
                      ],
                    )

                  ),
                ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // Orange text
                side: const BorderSide(
                    color: Colors.orange, width: 2), // Orange outline
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                setState(() {
                  selectedCategory = null;
                  selectedLocation = null;
                  selectedType = null;
                  selectedSevakName = null;
                  selectedItemName = null;
                  selectedDateRange = "All";
                  selectedExpiryDateRange="All";
                  purchase = false;
                  seva = false;
                  used = false;
                  given = false;
                  startDate = null;
                  endDate = null;
                  startExpDate=null;
                  endExpDate=null;
                });
              },
              child: const Text("Clear All Filters"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Orange background
                foregroundColor: Colors.white, // White text
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                widget.onApplyFilter({
                  "itemName": selectedItemName ?? "",
                  "categoryName": selectedCategory ?? "",
                  "location": selectedLocation ?? "",
                  "type": selectedType ?? "",
                  "sevakName": selectedSevakName ?? "",
                  "purchase": purchase,
                  "seva": seva,
                  "used": used,
                  "given": given,
                  "dateRange": selectedDateRange,
                  "startDate": startDate != null
                      ? DateFormat("yyyy-MM-dd").format(startDate!)
                      : "",
                  "endDate": endDate != null
                      ? DateFormat("yyyy-MM-dd").format(endDate!)
                      : "",
                  "startExpDate": startExpDate != null
                      ? DateFormat("yyyy-MM-dd").format(startExpDate!)
                      : "",
                  "endExpDate": endExpDate != null
                      ? DateFormat("yyyy-MM-dd").format(endExpDate!)
                      : "",




                });
                Navigator.pop(context);
              },
              child: const Text("Apply Filter"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    final bool isDateRangeDropdown = label == "Date Range"; // Check if it's Date Range dropdown

    final TextEditingController searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField2<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange.withOpacity(0.2), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange.withOpacity(0.5), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        isExpanded: true,
        hint: Text(label, style: const TextStyle(color: Colors.black54)),
        value: selectedValue,
        onChanged: onChanged,
        items: items
            .map((value) => DropdownMenuItem<String>(
          value: value,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ))
            .toList(),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 4),
        ),
        dropdownSearchData: isDateRangeDropdown
            ? null // Remove search field for Date Range dropdown
            : DropdownSearchData(
          searchController: searchController,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                hintText: "Search...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.orange),
                  onPressed: () {
                    searchController.clear();
                    setState(() {}); // Refresh dropdown to show all items
                  },
                )
                    : null, // Hide clear button if search field is empty
              ),
              onChanged: (query) {
                setState(() {}); // Trigger rebuild to filter items dynamically
              },
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
          },
        ),
      ),
    );
  }



  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto', // Using Roboto font
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('dd MMM yyyy')
                      .format(date) // Converts to "02 Jan 2025"
                  : label,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
          ],
        ),
      ),
    );
  }
}
