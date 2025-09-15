import 'package:flutter/material.dart';

import '../models/category.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({
    super.key,
    required this.categories,
    required this.searchController,
    required this.specialsOnly,
    required this.selectedCategoryId,
    required this.onSearchChanged,
    required this.onSpecialsChanged,
    required this.onCategoryChanged,
  });

  final List<Category> categories;
  final TextEditingController searchController;
  final bool specialsOnly;
  final String selectedCategoryId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onSpecialsChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: 320,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ListView(
        children: <Widget>[
          Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search products',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Special Offers Only'),
            value: specialsOnly,
            onChanged: onSpecialsChanged,
          ),
          const SizedBox(height: 16),
          Text('Categories', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: const Text('All Products'),
            value: 'all',
            groupValue: selectedCategoryId,
            onChanged: (String? value) {
              if (value != null) {
                onCategoryChanged(value);
              }
            },
          ),
          for (final Category category in categories)
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: Text(category.name),
              subtitle: category.description.isNotEmpty ? Text(category.description) : null,
              value: category.id,
              groupValue: selectedCategoryId,
              onChanged: (String? value) {
                if (value != null) {
                  onCategoryChanged(value);
                }
              },
            ),
        ],
      ),
    );
  }
}
