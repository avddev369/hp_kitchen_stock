
import 'package:klitchen_stock/api/api.dart';

import '../models/items/items.dart';

class ItemController {
  // Fetch filtered items from the API and return as List<Item>
  static Future<List<Item>> getFilteredItems(int categoryId) async {
    try {
      final response = await Api.getFilteredItems(categoryId);
      List<Item> items = [];
      if (response['data'] != null) {
        for (var itemData in response['data']) {
          items.add(Item.fromJson(itemData));
        }
      }
      return items;
    } catch (e) {
      throw Exception('Failed to load items: $e');
    }
  }

// Fetch item details based on itemId
  static Future<Item> getItemDetails(String itemId) async {
    try {
      // Convert itemId (String) to int
      int? parsedItemId = int.tryParse(itemId);

      // Check if the conversion was successful
      if (parsedItemId == null) {
        throw Exception('Invalid item ID: $itemId');
      }

      // Now pass the integer itemId to the API
      final response = await Api.getItemDetails(parsedItemId);

      if (response != null && response['data'] != null) {
        return Item.fromJson(response['data']);
      } else {
        throw Exception('Item not found');
      }
    } catch (e) {
      throw Exception('Failed to load item details: $e');
    }
  }

}
