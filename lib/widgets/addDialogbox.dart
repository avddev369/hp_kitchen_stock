import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:klitchen_stock/ui/controllers/filterItemsController.dart';
import '../api/api.dart';
import '../utils/api_urls.dart';

// ─── Shared colours ───────────────────────────────────────────────────────────
const Color _kOrange = Color(0xFFFF6B35);
const Color _kOrangeLight = Color(0xFFFFF0EA);
const Color _kBorder = Color(0xFFEEEFF4);
const Color _kBg = Color(0xFFF7F8FA);
const Color _kTextPrimary = Color(0xFF1A1D23);
const Color _kTextSecondary = Color(0xFF9599B0);

// ─── Add Item Screen ───────────────────────────────────────────────────────────
class AddItemScreen extends StatefulWidget {
  final int itemId;
  final int categoryId;
  final String categoryName;
  final String itemName;
  final String itemUnit;

  const AddItemScreen({
    Key? key,
    required this.itemId,
    required this.categoryId,
    required this.categoryName,
    required this.itemName,
    required this.itemUnit,
  }) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final FilteredItemsController _fc = Get.find<FilteredItemsController>();

  final _quantityController = TextEditingController();
  final _sevakNameController = TextEditingController();
  final _sevakNoController = TextEditingController();
  final _expiryController = TextEditingController();

  String? _selectedType;
  LocationOption? _selectedGodown;
  bool _showSevakFields = false;
  bool _loadingGodowns = true;
  bool _submitting = false;
  List<LocationOption> _godownOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchGodowns();
  }

  Future<void> _fetchGodowns() async {
    try {
      _godownOptions = await Api.getGodownLocations();
    } catch (_) {
      _godownOptions = [];
    }
    if (mounted) setState(() => _loadingGodowns = false);
  }

  void _showSnack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submit() async {
    final qtyText = _quantityController.text.trim();
    final enteredQty = double.tryParse(qtyText);
    if (qtyText.isEmpty || enteredQty == null || enteredQty <= 0) {
      _showSnack('Quantity must be a positive number!');
      return;
    }
    if (_selectedType == null) {
      _showSnack('Please select a Type!');
      return;
    }
    if (_selectedGodown == null) {
      _showSnack('Please select a Godown!');
      return;
    }
    if (_selectedType == 'Seva') {
      if (_sevakNameController.text.trim().isEmpty ||
          _sevakNoController.text.trim().isEmpty) {
        _showSnack('Sevak Name and Number are required for Seva!');
        return;
      }
      if (!RegExp(r'^\d{10}$').hasMatch(_sevakNoController.text.trim())) {
        _showSnack('Sevak No must be exactly 10 digits!');
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final body = {
        'itemId': widget.itemId,
        'type': _selectedType!,
        'sevakName': _showSevakFields ? _sevakNameController.text.trim() : '',
        'sevakNo': _showSevakFields ? _sevakNoController.text.trim() : '',
        'itemTo': 'Add',
        'expiryDate': _expiryController.text.trim(),
        'createdBy': 1,
        'locations': [
          {'locationId': _selectedGodown!.id, 'qty': enteredQty},
        ],
      };
      final url = Urls.endpoint('/insertItemToMultipleLocations');
      Api.logApiHit('POST', url, source: 'AddItemDialog');
      Api.logRequestBody(url, body, source: 'AddItemDialog');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print('Add item response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['errorStatus'] == false) {
          _showSnack('Item added successfully!', error: false);
          await Future.delayed(const Duration(milliseconds: 1200));
          await _fc.GetFilteredItems(widget.categoryId);
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          _showSnack(
            responseData['message']?.toString() ?? 'Failed to add item',
          );
        }
      } else {
        _showSnack('Failed to add item: ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _sevakNameController.dispose();
    _sevakNoController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Item',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            Text(
              widget.categoryName,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: _kTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ItemInfoBanner(itemName: widget.itemName),
                    const SizedBox(height: 14),
                    _SectionCard(
                      children: [
                        _FormField(
                          label: 'Item Name',
                          child: _readonlyField(widget.itemName),
                        ),
                        const SizedBox(height: 12),
                        _FormField(
                          label: 'Quantity',
                          child: _inputField(
                            controller: _quantityController,
                            hint: 'Enter quantity',
                            inputType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,3}$'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FormField(
                          label: 'Qty Unit',
                          child: _readonlyField(widget.itemUnit),
                        ),
                        const SizedBox(height: 12),
                        _FormField(
                          label: 'Expiry Date',
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                                builder: (ctx, child) => Theme(
                                  data: Theme.of(ctx).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: _kOrange,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setState(
                                  () => _expiryController.text = picked
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                                );
                              }
                            },
                            child: AbsorbPointer(
                              child: _inputField(
                                controller: _expiryController,
                                hint: 'Select date',
                                suffixIcon: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: _kTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      children: [
                        _FormField(
                          label: 'Type',
                          child: _dropdownField(
                            hint: 'Select type',
                            value: _selectedType,
                            items: const ['Purchase', 'Seva'],
                            onChanged: (v) => setState(() {
                              _selectedType = v;
                              _showSevakFields = v == 'Seva';
                            }),
                          ),
                        ),
                        if (_showSevakFields) ...[
                          const SizedBox(height: 12),
                          _FormField(
                            label: 'Sevak Name',
                            child: _inputField(
                              controller: _sevakNameController,
                              hint: 'Enter sevak name',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FormField(
                            label: 'Sevak No',
                            child: _inputField(
                              controller: _sevakNoController,
                              hint: '10-digit mobile number',
                              inputType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      children: [
                        _FormField(
                          label: 'Godown',
                          child: _loadingGodowns
                              ? const _GodownLoader()
                              : _godownOptions.isEmpty
                              ? _noGodownText()
                              : _locationDropdownField(
                                  hint: 'Select godown',
                                  value: _selectedGodown,
                                  items: _godownOptions,
                                  onChanged: (v) =>
                                      setState(() => _selectedGodown = v),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        label: 'Add Item',
        color: _kOrange,
        submitting: _submitting,
        onTap: _submit,
      ),
    );
  }
}

// ─── Remove Item Screen ────────────────────────────────────────────────────────
class RemoveItemScreen extends StatefulWidget {
  final int itemId;
  final int categoryId;
  final String categoryName;
  final String itemName;
  final String itemUnit;
  final Map<String, num>? godownStock;

  const RemoveItemScreen({
    Key? key,
    required this.itemId,
    required this.categoryId,
    required this.categoryName,
    required this.itemName,
    required this.itemUnit,
    this.godownStock,
  }) : super(key: key);

  @override
  State<RemoveItemScreen> createState() => _RemoveItemScreenState();
}

class _RemoveItemScreenState extends State<RemoveItemScreen> {
  final FilteredItemsController _fc = Get.find<FilteredItemsController>();

  final _quantityController = TextEditingController();
  LocationOption? _selectedGodown;
  String? _selectedUnit;
  bool _loadingGodowns = true;
  bool _submitting = false;
  List<LocationOption> _godownOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchGodowns();
  }

  Future<void> _fetchGodowns() async {
    try {
      _godownOptions = await Api.getGodownLocations(itemId: widget.itemId);
      if (_godownOptions.isNotEmpty) {
        _selectedGodown = _godownOptions.first;
      }
    } catch (_) {
      _godownOptions = [];
    }
    final compatibleUnits = _compatibleUnitsFor(widget.itemUnit);
    _selectedUnit = compatibleUnits.firstWhere(
      (unit) => _normalizeUnitKey(unit) == _normalizeUnitKey(widget.itemUnit),
      orElse: () => compatibleUnits.first,
    );
    if (mounted) setState(() => _loadingGodowns = false);
  }

  void _showSnack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  double _stockForSelectedGodown() {
    if (_selectedGodown == null) return 0;
    final apiQty = _selectedGodown!.availableQty;
    if (apiQty != null) return apiQty;
    final godownName = _selectedGodown!.name;
    return _stockLookup(widget.godownStock, godownName);
  }

  Future<void> _submit() async {
    final qtyText = _quantityController.text.trim();
    final enteredQty = double.tryParse(qtyText);
    if (qtyText.isEmpty || enteredQty == null || enteredQty <= 0) {
      _showSnack('Quantity must be a positive number!');
      return;
    }
    if (_selectedGodown == null) {
      _showSnack('Please select a Godown!');
      return;
    }
    if (_selectedUnit == null) {
      _showSnack('Please select a unit!');
      return;
    }

    final stockForGodown = _stockForSelectedGodown();
    final convertedQty = _convertQuantity(
      quantity: enteredQty,
      fromUnit: _selectedUnit!,
      toUnit: widget.itemUnit,
    );

    if (convertedQty == null) {
      _showSnack('Selected unit cannot be converted to ${widget.itemUnit}.');
      return;
    }

    if (convertedQty > stockForGodown) {
      _showSnack(
        'Only ${_formatQuantity(stockForGodown)} ${widget.itemUnit} is available in ${_selectedGodown!.name}.',
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final body = {
        'itemId': widget.itemId,
        'type': 'Used',
        'sevakName': '',
        'sevakNo': '',
        'itemTo': 'Remove',
        // 'expiryDate': '',
        'createdBy': 1,
        'locations': [
          {
            'locationId': _selectedGodown!.id,
            'qty': _normalizeQuantity(convertedQty),
          },
        ],
      };
      final url = Urls.endpoint('/insertItemToMultipleLocations');
      Api.logApiHit('POST', url, source: 'RemoveItemDialog');
      Api.logRequestBody(url, body, source: 'RemoveItemDialog');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print('Remove item response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['errorStatus'] == false) {
          _showSnack('Item removed successfully!', error: false);
          await Future.delayed(const Duration(milliseconds: 1200));
          await _fc.GetFilteredItems(widget.categoryId);
          if (mounted) Navigator.pop(context, true);
        } else {
          _showSnack(
            responseData['message']?.toString() ?? 'Failed to remove item',
          );
        }
      } else {
        _showSnack('Failed to remove item: ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Use Item',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            Text(
              widget.categoryName,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: _kTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ItemInfoBanner(itemName: widget.itemName, isRemove: true),
              const SizedBox(height: 14),
              _SectionCard(
                children: [
                  _FormField(
                    label: 'Item Name',
                    child: _readonlyField(widget.itemName),
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Quantity',
                    child: _inputField(
                      controller: _quantityController,
                      hint: 'Enter quantity',
                      inputType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,3}$'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Qty Unit',
                    child: _readonlyField(_selectedUnit ?? widget.itemUnit),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                children: [
                  _FormField(
                    label: 'Godown',
                    child: _loadingGodowns
                        ? const _GodownLoader()
                        : _godownOptions.isEmpty
                        ? _noGodownText()
                        : _locationDropdownField(
                            hint: 'Select godown',
                            value: _selectedGodown,
                            items: _godownOptions,
                            onChanged: (v) =>
                                setState(() => _selectedGodown = v),
                          ),
                  ),
                ],
              ),
              if (_selectedGodown != null) ...[
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    _FormField(
                      label: 'Available Stock',
                      child: _readonlyField(
                        '${_formatQuantity(_stockForSelectedGodown())} ${widget.itemUnit}',
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        label: 'Confirm Use',
        color: const Color(0xFFE53935),
        submitting: _submitting,
        onTap: _submit,
      ),
    );
  }
}

double _stockLookup(Map<String, num>? godownStock, String godownName) {
  final key = _normalizeGodownKey(godownName);
  return godownStock?[key]?.toDouble() ?? 0;
}

String _normalizeGodownKey(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

// ─── Shared Widgets ────────────────────────────────────────────────────────────

class _ItemInfoBanner extends StatelessWidget {
  final String itemName;
  final bool isRemove;
  const _ItemInfoBanner({required this.itemName, this.isRemove = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isRemove ? const Color(0xFFFFEBEE) : _kOrangeLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isRemove
                  ? const Color(0xFFFFCDD2)
                  : const Color(0xFFFFD8C8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isRemove
                  ? Icons.remove_circle_outline_rounded
                  : Icons.add_circle_outline_rounded,
              color: isRemove ? const Color(0xFFE53935) : _kOrange,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              itemName,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _kTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _GodownLoader extends StatelessWidget {
  const _GodownLoader();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: _kOrange),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String label;
  final Color color;
  final bool submitting;
  final VoidCallback onTap;
  const _BottomBar({
    required this.label,
    required this.color,
    required this.submitting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: submitting ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withOpacity(0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _readonlyField(String value) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    decoration: BoxDecoration(
      color: _kOrangeLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFFD8C8)),
    ),
    child: Text(
      value,
      style: GoogleFonts.poppins(
        fontSize: 13.5,
        color: _kTextPrimary,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget _inputField({
  required TextEditingController controller,
  required String hint,
  TextInputType inputType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffixIcon,
}) {
  return TextField(
    controller: controller,
    keyboardType: inputType,
    textInputAction: TextInputAction.done,
    inputFormatters: inputFormatters,
    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    style: GoogleFonts.poppins(fontSize: 13.5, color: _kTextPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: _kTextSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kOrange, width: 1.5),
      ),
    ),
  );
}

Widget _dropdownField({
  required String hint,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    hint: Text(
      hint,
      style: GoogleFonts.poppins(fontSize: 13, color: _kTextSecondary),
    ),
    onChanged: onChanged,
    items: items
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: GoogleFonts.poppins(fontSize: 13.5)),
          ),
        )
        .toList(),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kOrange, width: 1.5),
      ),
    ),
    dropdownColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    isExpanded: true,
    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kTextSecondary),
  );
}

Widget _locationDropdownField({
  required String hint,
  required LocationOption? value,
  required List<LocationOption> items,
  required ValueChanged<LocationOption?> onChanged,
}) {
  return DropdownButtonFormField<LocationOption>(
    value: value,
    hint: Text(
      hint,
      style: GoogleFonts.poppins(fontSize: 13, color: _kTextSecondary),
    ),
    onChanged: onChanged,
    items: items
        .map(
          (e) => DropdownMenuItem<LocationOption>(
            value: e,
            child: Text(e.name, style: GoogleFonts.poppins(fontSize: 13.5)),
          ),
        )
        .toList(),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kOrange, width: 1.5),
      ),
    ),
    dropdownColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    isExpanded: true,
    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kTextSecondary),
  );
}

Widget _noGodownText() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      'No godown found. Please add godown in location table.',
      style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
    ),
  );
}

// ─── Legacy stubs (kept so other files that import them don't break) ───────────
Future<bool?> showAddItemDialog(
  BuildContext context,
  int itemId,
  int categoryId,
  String categoryName,
  String itemName,
  String itemUnit,
) async {
  return Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => AddItemScreen(
        itemId: itemId,
        categoryId: categoryId,
        categoryName: categoryName,
        itemName: itemName,
        itemUnit: itemUnit,
      ),
    ),
  );
}

Future<bool?> showRemoveItemDialog(
  BuildContext context,
  int itemId,
  int categoryId,
  String categoryName,
  String itemName,
  String itemUnit,
  Map<String, num>? godownStock,
) async {
  return Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => RemoveItemScreen(
        itemId: itemId,
        categoryId: categoryId,
        categoryName: categoryName,
        itemName: itemName,
        itemUnit: itemUnit,
        godownStock: godownStock,
      ),
    ),
  );
}

List<String> _compatibleUnitsFor(String unit) {
  final normalizedUnit = unit.trim().toLowerCase();
  const groups = [
    ['kg', 'gm'],
    ['ltr', 'ml'],
  ];

  for (final group in groups) {
    if (group.contains(normalizedUnit)) {
      return group;
    }
  }

  return [unit];
}

double? _convertQuantity({
  required double quantity,
  required String fromUnit,
  required String toUnit,
}) {
  final from = fromUnit.trim().toLowerCase();
  final to = toUnit.trim().toLowerCase();

  if (from == to) return quantity;

  const conversionToBase = {'kg': 1000.0, 'gm': 1.0, 'ltr': 1000.0, 'ml': 1.0};

  if (!conversionToBase.containsKey(from) ||
      !conversionToBase.containsKey(to)) {
    return null;
  }

  final sameFamily =
      (['kg', 'gm'].contains(from) && ['kg', 'gm'].contains(to)) ||
      (['ltr', 'ml'].contains(from) && ['ltr', 'ml'].contains(to));
  if (!sameFamily) return null;

  final quantityInBase = quantity * conversionToBase[from]!;
  return quantityInBase / conversionToBase[to]!;
}

dynamic _normalizeQuantity(double value) {
  final rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.000001) {
    return rounded.toInt();
  }
  return double.parse(value.toStringAsFixed(3));
}

String _formatQuantity(num value) {
  final asDouble = value.toDouble();
  final rounded = asDouble.roundToDouble();
  if ((asDouble - rounded).abs() < 0.000001) {
    return rounded.toInt().toString();
  }
  return asDouble.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
}

String _normalizeUnitKey(String value) {
  return value.trim().toLowerCase();
}
