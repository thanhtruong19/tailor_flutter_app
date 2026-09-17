class Product {
  final int? id;
  final String name;
  final int price;
  final String description;
  final String? coverImageUrl;

  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.coverImageUrl,
  });
}