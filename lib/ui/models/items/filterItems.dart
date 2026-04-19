class FilterItem {
  final int itemId;
  final String engName;
  final String gujName;
  final int qty;
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

  /// Factory method to create an `Item` object from JSON.
  factory FilterItem.fromJson(Map<String, dynamic> json) {
    return FilterItem(
      itemId: json['itemId'] ,
      engName: json['engName'] as String,
      gujName: json['gujName'] as String,
      qty: json['qty'] ?? 0,
      location: json['location'] ?? "",
      categoryId: json['categoryId'] ,
      unit: json['unit'] ,
      createdBy: json['createdBy'] ,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
