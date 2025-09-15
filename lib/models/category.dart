import 'package:flutter/material.dart';

import 'sub_category.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    this.description = '',
    this.color,
    this.subCategories = const <SubCategory>[],
  });

  final String id;
  final String name;
  final String description;
  final Color? color;
  final List<SubCategory> subCategories;
}
