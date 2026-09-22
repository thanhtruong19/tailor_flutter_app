class ProductVariant {
  final int? id;
  final String color;
  final String size;
  final int stockQuantity;

  const ProductVariant({
    this.id,
    required this.color,
    required this.size,
    required this.stockQuantity,
  });
}