import 'dart:typed_data';

class Product {
  final int? id;
  final String name;
  final int price;
  final String description;
  final String? coverImageUrl;
  final Uint8List? coverImageBytes;
  final String? coverImageName;

  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.coverImageUrl,
    this.coverImageBytes,
    this.coverImageName
  });
}