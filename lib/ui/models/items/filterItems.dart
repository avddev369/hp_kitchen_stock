class FilterItem {
  final int itemId;
  final String engName;
  final String gujName;
  final double qty;
  final String location;
  final int categoryId;
  final String unit;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FilterItem({
    required this.itemId,
    required this.engName,
    required this.gujName,
    required this.qty,
    required this.location,
    required this.categoryId,
    required this.unit,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static double _parseQty(dynamic rawQty) {
    if (rawQty == null) return 0;
    if (rawQty is num) return rawQty.toDouble();
    return double.tryParse(rawQty.toString().trim()) ?? 0;
  }

  /// Factory method to create an `Item` object from JSON.
  factory FilterItem.fromJson(Map<String, dynamic> json) {
    final createdAt =
        DateTime.tryParse(
          (json['createdAt'] ?? json['date'] ?? '').toString(),
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final updatedAt =
        DateTime.tryParse(
          (json['updatedAt'] ?? json['createdAt'] ?? json['date'] ?? '')
              .toString(),
        ) ??
        createdAt;

    return FilterItem(
      itemId: int.tryParse(json['itemId']?.toString() ?? '') ?? 0,
      engName: (json['engName'] ?? json['itemName'] ?? '').toString(),
      gujName: (json['gujName'] ?? '').toString(),
      qty: _parseQty(json['qty']),
      location: (json['location'] ?? "").toString(),
      categoryId: int.tryParse(json['categoryId']?.toString() ?? '') ?? 0,
      unit: (json['unit'] ?? '').toString(),
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts an `Item` object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'engName': engName,
      'gujName': gujName,
      'qty': qty,
      'location': location,
      'categoryId': categoryId,
      'unit': unit,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
