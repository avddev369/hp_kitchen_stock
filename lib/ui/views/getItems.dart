import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:klitchen_stock/ui/controllers/filterItemsController.dart' show FilteredItemsController;
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
  String _selectedGodown = 'All';

  @override
  void initState() {
    super.initState();
    getItems();
  }

  getItems() async {
    await _fc.GetFilteredItems(widget.categoryId);
  }

  List<String> get _godownOptions {
    final locations = _fc.filteredItems
        .map((item) => item.location.toString().trim())
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...locations];
  }

  List<dynamic> get _visibleItems {
    if (_selectedGodown == 'All') {
      return _fc.filteredItems;
    }

    return _fc.filteredItems
        .where((item) => item.location.toString().trim() == _selectedGodown)
        .toList();
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
              'Items by godown',
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
          _buildFilterSection(),
          Expanded(
            child: _fc.filteredItems.isEmpty
                ? const Center(
                    child: SpinKitFadingCircle(color: kOrange, size: 44),
                  )
                : _visibleItems.isEmpty
                    ? _buildEmptyFilterState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _visibleItems.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildSummaryCard(_visibleItems.length);
                          }

                          final item = _visibleItems[index - 1];
                          return _buildItemCard(context, item);
                        },
                      ),
          ),
        ],
      ),
    ));
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Godown Filter',
            style: GoogleFonts.poppins(
              color: kTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Display items location-wise for faster stock checks',
            style: GoogleFonts.poppins(
              color: kTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _godownOptions.contains(_selectedGodown)
                    ? _selectedGodown
                    : 'All',
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                style: GoogleFonts.poppins(
                  color: kTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                items: _godownOptions
                    .map(
                      (godown) => DropdownMenuItem<String>(
                        value: godown,
                        child: Text(godown),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedGodown = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
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
                  _selectedGodown == 'All'
                      ? 'Tap any item to open full details'
                      : 'Showing items for $_selectedGodown',
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

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: kOrangeLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.filter_alt_off_rounded,
                color: kOrange,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No items in this godown',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different godown filter to view available items.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: kTextSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
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
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(
                  itemId: item.itemId ?? 0,
                  itemName: item.engName ?? 'N/A',
                  qty: item.qty,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.engName ?? 'No Name',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${item.qty ?? '0'} ${item.unit ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: kTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: kBackground,
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
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAF6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFEEE4)),
                  ),
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
                          item.location ?? 'Unknown location',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: kTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
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
                      const SizedBox(width: 6),
                      _buildActionButton(
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
