import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api/api.dart';
import 'utils/api_urls.dart';

class ItemProvider with ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  bool _isFetched = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading; // Ensure this getter is present

  List<Map<String, dynamic>> get items => _items;

  Future<void> fetchItems({bool forceRefresh = false}) async {
    if (_isFetched && !forceRefresh) return; // Skip if already fetched

    _isLoading = true;
    notifyListeners();
    final url = Urls.endpoint('/getManageItems');
    Api.logApiHit('POST', url, source: 'ItemProvider');
    Api.logRequestBody(url, null, source: 'ItemProvider');
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (!jsonResponse["errorStatus"]) {
        _items = [
          ...List<Map<String, dynamic>>.from(jsonResponse["data"]["add"] ?? []),
          ...List<Map<String, dynamic>>.from(
            jsonResponse["data"]["remove"] ?? [],
          ),
        ];
        _isFetched = true;
      }
    }
    _isLoading = false;
    notifyListeners(); // Update UI
  }
}
