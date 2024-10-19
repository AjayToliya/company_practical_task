import 'dart:typed_data';

class CategoryModelClass {
  int? id;
  String name;
  Uint8List? image;
  CategoryModelClass({
    this.id,
    required this.name,
    this.image,
  });
  factory CategoryModelClass.fromMap({required data}) {
    return CategoryModelClass(
        id: data['category_id'],
        name: data['category_name'],
        image: data['category_image']);
  }
}
