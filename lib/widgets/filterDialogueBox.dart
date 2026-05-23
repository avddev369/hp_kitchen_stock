import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../itemProvider.dart';
import '../utils/search_utils.dart';

class FilterDialogueBox extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilter;

  const FilterDialogueBox({Key? key, required this.onApplyFilter})
    : super(key: key);

  @override
  _FilterDialogueBoxState createState() => _FilterDialogueBoxState();
}

class _FilterDialogueBoxState extends State<FilterDialogueBox> {
  String? selectedCategory;
  String? selectedType;
  String? selectedSevakName;
  String? selectedItemName;
  String selectedDateRange = "All";
  String selectedExpiryDateRange = "All";

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
        final items = itemProvider.items
            .whereType<Map<String, dynamic>>()
            .toList();
        final itemNameAliases = _buildAliases(items, "itemName", [
          "itemGujName",
          "gujName",
        ]);
        final categoryAliases = _buildAliases(items, "categoryName", [
          "categoryGujName",
        ]);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter Reports",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                "Choose the fields you want to use for filtering.",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          content: itemProvider.isLoading
              ? const Center(child: SpinKitFadingCircle(color: Colors.orange))
              : SingleChildScrollView(
                  child: Container(
                    width: 760,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          title: "Basic Details",
                          subtitle:
                              "Pick the item, category, activity type, or sevak name.",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader("Item Name"),
                              _buildDropdown(
                                "Item Name",
                                items
                                    .map(
                                      (e) => (e["itemName"] as String?) ?? "",
                                    )
                                    .toSet()
                                    .toList(),
                                selectedItemName,
                                (value) =>
                                    setState(() => selectedItemName = value),
                                itemNameAliases,
                              ),
                              _buildHeader("Category"),
                              _buildDropdown(
                                "Category",
                                items
                                    .map(
                                      (e) =>
                                          (e["categoryName"] as String?) ?? "",
                                    )
                                    .toSet()
                                    .toList(),
                                selectedCategory,
                                (value) =>
                                    setState(() => selectedCategory = value),
                                categoryAliases,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildHeader("Seva Type"),
                                        _buildDropdown(
                                          "Seva Type",
                                          items
                                              .map(
                                                (e) =>
                                                    (e["type"] as String?) ??
                                                    "",
                                              )
                                              .toSet()
                                              .toList(),
                                          selectedType,
                                          (value) => setState(
                                            () => selectedType = value,
                                          ),
                                          const {},
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildHeader("Sevak Name"),
                                        _buildDropdown(
                                          "Sevak Name",
                                          items
                                              .map(
                                                (e) =>
                                                    (e["sevakName"]
                                                        as String?) ??
                                                    "",
                                              )
                                              .toSet()
                                              .toList(),
                                          selectedSevakName,
                                          (value) => setState(
                                            () => selectedSevakName = value,
                                          ),
                                          const {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSectionCard(
                          title: "Expiry Date",
                          subtitle:
                              "Filter only the records that match a specific expiry range.",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader("Expiry Range"),
                              _buildDropdown(
                                "Date Range",
                                ["All", "Custom Range"],
                                selectedExpiryDateRange,
                                (value) => setState(
                                  () => selectedExpiryDateRange = value!,
                                ),
                                const {},
                              ),
                              if (selectedExpiryDateRange ==
                                  "Custom Range") ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateField(
                                        label: "Start Date",
                                        date: startExpDate,
                                        onTap: () =>
                                            _selectExpDate(context, true),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDateField(
                                        label: "End Date",
                                        date: endExpDate,
                                        onTap: () =>
                                            _selectExpDate(context, false),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSectionCard(
                          title: "Created Date",
                          subtitle:
                              "Use this when you want records from a specific entry period.",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader("Created Date Range"),
                              _buildDropdown(
                                "Date Range",
                                ["All", "Custom Range"],
                                selectedDateRange,
                                (value) =>
                                    setState(() => selectedDateRange = value!),
                                const {},
                              ),
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
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDateField(
                                        label: "End Date",
                                        date: endDate,
                                        onTap: () =>
                                            _selectDate(context, false),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // Orange text
                side: const BorderSide(
                  color: Colors.orange,
                  width: 2,
                ), // Orange outline
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedCategory = null;
                  selectedType = null;
                  selectedSevakName = null;
                  selectedItemName = null;
                  selectedDateRange = "All";
                  selectedExpiryDateRange = "All";
                  purchase = false;
                  seva = false;
                  used = false;
                  given = false;
                  startDate = null;
                  endDate = null;
                  startExpDate = null;
                  endExpDate = null;
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
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                widget.onApplyFilter({
                  "itemName": selectedItemName ?? "",
                  "categoryName": selectedCategory ?? "",
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

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
    Map<String, List<String>> searchAliases,
  ) {
    final bool isDateRangeDropdown =
        label == "Date Range"; // Check if it's Date Range dropdown

    final TextEditingController searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: DropdownButtonFormField2<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.orange.withOpacity(0.2),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.orange.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        isExpanded: true,
        hint: Text(
          'Select $label',
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        value: selectedValue,
        onChanged: onChanged,
        items: items
            .map(
              (value) => DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(value, overflow: TextOverflow.ellipsis),
                ),
              ),
            )
            .toList(),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: 6),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      hintText: "Search...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                searchController.clear();
                                setState(
                                  () {},
                                ); // Refresh dropdown to show all items
                              },
                            )
                          : null, // Hide clear button if search field is empty
                    ),
                    onChanged: (query) {
                      setState(
                        () {},
                      ); // Trigger rebuild to filter items dynamically
                    },
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  final value = item.value?.toString() ?? '';
                  return matchesSearchQuery(searchValue, [
                    value,
                    ...?searchAliases[value],
                  ]);
                },
              ),
      ),
    );
  }

  Map<String, List<String>> _buildAliases(
    Iterable<Map<String, dynamic>> source,
    String primaryKey,
    List<String> aliasKeys,
  ) {
    final aliases = <String, Set<String>>{};

    for (final item in source) {
      final primary = (item[primaryKey] ?? '').toString().trim();
      if (primary.isEmpty) continue;

      final bucket = aliases.putIfAbsent(primary, () => <String>{});
      bucket.add(primary);
      for (final key in aliasKeys) {
        final alias = (item[key] ?? '').toString().trim();
        if (alias.isNotEmpty) {
          bucket.add(alias);
        }
      }
    }

    return aliases.map(
      (key, value) => MapEntry(key, value.toList()),
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withOpacity(0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          child,
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('dd MMM yyyy').format(
                      date,
                    ) // Converts to "02 Jan 2025"
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
