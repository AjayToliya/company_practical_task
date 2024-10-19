import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import this for date formatting

import '../../Utils/Helper/Api_Helper_Class.dart';
import '../../models/Spending_model.dart';
import '../../models/category_model_class.dart';

class SpendingComponent extends StatefulWidget {
  const SpendingComponent({super.key});

  @override
  State<SpendingComponent> createState() => _SpendingComponentState();
}

class _SpendingComponentState extends State<SpendingComponent> {
  String? selectedType = "Expense";
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  int? initialIndex;
  double? amount;
  DateTime? selectedDate;

  final Color primaryColor = const Color(0xFF7BB8B1);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryModelClass>>(
      future: ApiHelperClass.apiHelperClass.fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("ERROR: ${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          var categories = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Amount",
                          labelText: "Amount",
                          hintStyle: TextStyle(color: primaryColor),
                          labelStyle: TextStyle(color: primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text("Pick Date"),
                          IconButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDialog(
                                context: context,
                                builder: (context) {
                                  return DatePickerDialog(
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime.now(),
                                    helpText: "Pick date...",
                                  );
                                },
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.date_range),
                          ),
                          if (selectedDate != null)
                            Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate!),
                              style: TextStyle(color: primaryColor),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Choose Expense/Income",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      RadioListTile<String>(
                        activeColor: primaryColor,
                        value: "Expense",
                        groupValue: selectedType,
                        onChanged: (val) {
                          setState(() {
                            selectedType = val;
                          });
                        },
                        title: const Text("Expense"),
                      ),
                      RadioListTile<String>(
                        activeColor: primaryColor,
                        value: "Income",
                        groupValue: selectedType,
                        onChanged: (val) {
                          setState(() {
                            selectedType = val;
                          });
                        },
                        title: const Text("Income"),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Use SizedBox instead of Expanded
                      SizedBox(
                        height: 200, // Set a fixed height
                        child: categories.isEmpty
                            ? Center(
                                child: Text(
                                  'No data found',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 3 / 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  Uint8List? imageBytes;

                                  if (category.image != null) {
                                    imageBytes = category.image as Uint8List?;
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        initialIndex = (initialIndex == index)
                                            ? null
                                            : index;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          color: Colors.grey[100],
                                          border: (initialIndex == index)
                                              ? Border.all(
                                                  color: primaryColor,
                                                  width: 2.0)
                                              : null),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          imageBytes == null
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 48.0,
                                                    color: Colors.grey[400],
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  radius: 36.0,
                                                  backgroundImage:
                                                      MemoryImage(imageBytes),
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                amount = double.tryParse(amountController.text);
                                if (amount != null && selectedDate != null) {
                                  SpendingModel spending = SpendingModel(
                                    spending_amount: amount,
                                    spending_type: selectedType,
                                    spending_category: initialIndex,
                                    spending_date: DateFormat('dd/MM/yyyy').format(
                                        selectedDate!), // Format and assign the date
                                  );
                                  ApiHelperClass.apiHelperClass
                                      .insertSpending(spending: spending)
                                      .then((_) {
                                    setState(() {
                                      selectedType = "Expense";
                                      initialIndex = null;
                                      amountController.clear();
                                      amount = null;
                                      selectedDate =
                                          null; // Reset the selected date
                                      Get.snackbar(
                                        'Success',
                                        'Spending record added successfully.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: primaryColor,
                                      );
                                    });
                                  }).catchError((error) {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to add spending record: $error',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: primaryColor,
                                    );
                                  });
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Invalid amount value or date not selected.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: primaryColor,
                                  );
                                }
                              }
                            },
                            label: Text(
                              "Add Amount",
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            icon: Icon(
                              Icons.add,
                              color: primaryColor,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedType = "Expense";
                                initialIndex = null;
                                amountController.clear();
                                amount = null;
                                selectedDate = null; // Reset the selected date
                              });
                            },
                            label: Text("Reset",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold)),
                            icon: Icon(
                              Icons.refresh,
                              color: primaryColor,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
