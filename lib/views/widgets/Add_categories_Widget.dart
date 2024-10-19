import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../Utils/All_data.dart';
import '../../Utils/Helper/Api_Helper_Class.dart';
import '../../models/category_model_class.dart';
import 'package:flutter/services.dart' show rootBundle;

class AddCategoriesWidget extends StatefulWidget {
  const AddCategoriesWidget({super.key});

  @override
  State<AddCategoriesWidget> createState() => _AddCategoriesWidgetState();
}

class _AddCategoriesWidgetState extends State<AddCategoriesWidget> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final ImagePicker picker = ImagePicker();

  TextEditingController addCategoryController = TextEditingController();
  Uint8List? selectedImageBytes;
  String? categoryName;

  Future<Uint8List> loadAssetImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add New Category",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7BB8B1), // Teal-like color for title
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                onSaved: (val) {
                  categoryName = val;
                },
                controller: addCategoryController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter the category name.";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF7BB8B1)),
                  ),
                  labelText: "Category Name",
                  hintText: "Enter category name",
                  labelStyle: const TextStyle(color: Color(0xFF7BB8B1)),
                  prefixIcon:
                      const Icon(Icons.category, color: Color(0xFF7BB8B1)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF7BB8B1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(
                          0xFFF7F7F0), // Light beige for consistency
                      backgroundImage: selectedImageBytes != null
                          ? MemoryImage(selectedImageBytes!)
                          : null,
                      child: selectedImageBytes == null
                          ? GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                  titleStyle: const TextStyle(fontSize: 18),
                                  title: "Pick an Image",
                                  middleText: "Choose an image source:",
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        XFile? image = await picker.pickImage(
                                          source: ImageSource.camera,
                                          imageQuality: 30,
                                        );
                                        if (image != null) {
                                          selectedImageBytes =
                                              await image.readAsBytes();
                                          setState(() {});
                                          Get.back(); // Dismiss the bottom sheet
                                          // Show the alert dialog
                                          Get.dialog(
                                            AlertDialog(
                                              content: Image.memory(
                                                  selectedImageBytes!),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Get.back(); // Close the dialog
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.camera_alt),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        Get.bottomSheet(
                                          Container(
                                            padding: const EdgeInsets.all(16.0),
                                            child: GridView.builder(
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 10.0,
                                                mainAxisSpacing: 10.0,
                                              ),
                                              itemCount: allImages.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    Uint8List imageBytes =
                                                        await loadAssetImage(
                                                            allImages[index]);
                                                    selectedImageBytes =
                                                        imageBytes;
                                                    Navigator.pop(
                                                        context); // Close the bottom sheet
                                                    // Show the alert dialog
                                                    Get.dialog(
                                                      AlertDialog(
                                                        content: Image.memory(
                                                            selectedImageBytes!),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Get.back(); // Close the dialog
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    child: Image.asset(
                                                      allImages[index],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          isScrollControlled: true,
                                          ignoreSafeArea: false,
                                          backgroundColor: Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16.0)),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.image),
                                    ),
                                  ],
                                );
                              },
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.blueGrey,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.defaultDialog(
                          titleStyle: const TextStyle(fontSize: 18),
                          title: "Pick an Image",
                          middleText: "Choose an image source:",
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text('Cancel'),
                            ),
                            IconButton(
                              onPressed: () async {
                                XFile? image = await picker.pickImage(
                                    source: ImageSource.camera);
                                if (image != null) {
                                  selectedImageBytes =
                                      await image.readAsBytes();
                                  setState(() {});
                                }
                                Get.back();
                              },
                              icon: const Icon(Icons.camera_alt),
                            ),
                            IconButton(
                              onPressed: () async {
                                Get.bottomSheet(
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                      ),
                                      itemCount: allImages.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            Uint8List imageBytes =
                                                await loadAssetImage(
                                                    allImages[index]);
                                            selectedImageBytes = imageBytes;
                                            setState(() {});
                                            Get.back();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Image.asset(
                                              allImages[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  isScrollControlled: true,
                                  ignoreSafeArea: false,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16.0)),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.image),
                            ),
                          ],
                        );
                      },
                      icon: const Icon(
                        Icons.camera,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        'Pick Image',
                        style: TextStyle(color: Color(0xFF7BB8B1)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();

                          if (selectedImageBytes != null &&
                              categoryName != null) {
                            CategoryModelClass category = CategoryModelClass(
                                name: categoryName!, image: selectedImageBytes);
                            ApiHelperClass.apiHelperClass
                                .insertCategories(category: category);
                            formKey.currentState?.reset();
                            addCategoryController.clear();
                            selectedImageBytes = null;
                            setState(() {});

                            Get.snackbar(
                              "Category Added Successfully",
                              "The category has been successfully added to your list.",
                              backgroundColor: Colors.green.withOpacity(0.8),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.white),
                              snackPosition: SnackPosition.TOP,
                            );
                            ApiHelperClass.apiHelperClass.fetchCategories();
                          }
                        } else {
                          Get.snackbar(
                            "Category Addition Failed",
                            "There was an error adding the category. Please try again.",
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            icon: const Icon(Icons.error, color: Colors.white),
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      label: const Text(
                        "Add Category",
                        style:
                            TextStyle(color: Color(0xFFF7F7F0), fontSize: 16),
                      ),
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xFFF7F7F0),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF7BB8B1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        formKey.currentState?.reset();
                        addCategoryController.clear();
                        selectedImageBytes = null;
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh, color: Color(0xFF7BB8B1)),
                      label: const Text(
                        'Reset',
                        style:
                            TextStyle(color: Color(0xFF7BB8B1), fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7BB8B1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
