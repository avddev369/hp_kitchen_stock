import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klitchen_stock/ui/controllers/filterItemsController.dart';
import '../api/api.dart';
import '../helper/preferences.dart';


// 🔹 Common Dropdown Function
Widget buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
    ) {
  return StatefulBuilder(
    builder: (context, setState) {
      String? errorText;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: errorText == null
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.red, // Show red border on error
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: errorText == null
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.red, // Show red border if error
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              isExpanded: true,
              hint: Text(label),
              value: selectedValue,
              onChanged: (newValue) {
                setState(() {
                  selectedValue = newValue;
                  errorText = newValue == null ? "$label is required!" : null;
                });
                onChanged(newValue);
              },
              items: items.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (errorText != null) // Show error message only if there's an error
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    },
  );
}

// 🔹 Dialog for Adding Item






Future<void> showAddItemDialog(BuildContext context, int itemId, int categoryId, String categoryName, String itemName) async {
  FilteredItemsController _fc = Get.find<FilteredItemsController>();
  TextEditingController itemNameController = TextEditingController(text: itemName);
  TextEditingController quantityController = TextEditingController();
  TextEditingController sevakNameController = TextEditingController();
  TextEditingController sevakNoController = TextEditingController();
  TextEditingController ExpiryDateController = TextEditingController();

  String? selectedType;
  String? selectedGodown;
  bool showSevakFields = false;
  final List<String> godownOptions = [
    "HPYM Kothar",
    "AVD",
    "Sukun Cold Storage",
    "Amar Cold Storage"
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool isLoading = false; // Loading state

      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> addItem() async {
            setState(() => isLoading = true); // Show loader

            // Validation for Quantity
            String qtyText = quantityController.text.trim();
            if (qtyText.isEmpty || int.tryParse(qtyText) == null || int.parse(qtyText) <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Quantity must be a positive number!"),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => isLoading = false);
              return;
            }

            // Validation for Type selection
            if (selectedType == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select a Type!"),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => isLoading = false);
              return;
            }

            if (selectedGodown == null || selectedGodown!.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select a Godown!"),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => isLoading = false);
              return;
            }

            // Validation for Seva type
// Validation for Seva type
            if (selectedType == "Seva") {
              if (sevakNameController.text.trim().isEmpty || sevakNoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Sevak Name and Number are required for Seva!"),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() => isLoading = false);
                return;
              }

              // Validate Sevak No (should be exactly 10 digits)
              String sevakNo = sevakNoController.text.trim();
              if (!RegExp(r'^\d{10}$').hasMatch(sevakNo)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Sevak No must be exactly 10 digits!"),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() => isLoading = false);
                return;
              }
            }


            // Proceed with API call
            const String apiUrl = "http://27.116.52.24:8060/manageItem";
            String? username = await Preferences.getUserName();
            if (username == null || username.isEmpty) {
              throw Exception("Username is not available.");
            }

            int quantity = int.parse(qtyText);

            Map<String, dynamic> requestBody = {
              "table": "manage",
              "qty": quantity,
              "itemId": itemId,
              "type": selectedType!,
              "sevakName": showSevakFields ? sevakNameController.text.trim() : "",
              "sevakNo": showSevakFields ? sevakNoController.text.trim() : "",
              "location": selectedGodown,
              "itemTo": "Add",
              "expiryDate": ExpiryDateController.text.trim(),
              "createdBy": 1
            };

            try {
              final response = await http.post(
                Uri.parse(apiUrl),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(requestBody),
              );

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Item added successfully!"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                await Future.delayed(Duration(milliseconds: 1500)); // Delay for visibility
                await _fc.GetFilteredItems(categoryId);

                Navigator.pop(context); // Close dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to add item: ${response.statusCode}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (error) {
              print("ERROR: $error");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: $error"),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              setState(() => isLoading = false); // Hide loader
            }
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text(
              "Add New Item",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildHeader("Item Name"),
                    buildStyledTextField(
                      controller: itemNameController,
                      read: true,
                      isRequired: true,

                      label: "Item Name",
                    ),
                    _buildHeader("Quantity"),
                    buildStyledTextField(
                      controller: quantityController,
                      label: "Quantity",
                      isNumeric: true,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),

                    _buildHeader("Expiry Date"),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            ExpiryDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: buildStyledTextField(
                          controller: ExpiryDateController,
                          label: "",
                          isRequired: true,

                        ),
                      ),
                    ),

                    _buildHeader("Type"),
                    buildDropdown(
                      "Type",
                      ["Purchase", "Seva"],
                      selectedType,
                          (value) {
                        setState(() {
                          selectedType = value;
                          showSevakFields = value == "Seva";
                        });
                      },
                    ),
                    _buildHeader("Godown"),
                    buildDropdown(
                      "Godown",
                      godownOptions,
                      selectedGodown,
                      (value) {
                        setState(() {
                          selectedGodown = value;
                        });
                      },
                    ),
                    if (showSevakFields) ...[
                      buildStyledTextField(
                        controller: sevakNameController,
                        label: "Sevak Name",
                      ),
                      buildStyledTextField(
                        controller: sevakNoController,
                        label: "Sevak No",
                        keyboardType: TextInputType.phone,
                      ),
                    ],

                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                ),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : addItem,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Add"),
              ),
            ],
          );
        },
      );
    },
  );
}
Widget _buildHeader(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5, top: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto', // Using Roboto font
        color: Colors.black87,
      ),
    ),
  );
}
Widget buildStyledTextField({
  required TextEditingController controller,
  required String label,
  bool read = false, // Default: editable
  TextInputType keyboardType = TextInputType.text,
  bool isRequired = false, // Adds validation for required fields
  bool isNumeric = false, // Adds numeric validation
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      String? errorText;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              readOnly: read, // If true, make field non-editable
              keyboardType: keyboardType,
              style: TextStyle(
                color: Colors.black, // Uniform text color
              ),
              onChanged: (value) {
                // Validation logic
                setState(() {
                  if (isRequired && value.trim().isEmpty) {
                    errorText = "$label is required!";
                  } else if (isNumeric) {
                    int? number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      errorText = "$label must be a positive number!";
                    } else {
                      errorText = null; // Clear error if valid
                    }
                  } else {
                    errorText = null; // Clear error for non-numeric fields
                  }
                });
              },
              decoration: InputDecoration(
                labelText: label,
                filled: read, // Fill background when read-only
                fillColor: read ? Colors.orange[50] : Colors.white, // Light gray background
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: read ? Colors.grey : Colors.orange, // Grey border for read-only
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: read ? Colors.grey : Colors.deepOrange, // Grey border for read-only
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (errorText != null) // Show error only if there's an error
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    },
  );
}




// 🔹 Dialog for Removing Item
Future<void> showRemoveItemDialog(BuildContext context, int itemId,int categoryId, String categoryName,String itemName)async {
  FilteredItemsController _fc = Get.find<FilteredItemsController>();
  TextEditingController itemNameController = TextEditingController(text: "${itemName}",);
  TextEditingController quantityController = TextEditingController();
  TextEditingController sevakNameController = TextEditingController();
  TextEditingController sevakNoController = TextEditingController();
  TextEditingController ExpiryDateController = TextEditingController();



  String? selectedType;
  bool showSevakFields = false;


  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool isLoading = false; // Loading state

      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> removeItem() async {
            setState(() => isLoading = true); // Show loader

            // Validation for Quantity
            String qtyText = quantityController.text.trim();
            if (qtyText.isEmpty || int.tryParse(qtyText) == null || int.parse(qtyText) <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Quantity must be a positive number!"),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => isLoading = false);
              return;
            }

            // Validation for Type selection
            if (selectedType == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select a Type!"),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => isLoading = false);
              return;
            }

            // Validation for Seva type
            // Validation for Seva type
            if (selectedType == "Seva") {
              if (sevakNameController.text.trim().isEmpty || sevakNoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Sevak Name and Number are required for Seva!"),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() => isLoading = false);
                return;
              }

              // Validate Sevak No (should be exactly 10 digits)
              String sevakNo = sevakNoController.text.trim();
              if (!RegExp(r'^\d{10}$').hasMatch(sevakNo)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Sevak No must be exactly 10 digits!"),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() => isLoading = false);
                return;
              }
            }


            const String apiUrl = "http://27.116.52.24:8060/manageItem";
            String? username = await Preferences.getUserName();
            if (username == null || username.isEmpty) {
              throw Exception("Username is not available.");
            }

            int quantity = int.parse(qtyText);

            Map<String, dynamic> requestBody = {
              "table": "manage",
              "qty": quantity,
              "itemId": itemId,
              "type": selectedType!,
              "sevakName": showSevakFields ? sevakNameController.text.trim() : "",
              "sevakNo": showSevakFields ? sevakNoController.text.trim() : "",
              "expiryDate": ExpiryDateController.text.trim(),


              "itemTo": "Remove",  // Change from "Add" to "Remove"
              "createdBy": 1
            };

            try {
              final response = await http.post(
                Uri.parse(apiUrl),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(requestBody),
              );

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Item removed successfully!"), // Updated success message
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                await Future.delayed(Duration(milliseconds: 1500)); // Delay for visibility
                await _fc.GetFilteredItems(categoryId);

                Navigator.pop(context); // Close dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to remove item: ${response.statusCode}"), // Updated failure message
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (error) {
              print("ERROR: $error");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: $error"),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              setState(() => isLoading = false); // Hide loader
            }
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text(
              "Remove Item",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildHeader("Item Name"),
                    buildStyledTextField(
                      controller: itemNameController,
                      read: true,
                      isRequired: true,

                      label: "Item Name",
                    ),
                    _buildHeader("Quantity"),
                    buildStyledTextField(
                      controller: quantityController,
                      label: "Quantity",
                      isNumeric: true,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    _buildHeader("Expiry Date"),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            ExpiryDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: buildStyledTextField(
                          controller: ExpiryDateController,
                          label: "",
                          isRequired: true,

                        ),
                      ),
                    ),

                    _buildHeader("Type"),
                    buildDropdown(
                      "Type",
                      ["Purchase", "Seva"],
                      selectedType,
                          (value) {
                        setState(() {
                          selectedType = value;
                          showSevakFields = value == "Seva";
                        });
                      },
                    ),
                    if (showSevakFields) ...[
                      buildStyledTextField(
                        controller: sevakNameController,
                        label: "Sevak Name",
                      ),
                      buildStyledTextField(
                        controller: sevakNoController,
                        label: "Sevak No",
                        keyboardType: TextInputType.phone,
                      ),
                    ],

                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                ),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : removeItem,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Remove"),
              ),
            ],
          );
        },
      );
    },
  );


}


