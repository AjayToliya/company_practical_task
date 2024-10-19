import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Utils/Helper/Api_Helper_Class.dart';
import '../../models/category_model_class.dart';

class ShowCategoriesWidget extends StatefulWidget {
  const ShowCategoriesWidget({super.key});

  @override
  State<ShowCategoriesWidget> createState() => _ShowCategoriesWidgetState();
}

class _ShowCategoriesWidgetState extends State<ShowCategoriesWidget> {
  TextEditingController searchController = TextEditingController();
  late Future<List<CategoryModelClass>> allCategories;

  @override
  void initState() {
    super.initState();
    allCategories = ApiHelperClass.apiHelperClass.fetchCategories();
  }

  Future<void> _showEditDialog(CategoryModelClass category) async {
    final TextEditingController nameController =
        TextEditingController(text: category.name);
    Uint8List? updatedImage = category.image;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                  ),
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () async {
                    final XFile? pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 30,
                    );
                    if (pickedFile != null) {
                      updatedImage = await pickedFile.readAsBytes();
                      setState(() {}); // Refresh image display
                    }
                  },
                  child: CircleAvatar(
                    radius: 24.0,
                    backgroundImage: updatedImage != null
                        ? MemoryImage(updatedImage!)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: updatedImage == null
                        ? const Icon(Icons.image, color: Colors.grey)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedCategory = CategoryModelClass(
                  name: nameController.text,
                  image: updatedImage,
                  id: category.id,
                );
                try {
                  await ApiHelperClass.apiHelperClass.updateCategories(
                    category: updatedCategory,
                    id: category.id!,
                  );
                  setState(() {
                    allCategories =
                        ApiHelperClass.apiHelperClass.fetchCategories();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Category updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to update category'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(CategoryModelClass category) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ApiHelperClass.apiHelperClass
                      .deleteCategory(id: category.id!);
                  setState(() {
                    allCategories =
                        ApiHelperClass.apiHelperClass.fetchCategories();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Category deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to delete category'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAllDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content:
              const Text("Are you sure you want to delete all categories?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ApiHelperClass.apiHelperClass.deleteAllCategories();
                  setState(() {
                    allCategories =
                        ApiHelperClass.apiHelperClass.fetchCategories();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          const Text('All categories deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to delete all categories'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                allCategories =
                    ApiHelperClass.apiHelperClass.searchCategories(data: val);
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              hintText: "Search Category",
              labelText: "Search",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF7BB8B1)),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF7BB8B1)),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<CategoryModelClass>>(
            future: allCategories,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (snapshot.hasData) {
                final categories = snapshot.data;
                if (categories == null || categories.isEmpty) {
                  return Center(
                    child: Text(
                      'No data found',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final imageBytes = category.image;

                          return Card(
                            color: (index % 2 == 0)
                                ? const Color(0xFFE6E6E1)
                                : const Color(0xFFF7F7F0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              leading: imageBytes == null
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 32.0,
                                        color: Colors.grey[400],
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 24.0,
                                      backgroundImage: MemoryImage(imageBytes),
                                      backgroundColor: Colors.grey[200],
                                    ),
                              title: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                "Category ID: ${category.id}",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _showEditDialog(category),
                                    icon: const Icon(Icons.edit,
                                        size: 24.0, color: Colors.blueGrey),
                                    tooltip: 'Edit Category',
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _showDeleteDialog(category),
                                    icon: const Icon(Icons.delete,
                                        size: 24.0, color: Colors.redAccent),
                                    tooltip: 'Delete Category',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: OutlinedButton.icon(
                        onPressed: _showDeleteAllDialog,
                        icon: const Icon(Icons.delete_sweep,
                            color: Colors.redAccent),
                        label: const Text(
                          "Delete All Categories",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}
