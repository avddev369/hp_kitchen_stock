import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:klitchen_stock/api/api.dart';
import 'package:klitchen_stock/ui/controllers/filterItemsController.dart'
    show FilteredItemsController;
import 'package:klitchen_stock/ui/models/items/filterItems.dart';
import 'package:klitchen_stock/ui/views/showitemsDetails.dart'
    show ItemDetailScreen;
import 'package:klitchen_stock/widgets/customAlertDialog.dart';
import '../../widgets/addDialogbox.dart';
import '../../utils/search_utils.dart';

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

    return _fc.filteredItems.where((item) {
      return matchesSearchQuery(_searchQuery, [
        item.engName,
        item.gujName,
        item.location,
        item.unit,
        item.qty.toString(),
      ]);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddCategoryItemDialog,
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        tooltip: 'Add item in this category',
        child: const Icon(Icons.add_rounded),
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
    final godownStock = _fc.filteredItems
        .where((candidate) => candidate.itemId == item.itemId)
        .where((candidate) => candidate.location.trim().isNotEmpty)
        .fold<Map<String, num>>({}, (stock, candidate) {
          final location = _normalizeGodownKey(candidate.location);
          stock[location] = (stock[location] ?? 0) + candidate.qty;
          return stock;
        });

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
                        final didUpdate = await showAddItemDialog(
                          context,
                          item.itemId,
                          item.categoryId,
                          widget.categoryName ?? '',
                          item.engName,
                        );
                        if (didUpdate == true && mounted) {
                          await getItems();
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildActionButton(
                      label: 'Use',
                      icon: Icons.remove_rounded,
                      onTap: () async {
                        final didUpdate = await showRemoveItemDialog(
                          context,
                          item.itemId,
                          item.categoryId,
                          widget.categoryName ?? '',
                          item.engName,
                          item.unit,
                          godownStock,
                        );
                        if (didUpdate == true && mounted) {
                          await getItems();
                        }
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

  Future<void> _openAddCategoryItemDialog() async {
    final itemFormKey = GlobalKey<FormState>();
    final engNameController = TextEditingController();
    final gujNameController = TextEditingController();
    String? selectedUnit;
    bool isSubmitting = false;

    const units = [
      'Kg',
      'gm',
      'mg',
      'Liter',
      'ml',
      'Piece',
      'Dozen',
      'Packet',
      'Box',
      'Set',
      'Pair',
      'Meter',
      'Yard',
      'Foot',
      'Inch',
      'Bundle',
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final viewInsets = MediaQuery.of(dialogContext).viewInsets;
        final size = MediaQuery.of(dialogContext).size;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.fromLTRB(16, 24, 16, viewInsets.bottom + 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 440,
                    maxHeight: size.height * 0.9,
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.add_box_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add New Item',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Create item in this category',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IgnorePointer(
                            ignoring: isSubmitting,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                              child: Form(
                                key: itemFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel('Category'),
                                    _readOnlyField(widget.categoryName ?? ''),
                                    const SizedBox(height: 14),
                                    _dialogLabel('Item Name (English)'),
                                    _formField(
                                      engNameController,
                                      'e.g. Tomato',
                                      'Enter English name',
                                    ),
                                    const SizedBox(height: 14),
                                    _dialogLabel('Item Name (Gujarati)'),
                                    _formField(
                                      gujNameController,
                                      'e.g. ટામેટા',
                                      'Enter Gujarati name',
                                    ),
                                    const SizedBox(height: 14),
                                    _dialogLabel('Unit'),
                                    DropdownButtonFormField2<String>(
                                      value: selectedUnit,
                                      isExpanded: true,
                                      decoration: _dropdownDecoration(
                                        'Select unit',
                                      ),
                                      items: units
                                          .map(
                                            (unit) => DropdownMenuItem(
                                              value: unit,
                                              child: Text(
                                                unit,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: isSubmitting
                                          ? null
                                          : (value) => setDialogState(
                                              () => selectedUnit = value,
                                            ),
                                      validator: (value) => value == null
                                          ? 'Please select a unit'
                                          : null,
                                      dropdownStyleData: DropdownStyleData(
                                        maxHeight: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () => Navigator.pop(dialogContext),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: kBorder),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        color: kTextSecondary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kOrange,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (isSubmitting) {
                                        return;
                                      }
                                      if (!itemFormKey.currentState!
                                          .validate()) {
                                        return;
                                      }

                                      setDialogState(() {
                                        isSubmitting = true;
                                      });

                                      try {
                                        final result = await Api.addItem(
                                          widget.categoryId.toString(),
                                          engNameController.text,
                                          gujNameController.text,
                                          selectedUnit ?? '',
                                        );

                                        if (result['errorStatus'] == false) {
                                          if (!mounted) return;
                                          Navigator.pop(dialogContext);
                                          await getItems();
                                          if (!mounted) return;
                                          CustomAlertDialog.showSuccessDialog(
                                            context,
                                            'Item added successfully!',
                                          );
                                        } else {
                                          throw Exception('Failed to add item');
                                        }
                                      } catch (_) {
                                        setDialogState(() {
                                          isSubmitting = false;
                                        });
                                        if (!mounted) return;
                                        CustomAlertDialog.showErrorDialog(
                                          context,
                                          'Failed to add item.',
                                        );
                                      }
                                    },
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Add Item',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kTextSecondary,
        ),
      ),
    );
  }

  Widget _readOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: kTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _formField(
    TextEditingController controller,
    String hint,
    String validatorText,
  ) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 13, color: kTextPrimary),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorText;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: kTextSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kOrange, width: 1.4),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: kTextSecondary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kOrange, width: 1.4),
      ),
    );
  }
}

String _normalizeGodownKey(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
