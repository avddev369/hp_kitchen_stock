class Item {
  final String itemId;
  final String engName;
  final String qty;
  final String unit;
  final String location;

  Item({
    required this.itemId,
    required this.engName,
    required this.qty,
    required this.unit,
    required this.location,
  });

  // Factory method to create an Item from JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['itemId'] ?? '', // Default to an empty string if null
      engName: json['engName'] ?? '',
      qty: json['qty'] ?? '',
      unit: json['unit'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
