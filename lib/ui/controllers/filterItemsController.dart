import 'package:get/get.dart';
import 'package:klitchen_stock/ui/models/items/filterItems.dart';

import '../../api/api.dart';

class FilteredItemsController extends GetxController {
  var items = [].obs;
  RxList<FilterItem> filteredItems = <FilterItem>[].obs;

  Future<void> fetchFilteredItems(int categoryId) async {
    var response = await Api.getFilteredItems(categoryId);
    if (response['data'] != null) {
      items.assignAll(response['data']);
    }
  }

  Future<void> GetFilteredItems(dynamic categoryId) async {
    print("Fetching items for categoryId: $categoryId"); // Debug log

    try {
      Map data = await Api.getFilteredItems(categoryId);
      print("API Response: $data"); // Print API response for debugging

      if (data["data"] is List) {
        final List<FilterItem> items = (data["data"] as List)
            .map<FilterItem>((item) => FilterItem.fromJson(item))
            .toList();
        items.sort(
          (FilterItem a, FilterItem b) => b.createdAt.compareTo(a.createdAt),
        );
        filteredItems.assignAll(items);
        update(); // ✅ Forces UI to refresh
      } else {
        print("Error: Expected a list but got ${data["data"].runtimeType}");
      }
    } catch (e) {
      print("Error fetching filtered items: $e");
    }
  }

  // Method to get total quantity for a specific itemId
  double getTotalQuantityForItemId(int itemId) {
    return filteredItems.where((item) => item.itemId == itemId).fold(0.0, (
      sum,
      item,
    ) {
      return sum + item.qty;
    });
  }
}
