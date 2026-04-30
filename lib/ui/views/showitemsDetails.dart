import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/api.dart'; // Import your API logic
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

  late Future<Map<String, dynamic>> futureItemDetails;
  TextEditingController searchController = TextEditingController();
  List<dynamic> allItems = [];
  List<dynamic> filteredItems = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    futureItemDetails = Api.getItemDetails(widget.itemId);
  }

  getItems() async {}

  void _searchItems(String query) {
    if (query.isEmpty) {
      setState(() => filteredItems = allItems);
      return;
    }

    setState(() {
      filteredItems = allItems.where((item) {
        String itemName = item['itemName']?.toString().toLowerCase() ?? '';
        String category = item['categoryName']?.toString().toLowerCase() ?? '';
        String location = item['location']?.toString().toLowerCase() ?? '';
        String sevakName = item['sevakName']?.toString().toLowerCase() ?? '';
        String itemTo = item['itemTo']?.toString().toLowerCase() ?? '';

        return itemName.contains(query.toLowerCase()) ||
            category.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase()) ||
            sevakName.contains(query.toLowerCase()) ||
            itemTo.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
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
                  filteredItems = allItems;
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
            filteredItems =
                filteredItems.isEmpty && searchController.text.isEmpty
                ? List.from(allItems)
                : filteredItems;

            if (filteredItems.isEmpty) {
              return _buildEmptyState(
                searchController.text.isEmpty
                    ? 'No details available for this item'
                    : 'No matching history found',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: filteredItems.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSummaryCard();
                }

                final item = filteredItems[index - 1];
                final itemTo = item['itemTo']?.toString().toLowerCase() ?? '';
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
                  searchController.text.isEmpty
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    );
  }

  Widget _buildHistoryCard(dynamic item, String itemTo) {
    final isAdd = itemTo == 'add';
    final badgeColor = isAdd
        ? const Color(0xFF22A45D)
        : const Color(0xFFE05050);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    'Category',
                    item['categoryName'],
                    Icons.category_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    'Quantity',
                    "${item['qty'] ?? ''} ${item['unit'] ?? ''}",
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
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    'Item Type',
                    item['type'],
                    Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailTile(
                    'Sevak Name',
                    item['sevakName'],
                    Icons.person_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    'Sevak No',
                    item['sevakNo'],
                    Icons.phone_outlined,
                  ),
                ),
                const SizedBox(width: 10),
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
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

  Widget _buildDetailTile(
    String title,
    dynamic value,
    IconData icon, {
    Color valueColor = kTextPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEEE4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: kOrangeLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: kOrange),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${value ?? 'N/A'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiryDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }

    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(value.toString()));
    } catch (_) {
      return value.toString();
    }
  }

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
