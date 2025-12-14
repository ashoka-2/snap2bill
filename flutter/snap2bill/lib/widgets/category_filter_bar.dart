import 'package:flutter/material.dart';
import '../data/dataModels.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<CategoryData> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const CategoryFilterBar({
    Key? key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedId == cat.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat.name),
              selected: isSelected,
              onSelected: (_) => onSelect(cat.id),
              selectedColor: theme.primaryColor,
              backgroundColor:
              isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
