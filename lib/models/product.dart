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
    this.currencyCode = 'USD',
    this.currencySymbol = 'US\$',
    this.currencySuffix = '',
    this.permalink,
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
  final String currencyCode;
  final String currencySymbol;
  final String currencySuffix;
  final String? permalink;

  double get savings => oldPrice != null ? oldPrice! - price : 0;

  String get currencyLabel {
    if (currencySymbol.trim().isNotEmpty) {
      return currencySymbol.trim();
    }
    if (currencySuffix.trim().isNotEmpty) {
      return currencySuffix.trim();
    }
    return currencyCode;
  }

  String formatPrice(double amount) {
    final String formatted = amount.toStringAsFixed(2);
    final String symbol = currencySymbol.trim();
    final String suffix = currencySuffix.trim();
    if (symbol.isNotEmpty && suffix.isNotEmpty) {
      return '$symbol $formatted $suffix';
    }
    if (symbol.isNotEmpty) {
      return '$symbol $formatted';
    }
    if (suffix.isNotEmpty) {
      return '$formatted $suffix';
    }
    return '${currencyCode.toUpperCase()} $formatted';
  }
}
