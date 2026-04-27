import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:klitchen_stock/ui/controllers/filterItemsController.dart' show FilteredItemsController;
import 'package:klitchen_stock/ui/models/items/filterItems.dart';
import 'package:klitchen_stock/ui/views/showitemsDetails.dart' show ItemDetailScreen;
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
  static const Color kOrange = Color(0xFFFF6B35);
  static const Color kOrangeLight = Color(0xFFFFF0EA);
  static const Color kBackground = Color(0xFFF7F8FA);
  static const Color kSurface = Colors.white;
  static const Color kBorder = Color(0xFFEEEFF4);
  static const Color kTextPrimary = Color(0xFF1A1D23);
  static const Color kTextSecondary = Color(0xFF9599B0);

  @override
  void initState() {
    super.initState();
    getItems();
  }

  getItems() async {
    await _fc.GetFilteredItems(widget.categoryId);
  }

  Map<String, List<FilterItem>> get _groupedItems {
    final Map<String, List<FilterItem>> grouped = {};

    for (final item in _fc.filteredItems) {
      grouped.putIfAbsent(item.engName, () => <FilterItem>[]).add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: kTextPrimary),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryName ?? 'Category',
              style: GoogleFonts.poppins(
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Items with godown-wise stock',
              style: GoogleFonts.poppins(
                color: kTextSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _fc.filteredItems.isEmpty
                ? const Center(
                    child: SpinKitFadingCircle(color: kOrange, size: 44),
                  )
                : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _groupedItems.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildSummaryCard(_groupedItems.length);
                          }

                          final entry = _groupedItems.entries.elementAt(index - 1);
                          return _buildItemGroupCard(context, entry.key, entry.value);
                        },
                      ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSummaryCard(int itemCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  'Available Items',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Open an item to view its godown-wise stock rows',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kOrangeLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$itemCount',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: kOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGroupCard(
    BuildContext context,
    String itemName,
    List<FilterItem> godownItems,
  ) {
    final totalQty = godownItems.fold<int>(0, (sum, item) => sum + item.qty);
    final unit = godownItems.isNotEmpty ? godownItems.first.unit : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
            iconColor: kOrange,
            collapsedIconColor: kTextSecondary,
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF0EA), Color(0xFFFFE0D1)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.kitchen_rounded,
                color: kOrange,
                size: 20,
              ),
            ),
            title: Text(
              itemName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: kTextPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${godownItems.length} godown${godownItems.length == 1 ? '' : 's'} | $totalQty $unit',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            children: godownItems
                .map((item) => _buildGodownRow(context, item))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGodownRow(BuildContext context, FilterItem item) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFEEE4)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailScreen(
                    itemId: item.itemId,
                    itemName: item.engName,
                    qty: item.qty,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: kOrange,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.location.isNotEmpty ? item.location : 'Unknown location',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: kTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.qty} ${item.unit}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: kTextSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Add',
                  icon: Icons.add_rounded,
                  onTap: () async {
                    await showAddItemDialog(
                      context,
                      item.itemId,
                      item.categoryId,
                      widget.categoryName ?? '',
                      item.engName,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  label: 'Use',
                  icon: Icons.remove_rounded,
                  onTap: () {
                    showRemoveItemDialog(
                      context,
                      item.itemId,
                      item.categoryId,
                      widget.categoryName ?? '',
                      item.engName,
                    );
                  },
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary ? kOrange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: const Color(0xFFFFD8C8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isPrimary ? Colors.white : kOrange,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isPrimary ? Colors.white : kOrange,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
