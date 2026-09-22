import 'dart:typed_data';

import 'product_variant.dart';

class Product {
  int? id;
  String name;
  double price;
  String description;
  String? coverImageUrl;
  Uint8List? coverImageBytes;
  String? coverImageName;
  List<ProductVariant> variants;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.coverImageUrl,
    this.coverImageBytes,
    this.coverImageName,
    List<ProductVariant>? variants,
  }) : variants = variants ?? [];
}
