import 'dart:convert';

import 'package:get/get.dart';
import 'package:klitchen_stock/ui/models/items/filterItems.dart';

import '../../api/api.dart';

class FilteredItemsController extends GetxController {
  var items = [].obs;
  RxList<FilterItem> filteredItems = <FilterItem>[].obs;

  Future<void> fetchFilteredItems(int categoryId) async {
    var response = await Api.getFilteredItems(categoryId);
    if (response != null && response['data'] != null) {
      items.assignAll(response['data']);
    }
  }

  Future<void> GetFilteredItems(dynamic categoryId) async {
    print("Fetching items for categoryId: $categoryId"); // Debug log

    try {
      Map data = await Api.getFilteredItems(categoryId);
      print("API Response: $data"); // Print API response for debugging

      if (data["data"] is List) {
        filteredItems.assignAll(
          data["data"].map<FilterItem>((item) => FilterItem.fromJson(item)).toList(),
        );
        update(); // ✅ Forces UI to refresh
      } else {
        print("Error: Expected a list but got ${data["data"].runtimeType}");
      }
    } catch (e) {
      print("Error fetching filtered items: $e");
    }
  }



  // Method to get total quantity for a specific itemId
  int getTotalQuantityForItemId(int itemId) {
    return filteredItems.where((item) => item.itemId == itemId).fold(0, (sum, item) {
      int qty = int.tryParse(item.qty?.toString() ?? '0') ?? 0;
      return sum + qty;
    });
  }


}
