import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:klitchen_stock/ui/controllers/filterItemsController.dart'
    show FilteredItemsController;
import 'package:klitchen_stock/ui/models/items/filterItems.dart';
import 'package:klitchen_stock/ui/views/showitemsDetails.dart'
    show ItemDetailScreen;
import '../../widgets/addDialogbox.dart';

class FilteredItemsScreen extends StatefulWidget {
  final int categoryId;
  final String? categoryName;
  final String? qty;

  FilteredItemsScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    this.qty,
  }) : super(key: key);

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
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    getItems();
  }

  getItems() async {
    setState(() {
      _isLoading = true;
    });
    await _fc.GetFilteredItems(widget.categoryId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  List<FilterItem> get _visibleItems {
    if (_searchQuery.trim().isEmpty) {
      return _fc.filteredItems.toList();
    }

    final query = _searchQuery.toLowerCase().trim();
    return _fc.filteredItems.where((item) {
      final haystacks = [
        item.engName,
        item.gujName,
        item.location,
        item.unit,
        item.qty.toString(),
      ];
      return haystacks.any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              style: GoogleFonts.poppins(color: kTextSecondary, fontSize: 11.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: getItems,
            icon: const Icon(Icons.refresh_rounded, color: kTextPrimary),
            tooltip: 'Refresh items',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: kOrangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_visibleItems.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: kOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: SpinKitFadingCircle(color: kOrange, size: 44),
                  )
                : _visibleItems.isEmpty
                ? _buildEmptyFilterState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _visibleItems.length,
                    itemBuilder: (context, index) {
                      final item = _visibleItems[index];
                      return _buildItemCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: GoogleFonts.poppins(fontSize: 13.5, color: kTextPrimary),
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: kTextSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: kTextSecondary),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded, color: kTextSecondary),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kOrange, width: 1.4),
          ),
        ),
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
              'No items available',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.trim().isEmpty
                  ? 'Items will appear here when stock is available.'
                  : 'No items matched your search.',
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

  Widget _buildItemCard(BuildContext context, FilterItem item) {
    final allowedGodowns =
        _fc.filteredItems
            .where((candidate) => candidate.itemId == item.itemId)
            .map((candidate) => candidate.location.trim())
            .where((location) => location.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: kOrangeLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.kitchen_rounded,
                    color: kOrange,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.engName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: kTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.gujName.trim().isNotEmpty)
                        Text(
                          item.gujName,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: kTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kOrangeLight,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${item.qty} ${item.unit}',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: kOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          allowedGodowns,
                        );
                      },
                      isPrimary: false,
                    ),
                  ],
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? kOrange : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary ? null : Border.all(color: const Color(0xFFFFD8C8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isPrimary ? Colors.white : kOrange),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isPrimary ? Colors.white : kOrange,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
