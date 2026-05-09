import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/api.dart';
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;
  final String itemName;
  final int? qty;

  const ItemDetailScreen({
    Key? key,
    required this.itemId,
    required this.itemName,
    this.qty,
  }) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  static const Color kOrange = Color(0xFFFF6B35);
  static const Color kOrangeLight = Color(0xFFFFF0EA);
  static const Color kBackground = Color(0xFFF7F8FA);
  static const Color kSurface = Colors.white;
  static const Color kBorder = Color(0xFFEEEFF4);
  static const Color kTextPrimary = Color(0xFF1A1D23);
  static const Color kTextSecondary = Color(0xFF9599B0);
  static const Color kTileBackground = Color(0xFFF7F8FA);

  late Future<Map<String, dynamic>> futureItemDetails;
  TextEditingController searchController = TextEditingController();
  List<dynamic> allItems = [];
  List<dynamic> filteredItems = [];
  bool isSearching = false;
  String selectedLocationFilter = 'All';

  @override
  void initState() {
    super.initState();
    futureItemDetails = Api.getItemDetails(widget.itemId);
  }

  void _searchItems(String query) {
    setState(_applyFilters);
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase().trim();

    filteredItems = allItems.where((item) {
      final itemName = item['itemName']?.toString().toLowerCase() ?? '';
      final category = item['categoryName']?.toString().toLowerCase() ?? '';
      final location = item['location']?.toString().toLowerCase() ?? '';
      final sevakName = item['sevakName']?.toString().toLowerCase() ?? '';
      final itemTo = item['itemTo']?.toString().toLowerCase() ?? '';

      final matchesSearch =
          query.isEmpty ||
              itemName.contains(query) ||
              category.contains(query) ||
              location.contains(query) ||
              sevakName.contains(query) ||
              itemTo.contains(query);

      final matchesLocation =
          selectedLocationFilter == 'All' ||
              location == selectedLocationFilter.toLowerCase();

      return matchesSearch && matchesLocation;
    }).toList();
  }

  List<String> get locationFilters {
    final locations = allItems
        .map((item) => item['location']?.toString().trim() ?? '')
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...locations];
  }

  @override
  void dispose() {
    searchController.dispose();
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
        title: isSearching
            ? TextField(
          controller: searchController,
          autofocus: true,
          style: GoogleFonts.poppins(color: kTextPrimary),
          decoration: InputDecoration(
            hintText: 'Search history...',
            hintStyle: GoogleFonts.poppins(color: kTextSecondary),
            border: InputBorder.none,
          ),
          onChanged: _searchItems,
        )
            : Text(
          widget.itemName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
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
                  _applyFilters();
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureItemDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitFadingCircle(color: kOrange, size: 46.0),
            );
          } else if (snapshot.hasError) {
            return _buildEmptyState('No details available for this item');
          } else if (snapshot.hasData) {
            allItems = snapshot.data?['data'] ?? [];
            if (filteredItems.isEmpty &&
                searchController.text.isEmpty &&
                selectedLocationFilter == 'All') {
              filteredItems = List.from(allItems);
            } else {
              _applyFilters();
            }

            if (filteredItems.isEmpty) {
              return _buildEmptyState(
                searchController.text.isEmpty && selectedLocationFilter == 'All'
                    ? 'No details available for this item'
                    : 'No matching history found',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
              itemCount: filteredItems.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSummaryCard();
                }
                final item = filteredItems[index - 1];
                final itemTo =
                    item['itemTo']?.toString().toLowerCase() ?? '';
                return _buildHistoryCard(item, itemTo);
              },
            );
          } else {
            return _buildEmptyState('No details available for this item');
          }
        },
      ),
    );
  }

  // ── Summary card ────────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item History',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      searchController.text.isEmpty &&
                          selectedLocationFilter == 'All'
                          ? 'View add and remove history for this item'
                          : 'Showing filtered history results',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: kOrangeLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${filteredItems.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: kOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: locationFilters.map((location) {
                final isSelected = selectedLocationFilter == location;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLocationFilter = location;
                        _applyFilters();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? kOrange : kOrangeLight,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? kOrange
                              : const Color(0xFFFFD8C8),
                        ),
                      ),
                      child: Text(
                        location,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : kOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── History card ────────────────────────────────────────────────────────────
  Widget _buildHistoryCard(dynamic item, String itemTo) {
    final isAdd = itemTo == 'add';
    final itemType = item['type']?.toString().toLowerCase() ?? '';
    final isPurchaseType =
        itemType == 'purchase' || itemType == 'purchased';
    final badgeColor =
    isAdd ? const Color(0xFF22A45D) : const Color(0xFFE05050);
    final locationName = item['location']?.toString().trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: item name + add/remove badge ─────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item['itemName'] ?? 'No Name',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: kTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAdd ? 'Add' : 'Remove',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Location badge ────────────────────────────────
            _buildHighlightBadge(
              icon: Icons.location_on_rounded,
              label: (locationName != null && locationName.isNotEmpty)
                  ? locationName
                  : 'N/A',
            ),

            const SizedBox(height: 12),
            Divider(color: kBorder, height: 1, thickness: 1),
            const SizedBox(height: 12),

            // ── Category (full width) ─────────────────────────
            _buildDetailTile(
              'Category',
              item['categoryName'],
              Icons.category_rounded,
            ),

            const SizedBox(height: 10),

            // ── Quantity | Date ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    'Quantity',
                    "${item['qty'] ?? ''} ${item['unit'] ?? ''}".trim(),
                    Icons.scale_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailTile(
                    'Date',
                    item['date'],
                    Icons.calendar_month_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Item Type | Sevak Name (hidden for purchase) ──
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    'Item Type',
                    item['type'],
                    Icons.inventory_2_outlined,
                  ),
                ),
                if (!isPurchaseType) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDetailTile(
                      'Sevak Name',
                      item['sevakName'],
                      Icons.person_outline_rounded,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // ── Sevak No | Item To ────────────────────────────
            Row(
              children: [
                if (!isPurchaseType) ...[
                  Expanded(
                    child: _buildDetailTile(
                      'Sevak No',
                      item['sevakNo'],
                      Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: _buildDetailTile(
                    'Item To',
                    item['itemTo'],
                    isAdd
                        ? Icons.add_circle_outline_rounded
                        : Icons.remove_circle_outline_rounded,
                    valueColor: badgeColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Expiry badge (right-aligned) ──────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: kOrangeLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "Expiry: ${_formatExpiryDate(item['expiryDate'])}",
                  style: GoogleFonts.poppins(
                    color: kOrange,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Detail tile ─────────────────────────────────────────────────────────────
  Widget _buildDetailTile(
      String label,
      dynamic value,
      IconData icon, {
        Color? valueColor,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kTileBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: kTextSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value?.toString().isNotEmpty == true
                      ? value.toString()
                      : '—',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Highlight badge ─────────────────────────────────────────────────────────
  Widget _buildHighlightBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kOrangeLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFD8C8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kOrange),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: kOrange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Expiry date formatter ───────────────────────────────────────────────────
  String _formatExpiryDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'N/A';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(value.toString()));
    } catch (_) {
      return value.toString();
    }
  }

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState(String message) {
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
                Icons.inventory_2_outlined,
                color: kOrange,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
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
}