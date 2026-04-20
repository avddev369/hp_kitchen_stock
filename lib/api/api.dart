import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:klitchen_stock/helper/preferences.dart';
import 'package:klitchen_stock/utils/api_urls.dart';
import 'dart:developer' as log;
class Api {
  static Dio? client;

  // Initialize Dio client
  static Future<void> clientInstance() async {
    if (client == null) {
      client = Dio();

      client!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.contains('http')) {
            options.path = Urls.mainDomain + options.path;
          }

          // Attach Authorization token to headers if it exists
          String? token = await Preferences.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioError error, handler) async {
          if ((error.response?.statusCode == 401 &&
              error.response?.data['message'] == "Invalid JWT")) {
            // Handle JWT expiration or invalid token logic here if needed
            // For example, trigger a refresh token request or logout the user
            // You can call Preferences.removeToken() to log the user out
          }
          return handler.next(error);
        },
      ));
    }
  }

  // Login API method
  static Future<Map<String, dynamic>> login(
      String username, String password, BuildContext context) async {
    try {
      final Uri url = Uri.parse('http://27.116.52.24:8060/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': username,
          'password': password,
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['errorStatus'] == false) {
          final Map<String, dynamic> userData = responseData['data'];

          if (userData.containsKey('token') && userData['token'] != null) {
            String token = userData['token'];
            String name = userData['name'] ?? 'Unknown';

            await Preferences.saveToken(token);
            await Preferences.saveUserName(name);

            return {
              'success': true,
              'data': {
                'token': token,
                'name': name,
              },
            };
          } else {
            return {'success': false, 'msg': 'Login failed: No token received.'};
          }
        } else {
          return {'success': false, 'msg': responseData['msg'] ?? 'Unknown error'};
        }
      } else {
        return {'success': false, 'msg': 'Server error. Please try again.'};
      }
    } catch (error) {
      print("Login Error: $error");
      return {'success': false, 'msg': 'Error during login: $error'};
    }
  }


  static Future<Map<String, dynamic>> getItems() async {
    try {
      // The data to be sent in the body
      var requestBody = {
        "table": "category", // Add this to the request body
      };

      final response = await client!.post(
        'http://27.116.52.24:8060/getData/', // The URL of the API
        data: requestBody, // Sending the body with the request
      );

      // Print the raw response data for debugging
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;

        // If the "errorStatus" is false, return the data
        if (responseData['errorStatus'] == false) {
          return {
            'errorStatus': false,
            'data': responseData['data'],
          };
        } else {
          throw Exception('Error occurred: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load items. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error occurred during request: $error');
    }
  }
  // Additional methods for other API calls can go here


  static Future<Map<String, dynamic>> getFilteredItems(int categoryId) async {
    try {
      var requestBody = {
        "table": "item",
        "filters": {"categoryId": categoryId}
      };

      final response = await client!.post(
        'http://27.116.52.24:8060/getData',
        data: requestBody,
      );

      print('Filtered Items Response Data: ${response.data}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        log.log('Filtered Items Data: ${responseData['data']}');

        if (responseData['errorStatus'] == false) {
          return {
            'errorStatus': false,
            'data': responseData['data'],
          };
        } else {
          throw Exception('Error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load filtered items. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during getFilteredItems: $error');
      throw Exception('Error occurred during request: $error');
    }
  }


  static Future<Map<String, dynamic>> getItemDetails(int itemId) async {
    try {
      final response = await http.post(
        Uri.parse('http://27.116.52.24:8060/getManageItemsByItemId'),
        body: json.encode({"itemId": itemId}),
        headers: {'Content-Type': 'application/json'},
      );

      print('Item Details Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Item Details Data: $data');
        return data;
      } else {
        throw Exception('Failed to load item details');
      }
    } catch (error) {
      print('Error during getItemDetails: $error');
      throw Exception('Error occurred during request: $error');
    }
  }

  static Future<List<dynamic>> searchItems(String keyword) async {
    final url = Uri.parse("http://27.116.52.24:8060/search");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"keyword": keyword}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['items']);

        return data['items'] ?? [];

      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  static Future<Map<String, dynamic>> addItem(String categoryId, String engName, String gujName, String unit, String location) async {
    String? username = await Preferences.getUserName();

    try {
      var requestBody = {
        "table": "item",
        "categoryId": int.parse(categoryId),  // Ensure categoryId is an integer
        "engName": engName,
        "gujName": gujName,
        "unit": unit,
        "location": location,
        "createdBy": username
      };

      final response = await http.post(
        Uri.parse('http://27.116.52.24:8060/insertData'), // API URL for adding item
        headers: {
          'Content-Type': 'application/json', // Ensure correct content type
        },
        body: json.encode(requestBody), // Encode the body to JSON
      );

      print("RESP INSEERT ${response}");

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body); // Decode the response body

        if (responseData['errorStatus'] == false) {
          return {
            'errorStatus': false,
            'data': responseData['data'],
          };
        } else {
          throw Exception('Error occurred: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to add item. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error occurred during adding item: $error');
    }
  }

  static Future<Map<String, dynamic>> addCategory(
      String engName, String gujName) async {
    String? username = await Preferences.getUserName();

    try {
      var requestBody = {
        "table": "category",
        "engName": engName,
        "gujName": gujName,
        "createdBy": username,
      };

      final response = await http.post(
        Uri.parse('http://27.116.52.24:8060/insertData'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['errorStatus'] == false) {
          return {
            'errorStatus': false,
            'data': responseData['data'],
          };
        } else {
          throw Exception('Error occurred: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Failed to add category. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error occurred during adding category: $error');
    }
  }

}






