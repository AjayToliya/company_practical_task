import 'package:budget_buddy/models/Spending_model.dart';
import 'package:budget_buddy/models/category_model_class.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/Helper/Api_Helper_Class.dart';

class ShowSpendingComponent extends StatefulWidget {
  const ShowSpendingComponent({super.key});

  @override
  State<ShowSpendingComponent> createState() => _ShowSpendingComponentState();
}

class _ShowSpendingComponentState extends State<ShowSpendingComponent> {
  num totalIncome = 0;
  num totalExpense = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiHelperClass.apiHelperClass.fetchSpending(),
      builder: (context, snapShot) {
        if (snapShot.hasError) {
          return Center(
            child: Text(
              "No data Found: Error ${snapShot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        } else if (snapShot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapShot.hasData) {
          List<SpendingModel>? data = snapShot.data;

          return data!.isEmpty
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
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var item = data[index];
                    Color itemColor = item.spending_type == 'Income'
                        ? Colors.green
                        : Colors.red;
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await ApiHelperClass.apiHelperClass
                            .deleteSpending(spendingId: index + 1);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: FutureBuilder(
                            future: ApiHelperClass.apiHelperClass.findCategory(
                              id: data[index].spending_category! + 1,
                            ),
                            builder: (context, ss) {
                              if (ss.hasError) {
                                return const CircleAvatar(
                                  radius: 35,
                                  child: Icon(Icons.error_outline),
                                );
                              } else if (ss.hasData) {
                                CategoryModelClass? img = ss.data;
                                return CircleAvatar(
                                  radius: 35,
                                  backgroundImage: (img!.image == null)
                                      ? null
                                      : MemoryImage(img.image!),
                                );
                              }
                              return const CircleAvatar(
                                radius: 35,
                              );
                            },
                          ),
                        ),
                        title: Text(
                          "\$${data[index].spending_amount}",
                          style: TextStyle(
                              color: itemColor), // Apply itemColor here
                        ),
                        subtitle: Text(data[index].spending_type!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FutureBuilder<CategoryModelClass?>(
                              future:
                                  ApiHelperClass.apiHelperClass.findCategory(
                                id: data[index].spending_category! + 1,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Chip(
                                    label: Text(
                                      'Error',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.red),
                                    ),
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.all(8),
                                  );
                                } else if (snapshot.hasData) {
                                  CategoryModelClass? img = snapshot.data;
                                  return Chip(
                                    elevation: 0,
                                    label: Text(
                                      img?.name ?? 'No Name',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: const Color(0xFF7BB8B1),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                  );
                                }
                                return const Chip(
                                  label: Text(
                                    'Loading...',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.all(8),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    TextEditingController amountController =
                                        TextEditingController(
                                      text: data[index]
                                          .spending_amount
                                          .toString(),
                                    );
                                    String spendingType =
                                        data[index].spending_type!;
                                    int selectedCategory =
                                        data[index].spending_category!;

                                    return AlertDialog(
                                      title: const Text('Edit Spending'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: amountController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: "Spending Amount",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            DropdownButtonFormField<String>(
                                              value: spendingType,
                                              items: ['Income', 'Expense']
                                                  .map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                spendingType = newValue!;
                                              },
                                              decoration: const InputDecoration(
                                                labelText: "Spending Type",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            SpendingModel updatedSpending =
                                                SpendingModel(
                                              spending_id:
                                                  data[index].spending_id,
                                              spending_amount: double.parse(
                                                  amountController.text),
                                              spending_type: spendingType,
                                              spending_category:
                                                  selectedCategory,
                                            );

                                            await ApiHelperClass.apiHelperClass
                                                .updateSpending(
                                              spending: updatedSpending,
                                            );

                                            setState(() {
                                              data[index] = updatedSpending;
                                            });

                                            Navigator.pop(context);

                                            Get.snackbar(
                                              'Success',
                                              'Spending updated',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                            );
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
