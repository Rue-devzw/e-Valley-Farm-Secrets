class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.unit,
    required this.imageUrl,
    this.subCategoryId,
    this.oldPrice,
    this.description,
    this.onSpecial = false,
  });

  final String id;
  final String name;
  final String categoryId;
  final String? subCategoryId;
  final double price;
  final double? oldPrice;
  final String unit;
  final bool onSpecial;
  final String imageUrl;
  final String? description;

  double get savings => oldPrice != null ? oldPrice! - price : 0;
}
